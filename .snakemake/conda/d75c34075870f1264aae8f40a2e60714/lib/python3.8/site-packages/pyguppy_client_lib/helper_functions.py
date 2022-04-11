#! /usr/bin/env python3

import os
import json
import subprocess
import time
import warnings
from itertools import cycle
from pyguppy_client_lib.client_lib import GuppyClient

H5PY_UNAVAILABLE = False
try:
    from ont_fast5_api.fast5_read import Fast5Read
    from ont_fast5_api.fast5_interface import get_fast5_file
except Exception:
    H5PY_UNAVAILABLE = True

# Counter that cycles [0, 2**32)
_COUNT = cycle(range(0, int(2 ** 32), 1))
FINISH_TIMEOUT = 300

warnings.filterwarnings("default", category=DeprecationWarning,
                        module=__name__)


def _check_fast5_api():
    if H5PY_UNAVAILABLE:
        raise RuntimeError('ont_fast5_api must be installed to use this function')


def pull_read(fast5_read):
    _check_fast5_api()
    input_read = fast5_read
    if not isinstance(input_read, Fast5Read):
        warnings.warn("pull_read() will no longer support pathnames soon.",
                      DeprecationWarning)
        with get_fast5_file(fast5_read, mode='r') as f5:
            input_read = f5.get_read(f5.get_read_ids()[0])
            read_id = input_read.read_id
            channel_info = input_read.get_channel_info()
            raw_data = input_read.get_raw_data()
    else:
        read_id = input_read.read_id
        channel_info = input_read.get_channel_info()
        raw_data = input_read.get_raw_data()
    rng = channel_info["range"]
    digi = channel_info["digitisation"]
    read = {
        "raw_data": raw_data,
        "read_id": read_id,
        "daq_offset": channel_info["offset"],
        "daq_scaling": rng / digi
    }
    return read


def _get_all_read_ids(files):
    read_ids = []
    for filename in files:
        with get_fast5_file(filename, mode='r') as f5:
            read_ids += f5.get_read_ids()
    return read_ids


def _read_generator(files):
    for filename in files:
        with get_fast5_file(filename, mode='r') as f5:
            for read_id in f5.get_read_ids():
                yield f5.get_read(read_id)


def basecall_with_pyguppy(client, input_path, save_file=None):
    _check_fast5_api()
    if save_file is not None:
        out = open(save_file, "w")
        out.write("read_id\tsequence_length\n")
    else:
        out = None

    try:
        num_reads_sent = 0
        num_reads_called = 0
        called_ids = []
        called_reads = []
        files = [os.path.join(input_path, f)
                 for f in os.listdir(input_path)
                 if f.endswith(".fast5")]
        all_reads = _get_all_read_ids(files)
        read_count = len(all_reads)
        generator = _read_generator(files)
        while num_reads_sent < read_count:
            next_read = next(generator)
            read = pull_read(next_read)
            read["read_tag"] = num_reads_sent
            result = client.pass_read(read)
            while result == GuppyClient.queue_full:
                time.sleep(0.05)
                result = client.pass_read(read)
            if result == GuppyClient.read_accepted:
                num_reads_sent += 1
            else:
                raise Exception("Attempt to pass read to server failed. Return value is {}.".format(result))
            completed_reads = client.get_completed_reads()
            for read in completed_reads:
                read_id = read["metadata"]["read_id"]
                sequence_length = read["metadata"]["sequence_length"]
                called_ids.append(read["read_tag"])
                called_reads.append(read)
                num_reads_called += 1
                if out is not None:
                    out.write("{}\t{}\n".format(read_id, sequence_length))

        result = client.finish(FINISH_TIMEOUT)
        if GuppyClient.success != result:
            raise Exception("Call to final() method did not complete quickly enough. Return value is {}.".format(result))

        completed_reads = client.get_completed_reads()
        for read in completed_reads:
            read_id = read["metadata"]["read_id"]
            sequence_length = read["metadata"]["sequence_length"]
            called_ids.append(read["read_tag"])
            called_reads.append(read)
            num_reads_called += 1
            if out is not None:
                out.write("{}\t{}\n".format(read_id, sequence_length))
    except Exception:
        raise
    finally:
        if out is not None:
            out.close()
    unique_ids = set(called_ids)
    assert read_count == num_reads_sent
    assert read_count == num_reads_called
    assert read_count == len(unique_ids)
    return called_reads


def run_server(options, bin_path=None):
    """
    Start a basecall server with the specified parameters.
    :param options: List of command line options for the server.
    :param bin_path: Optional path to basecall server binary executable.
    :return: A tuple containing the handle to the server process, and the port the server is listening on.

    If the server cannot be started, the port will be returned as 'ERROR'.
    Use the 'auto' option for the port to have the server automatically select an available port.
    """
    executable = "guppy_basecall_server"
    if bin_path is not None:
        executable = os.path.join(bin_path, executable)
    server_args = [executable]
    server_args.extend(options)

    print("Server command line: ", " ".join(server_args))
    server = subprocess.Popen(server_args, stdout=subprocess.PIPE)
    for line in iter(server.stdout.readline, ""):
        message_to_find = b"Starting server on port: "
        if message_to_find in line:  # This will be true when the server has started up.
            port_string = line[len(message_to_find) :].decode("ascii").strip()
            break
        if len(line) == 0:  # If something goes wrong, this prevents an endless loop.
            return server, "ERROR"
    print("Server started on port: {}".format(port_string))
    return server, port_string


def package_read(
    read_id: str,
    raw_data: "numpy.ndarray[numpy.int16]",
    daq_offset: float,
    daq_scaling: float,
    read_tag: int = None,
) -> dict:
    """Package a read for pyguppy_client_lib

    :param read_id: Read ID for the read, doesn't need to be unique but must
        not be empty
    :type read_id: str
    :param raw_data: 1d numpy array of signed 16 bit integers
    :type raw_data: numpy.ndarray[numpy.int16]
    :param daq_offset: Offset for pA conversion
    :type daq_offset: float
    :param daq_scaling: Scale factor for pA conversion
    :type daq_scaling: float
    :param read_tag: 32 bit positive integer, must be unique to each read. If
        ``None`` will be assigned a value from the pyguppy global counter
    :type read_tag: int

    :returns: read data packaged for guppy
    :rtype: dict
    """
    if read_tag is None:
        read_tag = next(_COUNT)
    return {
        "read_tag": read_tag,
        "read_id": read_id,
        "raw_data": raw_data,
        "daq_offset": daq_offset,
        "daq_scaling": daq_scaling,
    }


def get_barcode_kits(address: str, timeout: int) -> list:
    """Get available barcode kits from server

    :param address: guppy_basecall_server address eg: 127.0.0.1:5555
    :type address: str
    :param timeout: Timeout in milliseconds
    :type timeout: int

    :raises RuntimeError: if failed to retrieve barcode kits from server.

    :returns: List of barcode kits supported by the server
    :rtype: list
    """
    result, status = GuppyClient.get_barcode_kits(address, timeout)
    if status != GuppyClient.success:
        raise RuntimeError("Could not get barcode kits")
    return result

def get_server_stats(address: str, timeout: int) -> dict:
    """Get statistics from server

    :param address: guppy_basecall_server address eg: 127.0.0.1:5555
    :type address: str
    :param timeout: Timeout in milliseconds
    :type timeout: int

    :raises RuntimeError: if failed to retrieve statistics from server

    :returns: Dictionary of server stats
    :rtype: dict
    """
    result, status = GuppyClient.get_server_stats(address, timeout)
    if status != GuppyClient.success:
        raise RuntimeError("Could not get server stats")
    return result

def get_server_information(address: str, timeout: int) -> dict:
    """Get server information

    :param address: guppy_basecall_server address eg: 127.0.0.1:5555
    :type address: str
    :param timeout: Timeout in milliseconds
    :type timeout: int

    :raises RuntimeError: if failed to retrieve information from server

    :returns: Dictionary of server information
    :rtype: dict
    """
    result_str, status = GuppyClient.get_server_information(address, timeout)
    if status == GuppyClient.timed_out:
        raise RuntimeError("Request for server information timed out")
    if status != GuppyClient.success:
        raise RuntimeError("An error occurred attempting to retrieve server information")
    result_dict = json.loads(result_str)
    return result_dict
