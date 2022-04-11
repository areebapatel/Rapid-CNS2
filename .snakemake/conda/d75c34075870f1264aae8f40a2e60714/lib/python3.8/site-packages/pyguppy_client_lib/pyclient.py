import time
from typing import Any, Callable, List, Union

from pyguppy_client_lib.client_lib import GuppyClient


class PyGuppyClient(GuppyClient):
    """Python interface for guppy_basecall_server

    Any optional server parameters can be accessed via the ``params`` attribute

    :param address: The formatted address and port for the guppy_basecall_server,
        eg '127.0.0.1:5555'
    :type address: str
    :param config: The basecalling config to initialise the server with.
    :type config: str
    :param throttle: Time, in seconds, to delay repeated requests to the server
    :type throttle: float
    :param retries: Number of retry attempts when sending data, if the server is
        not ready
    :type retries: int
    :param kwargs: Any optional server parameters can be set as keyword arguments
        and will be passed to the server. To see available server parameters see
        the help text for ``set_params``.

    .. note::
        Some server parameters, this list may be incomplete:
            * ``barcode_kits`` `(list)` Strings naming each barcode kit to use. Default is to
                not do barcoding.
            * ``timeout`` `(int)` Milliseconds to wait for a server response before timing
                out. Default is 2000.
            * ``block_size`` `(int)` Size of blocks to be sent to the server, in samples.
                Default is 50000.
            * ``max_reads_queued`` `(int)` Maximum number of reads to queue for sending to the
                server. Default is 20.
            * ``priority`` `(ReadPriority)` Priority of the client (low, medium, or high). Default is
                medium.
            * ``move_and_trace_enabled`` `(bool)` Flag indicating whether to return trace and
                move data. Default is True.
            * ``state_data_enabled`` `(bool)` Flag indicating whether to return full posterior
                state data. Default is False.
            * ``barcode_trimming_enabled`` `(bool)` Flag indicating that barcodes should be
                trimmed. Default is False.
            * ``alignment_index_file`` `(str)` Filename of index file to use for alignment
                (if any). Default is to not align.
            * ``bed_file`` `(str)` Filename of BED file to use for alignment (if any). Default
                is to not align.
            * ``alignment_type`` `(str)` Type of alignment required. Valid values are "auto", "coarse", and "full".
            * ``server_file_load_timeout`` `(int)` Seconds to wait for files to be loaded on
                the server. Default is 30.
            * ``require_barcodes_both_ends`` `(bool)` Flag indicating that barcodes must be at
                both ends. Default is False.
            * ``detect_mid_strand_barcodes`` `(bool)` Flag indicating that read will be marked
                as unclassified if barcodes appear within the strand itself. Default is False.
            * ``detect_mid_strand_adapter`` `(bool)` Flag indicating that read will be marked
                as unclassified if adapter sequence appears within the strand itself. Default is False.
            * ``min_score_front_barcodes`` `(float)` Minimum score for a front barcode to be
                classified. Default is 60.
            * ``min_score_rear_barcodes`` `(float)` Minimum score for a rear barcode to be
                classified. Default is to use the front minimum.
            * ``min_score_mid_barcodes`` `(float)` Minimum score for mid barcodes to be detected.
                Default is 60.

    :Example:

    >>> caller = PyGuppyClient(
        "127.0.0.1:5555",
        "dna_r9.4.1_450bps_fast",
        alignment_index_file="/path/to/index.mmi",
        bed_file="/path/to/targets.bed"
    )
    >>> caller.connect()

    .. note:: ``GuppyClient`` does `not` raise raise_errors. Each time an
        action is made a code is returned and must be checked.

         - ``result.align_index_unavailable``
         - ``result.already_connected``
         - ``result.barcode_kit_unavailable``
         - ``result.basecall_config_unavailable``
         - ``result.bed_file_unavailable``
         - ``result.failed``
         - ``result.invalid_response``
         - ``result.no_connection``
         - ``result.not_ready``
         - ``result.success``
         - ``result.timed_out``
    """

    def __init__(
        self,
        address: str,
        config: str,
        throttle: float = 0.01,
        retries: int = 5,
        **kwargs
    ):
        # Set instance vars
        self.address = address
        self.config = config
        self.throttle = throttle
        self.params = kwargs

        # Allow config to use '.cfg' suffix
        suffix = ".cfg"
        if self.config.endswith(suffix):
            self.config = self.config[: -len(suffix)]

        # When server is not ready, how many times should we attempt
        #   to send a read
        self.pass_attempts = retries

        # Init base class
        super().__init__(self.address, self.config)

        # Pass any params
        self.set_params(self.params)

    def connect(self):
        """Connect to the guppy_basecall_server

        On first connection external files will be loaded (minimap2 index and
        bed file), the ``server_file_load_timeout`` parameter should be set
        if these will take >30 seconds to load.

        :raises ConnectionError: When cannot connect, the connection attempt
            times out, or an invalid response is received
        :raises ValueError: When the barcode kit is unavailable.
        :raises RuntimeError: When an undefined return code is returned

        :returns: None

        .. Note::
        If attempting to connect when already connected, the return code will be
        ``already_connected``, but the client will remain connected.
        """
        return_code = super().connect()
        if self.get_status() != self.connected:
            if return_code == self.barcode_kit_unavailable:
                raise ValueError("Barcode kit unavailable: {!r}".format(return_code))
            elif return_code == self.basecall_config_unavailable:
                raise ValueError("Basecalling config unavailable: {!r}".format(return_code))
            elif return_code == self.invalid_response:
                raise ConnectionError("Received invalid response: {!r}".format(return_code))
            elif return_code == self.failed:
                raise ConnectionError("Failed to establish connection: {}".format(self.get_error_message()))

            tries = 0
            while self.get_status() != self.connected:
                # Should be in error state, so clear
                self.disconnect()
                return_code = super().connect()
                tries += 1
                if tries >= self.pass_attempts:
                    break
                time.sleep(self.throttle)
            else:
                # Should only get here if status is connected
                return

            # Handle return_code
            if return_code == self.success:
                return
            elif return_code == self.failed:
                raise ConnectionError(
                    "Could not connect. Is the server running? Check your connection parameters. {!r} : {}".format(
                        return_code, self.get_error_message()
                    )
                )
            elif return_code == self.timed_out:
                raise ConnectionError("Connection attempt timed out: {!r}".format(return_code))
            elif return_code == self.invalid_response:
                raise ConnectionError("Received invalid response: {!r}".format(return_code))
            elif return_code == self.basecall_config_unavailable:
                raise ValueError("Basecalling config unavailable: {!r}".format(return_code))
            elif return_code == self.barcode_kit_unavailable:
                raise ValueError("Barcode kit unavailable: {!r}".format(return_code))
            else:
                raise RuntimeError("Undefined return code: {}".format(return_code))

    def __repr__(self):
        return (
            "{}(address={!r},"
            " config={!r},"
            " alignment_index_file={!r},"
            " bed_file={!r},"
            " barcodes={!r},"
            " {}, {})"
        ).format(
            self.__class__.__name__,
            self.address,
            self.config,
            self.params.get("alignment_index_file", None),
            self.params.get("bed_file", None),
            self.params.get("barcode_kits", None),
            self.get_status(),
            self.get_error_message(),
        )

    def pass_read(
        self,
        read: Union[dict, Any],
        package_function: Callable[..., dict] = lambda x: x,
    ):
        """Pass a read to the basecall server

        If ``read`` is a dict it must be initialised with the following fields:
            - ``read_tag`` (`int`) 32-bit uint
            - ``read_id`` (`str`) Non-empty string
            - ``raw_data`` (`numpy.ndarray[numpy.int16]`) 1D NumPy array of int 16
            - ``daq_offset`` (`float`) Offset value for conversion to pA
            - ``daq_scaling`` (`float`) Scaling value for conversion to pA

        :param read: Either a packaged read or object that can be packaged by
            package_function
        :type read: dict or Any
        :param package_function: optional callback function that should return
            a packaged read
        :type package_function: callable

        :raises ValueError: When send fails, this is usually returned when the
            read is malformed
        :raises ConnectionError: Raised when there is no connection
        :raises RuntimeError: Raised when an undefined response is returned

        :return: True if read sent successfully, otherwise False
        :rtype: bool
        """
        current_status = self.get_status()
        if current_status != self.connected:
            raise ConnectionError(
                "Not connected to server. status code: {!r}. {!r}".format(current_status, self)
            )

        # Make first attempt to pass read to guppy
        read = package_function(read)
        return_code = super().pass_read(read)
        if return_code == self.read_accepted:
            # Read passed successfully, return
            return True

        # Read failed to send
        # reattempt sending if not_ready or handle errors
        for _ in range(self.pass_attempts):
            if return_code == self.queue_full:
                time.sleep(self.throttle)
                return_code = super().pass_read(read)
            else:
                break

        if return_code == self.read_accepted:
            return True
        elif return_code == self.queue_full:
            return False
        elif return_code == self.bad_read:
            raise ValueError(
                "Something went wrong, read dict might be malformed. return_code: {!r}".format(
                    return_code
                )
            )
        elif return_code == self.not_accepting_reads:
            raise ConnectionError(
                "Not accepting reads (disconnected or finished). return_code: {!r}".format(return_code)
            )
        else:
            raise RuntimeError("Undefined return_code: {!r}".format(return_code))

    def get_completed_reads(self) -> List[dict]:
        """Get completed reads from the server

        :raises ConnectionError: When not connected to server
        :raises RuntimeError: When could not retrieve reads or an unexpected
            return code was received

        :return: List of dictionaries, where each dict is a called read
        :rtype: list[dict]
        """
        """Wrapper for get_completed_reads"""
        current_status = self.get_status()
        if current_status != self.connected:
            raise ConnectionError(
                "Not connected to server. status code: {!r}. {!r}".format(current_status, super())
            )

        results = super().get_completed_reads()
        return results

    def set_params(self, params: dict):
        for key, value in params.items():
            return_code = super().set_params({key: value})
            if return_code != self.success:
                if return_code == self.already_connected:
                    raise RuntimeError(
                        "Attempting to set connection parameters while connected is not supported. Please set parameters before connecting."
                    )
                elif return_code == self.failed:
                    raise ValueError(
                        "Could not set server parameter {!r} using value {!r}".format(
                            key, value,
                        )
                    )
                else:
                    raise RuntimeError("Unexpected response from guppy server")

    def __enter__(self):
        """Make a connection to the server.

        This could be slow on the first connection due to loading the alignment
        index
        """
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Close the connection to the server."""
        self.disconnect()
