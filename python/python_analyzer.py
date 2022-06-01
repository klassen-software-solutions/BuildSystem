#!/usr/bin/env python3

"""Program to run a static analysis on a directory.

   Note that at present this simply runs pylint.
"""

import os
import subprocess
import sys

def _main(directory):
    if not os.path.isdir(directory):
        print(f"'{directory}' does not exist or is not a directory")
        sys.exit(-1)
    subprocess.run(f"pylint {directory}", shell=True, check=True)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("usage: python_analyzer.py <directory>", file=sys.stderr)
        sys.exit(-1)
    _main(sys.argv[1])
