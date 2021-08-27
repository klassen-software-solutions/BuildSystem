#!/usr/bin/env python3

"""Program to generate HTML documentation for a Swift package."""


import json
import logging
import os
import shutil
import subprocess

from typing import Dict, List


def _run(command: str, directory: str = None):
    logging.debug("Running command: %s", command)
    subprocess.run("%s" % command, shell=True, check=True, cwd=directory)

def _get_run(command: str, directory: str = None) -> str:
    logging.debug("Running command: %s", command)
    res = subprocess.run("%s" % command, shell=True, check=True, cwd=directory,
                         stdout=subprocess.PIPE)
    return res.stdout.decode('utf-8').strip()

def _get_products_from(package: Dict) -> List:
    products = []
    for product in package.get('products', []):
        products.append(product['name'])
    logging.debug("Found products: %s", products)
    return products

def _recreate_docs_directory():
    if os.path.isdir('docs'):
        shutil.rmtree('docs')
    os.mkdir('docs')

def _generate_docs_for(target: str, version: str, create_subdirs: bool):
    logging.info("Generating docs for %s", target)
    command = "jazzy"
    command += " --module=%s" % target
    command += " --module-version='%s'" % version
    if create_subdirs:
        command += " --output='docs/%s'" % target
    command += " --use-safe-filenames"
    command += " --documentation='Sources/%s/*.md'" % target
    if os.path.isfile('logo.png'):
        command += " --docset-icon=logo.png"
    author = os.environ.get('AUTHOR', None)
    if author:
        command += " --author='%s'" % author
    author_url = os.environ.get('AUTHOR_URL', None)
    if os.environ.get('AUTHOR_URL'):
        command += " --author_url='%s'" % author_url
    git_url = _get_run("git config --get remote.origin.url")
    if git_url:
        command += " --github_url='%s'" % git_url
    _run(command)

def _write_index(targets: List, version: str):
    logging.info("Writing index file")
    package_name = os.path.basename(os.getcwd())
    with open('docs/index.html', 'w', encoding='utf-8') as outfile:
        outfile.write("<!DOCTYPE html>\n")
        outfile.write("<!-- Auto-generated by kss.license.html_report. Do not edit manually. -->\n")
        outfile.write("<html>\n")
        outfile.write("<head>\n")
        outfile.write("  <link rel='stylesheet' type='text/css' href='%s/css/jazzy.css'/>\n"
                      % targets[0])
        outfile.write("  <link rel='stylesheet' type='text/css' href='%s/css/highlight.css'/>\n"
                      % targets[0])
        outfile.write("  <meta charset='utf-8'>\n")
        outfile.write("</head>\n")
        outfile.write("<body>\n")
        outfile.write("<article class='main-conent'>\n")
        outfile.write("<section class='section'>\n")
        outfile.write("<h1 class='heading'>Index of %s</h1>\n" % package_name)
        outfile.write("<h2>Version %s</h2>\n" % version)
        outfile.write("<h2>Modules</h2>\n")
        outfile.write("<ul>\n")
        for target in targets:
            outfile.write("<li><a href='%s/index.html'>%s</a></li>\n" % (target, target))
        outfile.write("</ul>\n")
        outfile.write("</section>\n")
        outfile.write("</article>\n")
        outfile.write("</body>\n")
        outfile.write("</html>\n")


def _main():
    logging.basicConfig(level=logging.DEBUG)
    package = json.loads(_get_run('swift package dump-package'))
    products = _get_products_from(package)
    is_more_than_one_product = len(products) > 1
    version = _get_run("BuildSystem/common/revision.sh")
    _recreate_docs_directory()
    for product in products:
        _generate_docs_for(product, version, is_more_than_one_product)
    if is_more_than_one_product:
        _write_index(products, version)

if __name__ == '__main__':
    if not os.path.isfile('Package.swift'):
        raise RuntimeError("This does not appear to be a Swift package")
    _main()
