# BuildSystem
Build system utilities used for all KSS projects

The purpose of this project is to contain the utilities common to all Klassen Software Solutions
build systems.

## Usage

The utilities are divided into language groups based on a directory, with `common` being utilities that
are independant of the source language. Within each language group is a separate README.md that
describes how a project should make use of its utilities.

## Contributing

If you wish to contribute to this project, you need to be familiar with the following development procedures:

* [Git Procedures](https://www.kss.cc/standards-git.html)
* [Python Coding Standards](https://www.kss.cc/standards-python.html)

Note that this project makes the following changes from our standard procedures:

* There are no `development` or `release` branches in this project. Instead you branch your `feature`
branch directly from `master` and when done create a merge request directly back into `master`.
* There are no unit tests in this project.
* You should run `make analyze` before creating your merge request. This will run a static analysis
on all Python and Bash scripts.
