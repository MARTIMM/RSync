# Copying/backing up files using rsync

[![Travis Build Status](https://travis-ci.org/MARTIMM/RSync.svg?branch=master)](https://travis-ci.org/MARTIMM/RSync)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

## Synopsis

```
fcopy config.toml target target-opt1 target-opt2
```
## Description

Rsync can be used from the commandline. The number of options is awsome and because of that difficult to remember. You can use the command from a script started by the cron schedular. This distribution helps to replace those scripts with a command ```fcopy``` which reads one or more toml configuration files to do what you like to do.

## Documentation

See pod documentation in pdf format at

* [fcopy program](https://github.com/MARTIMM/RSync/blob/master/doc/fcopy.pdf)
* [File::RSync module](https://github.com/MARTIMM/RSync/blob/master/doc/RSync.pdf)

* [Release notes](https://github.com/MARTIMM/RSync/blob/master/doc/CHANGES.md)

## Versions of PERL, MOARVM

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## Authors

```
Marcel Timmerman (MARTIMM on github)
```
