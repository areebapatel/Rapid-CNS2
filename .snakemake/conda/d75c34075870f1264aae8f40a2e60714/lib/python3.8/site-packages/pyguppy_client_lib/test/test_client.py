#! /usr/bin/env python3

import os
import unittest
import pkg_resources
from pyguppy_client_lib import TEST_SERVER_PORT
from pyguppy_client_lib.client_lib import GuppyClient
from pyguppy_client_lib.helper_functions import basecall_with_pyguppy

# We will skip the tests if h5py is not available.
H5PY_UNAVAILABLE = False
try:
    import h5py
except Exception:
    H5PY_UNAVAILABLE = True


class TestGuppyClientLib(unittest.TestCase):
    # TEST_SERVER_PORT can be set automatically in the main __init__.py when a
    # server is started, but if it's not we'll check for an environment
    # variable.
    SERVER_ADDRESS = TEST_SERVER_PORT
    if SERVER_ADDRESS is None:
        SERVER_ADDRESS = os.environ.get('TEST_SERVER_PORT')
    DNA_CONFIG = 'dna_r9.4.1_450bps_fast'
    DNA_FOLDER = 'fast5'
    print('Server address is {}'.format(SERVER_ADDRESS))

    def setUp(self):
        data_dir = os.path.join('test', 'data')
        self.data_path = pkg_resources.resource_filename('pyguppy_client_lib', data_dir)

    def tearDown(self):
        pass

    def test_00_basecalling_test(self):
        if TestGuppyClientLib.SERVER_ADDRESS is None:
            raise unittest.SkipTest('No server port has been set.')
        if H5PY_UNAVAILABLE:
            raise unittest.SkipTest('Could not import h5py.')
        input_folder = os.path.join(self.data_path, TestGuppyClientLib.DNA_FOLDER)
        client = GuppyClient(TestGuppyClientLib.SERVER_ADDRESS, TestGuppyClientLib.DNA_CONFIG)
        client.set_params({"name": "guppy_client_test_00_basecalling_test"})
        self.assertEqual(GuppyClient.disconnected, client.get_status(),
                         "validate connection status disconnected prior to connect.")
        result = client.connect()
        self.assertEqual(GuppyClient.success, result)
        self.assertEqual(GuppyClient.connected, client.get_status(), "validate connection status after connecting.")
        try:
            basecall_with_pyguppy(client, input_folder)
        except Exception:
            raise
        finally:
            client.disconnect()
