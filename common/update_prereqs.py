#!/usr/bin/env python3


"""Program to download, build, and install prerequisites."""

import json
import logging
import os
import subprocess
import sys
import urllib.parse
from typing import Dict, List

import requests


def _read_prereqs_file() -> List:
    try:
        with open('Dependancies/prereqs.json', 'r', encoding='utf-8') as file:
            return json.load(file)
    except IOError:
        logging.info("Could not open Dependancies/prereqs.json. Assuming no dependancies.")
        return []

def _change_to_prereqs_directory():
    if not os.path.isdir(".prereqs"):
        logging.debug("Creating .prereqs")
        os.mkdir(".prereqs")
    if not os.path.isdir(PREREQS_DIR):
        logging.debug("Creating %s", PREREQS_DIR)
        os.mkdir(PREREQS_DIR)
    os.chdir(PREREQS_DIR)

def _directory_name_for_prereq(prereq: Dict) -> str:
    dirname = os.path.basename(urllib.parse.urlparse(prereq['git']).path)
    if dirname.endswith('.git'):
        dirname = dirname[:-4]
    return dirname

def _run(command: str, directory: str = None):
    logging.info("running: %s", command)
    subprocess.run(f"{command}", shell=True, check=True, cwd=directory)

def _get_run(command: str):
    res = subprocess.run(f"{command}", shell=True, check=True,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return res.stdout.decode('utf-8').strip()

def _update_repo(dirname: str):
    logging.info("Updating %s", dirname)
    _run('git pull', directory=dirname)
    if os.path.isfile(f"{dirname}/.gitmodules"):
        _run('git submodule update --init --recursive', directory=dirname)

def _clone_repo(url: str, dirname: str, branch: str):
    logging.info("Cloning %s", url)
    _run(f"git clone {url}")
    if branch:
        _run(f"git checkout {branch}", directory=dirname)
    if os.path.isfile(f"{dirname}/.gitmodules"):
        _run('git submodule update --init --recursive', directory=dirname)

def _rebuild_and_install(dirname: str):
    logging.info("Rebuilding %s", dirname)
    _run(f"./configure --prefix={INSTALL_PREFIX}", directory=dirname)
    _run('make', directory=dirname)
    _run('make install', directory=dirname)

def _is_applicable(prereq: Dict) -> bool:
    if 'arch' in prereq:
        if not ARCH in prereq['arch']:
            return False
    return True

def _is_ok(resp):
    return resp.status_code >= 200 and resp.status_code < 300

def _download(url: str, filename: str):
    logging.info("Downloading %s to %s", url, filename)
    resp = requests.get(url)
    if not _is_ok(resp):
        raise RuntimeError(f"Bad response from {url}: {resp.status_code}")
    with open(filename, 'wb') as outfile:
        outfile.write(resp.content)

def _extract(filename: str) -> str:
    dirname = filename
    if dirname.endswith('.tar.gz'):
        dirname = dirname[:-7]
    _run(f"tar xzf {filename}")
    if not os.path.isdir(dirname):
        raise RuntimeError(f"Did not seem to create {dirname}")
    return dirname

def _install_tarball(url: str, filename: str):
    if not filename:
        filename = os.path.basename(urllib.parse.urlparse(url).path)
    _download(url, filename)
    dirname = _extract(filename)
    _rebuild_and_install(dirname)

def _install_pip(package_name: str):
    install_options = ''
    prefix = os.environ.get('KSS_INSTALL_PREFIX', None)
    if prefix:
        install_options = f'--install-option="--prefix={prefix}"'
    _run(f"python3 -m pip install --upgrade {install_options} {package_name}")

def _install_or_update(prereq: Dict):
    if not _is_applicable(prereq):
        logging.info("Skipping %s as not applicable to %s", prereq, ARCH)
        return
    if "git" in prereq:
        logging.info("Found %s", prereq['git'])
        dirname = _directory_name_for_prereq(prereq)
        if os.path.isdir(dirname):
            _update_repo(dirname)
        else:
            _clone_repo(prereq['git'], dirname, prereq.get('branch', None))
        _rebuild_and_install(dirname)
    elif "tarball" in prereq:
        logging.info("Found %s", prereq['tarball'])
        _install_tarball(prereq['tarball'], prereq.get('filename', None))
    elif "pip" in prereq:
        logging.info("Found %s", prereq['pip'])
        _install_pip(prereq['pip'])
    elif "command" in prereq:
        logging.info("Found %s", prereq['command'])
        _run(prereq['command'], directory=CWD)
    else:
        logging.error("Could not determine how to handle %s", prereq)


def _main():
    logging.basicConfig(level=logging.DEBUG)
    logging.debug("ARCH=%s", ARCH)
    logging.debug("PREREQS_DIR=%s", PREREQS_DIR)
    logging.debug("INSTALL_PREFIX=%s", INSTALL_PREFIX)
    prereqs = _read_prereqs_file()
    logging.info("Found %d prerequisites", len(prereqs))
    if len(prereqs) == 0:
        sys.exit(0)
    _change_to_prereqs_directory()
    for prereq in prereqs:
        _install_or_update(prereq)
    os.chdir(CWD)

if __name__ == '__main__':
    _OS = _get_run('uname -s')
    _MACHINE = _get_run('uname -m')
    CWD = os.getcwd()
    ARCH = f"{_OS}-{_MACHINE}"
    PREREQS_DIR = f".prereqs/{ARCH}"
    INSTALL_PREFIX = os.environ.get('KSS_INSTALL_PREFIX', '/opt/kss')
    _main()
