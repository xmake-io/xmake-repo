# cpython >= 3.8
# @see https://docs.python.org/3/library/os.html#os.add_dll_directory
import os

if os.name == "nt":
    os.add_dll_directory(os.path.join(os.path.abspath(os.path.dirname(os.path.dirname(__file__))), "bin"))

import libxml2mod