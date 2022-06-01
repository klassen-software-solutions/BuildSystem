#!/usr/bin/env python3

"""Program to run the Xcode static analyzer and interpret the results."""

import logging
import os
import subprocess
import sys

def _run(command: str):
    logging.info("running: %s", command)
    subprocess.run(f"{command}", shell=True, check=True)

def _get_run(command: str):
    res = subprocess.run(f"{command}", shell=True, check=True,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return res.stdout.decode('utf-8').strip()

def _process(command: str):
    # pylint: disable=consider-using-with
    #   Justification: It would complicate things and this is a short running script.
    logging.info("processing: %s", command)
    res = subprocess.Popen(f"{command}", shell=True,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return res.stdout

def _main():
    logging.basicConfig(level=logging.DEBUG)

    os_name = _get_run('uname -s')
    hardware_name = _get_run('uname -m')
    arch = f"{os_name}-{hardware_name}"
    build_dir = f".build/{arch}"
    install_prefix = os.environ.get('KSS_INSTALL_PREFIX', '/opt/kss')
    logging.info("ARCH=%s", arch)
    logging.info("INSTALL_PREFIX=%s", install_prefix)
    logging.info("BUILDDIR=%s", build_dir)

    warning_count = 0
    analyze_failed = False
    _run("rm -rf Build")
    command = "xcodebuild -alltargets -configuration Debug -quiet analyze"
    command += f' HEADER_SEARCH_PATHS="{build_dir}/include {install_prefix}/include"'
    command += f' LIBRARY_SEARCH_PATHS="{build_dir}/lib {install_prefix}/lib"'
    for line in _process(command):
        line = line.decode('utf-8').rstrip()
        print(f"{line}")
        if "warning:" in line:
            if "ld: warning: directory not found for option" not in line:
                # this warning isn't a code problem, but occurs when we have no prereqs
                # hence do not have the /opt or /tmp/opt prerequisite directory
                warning_count += 1
        if "** ANALYZE FAILED **" in line:
            analyze_failed = True

    if warning_count > 0:
        logging.info("Found %d warnings", warning_count)
        sys.exit(warning_count)
    if analyze_failed:
        sys.exit(-1)

if __name__ == '__main__':
    _main()
