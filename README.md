# Copying/backing up files using rsync

[![Travis Build Status](https://travis-ci.org/MARTIMM/RSync.svg?branch=master)](https://travis-ci.org/MARTIMM/RSync)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

## Synopsis

An example TOML configuration might be
```
# Basic setup
[filters]
  filter-sequence       = [ 'i=include', 'e=exclude', 'f=filter', 'e=ex2']
  exclude               = [ 'old', 'Old', '*~']
  ex2                   = [ '*.html']
  include               = [ '*.pdf' ]
  filter                = [ '- Test/', '- test' ]

[options]
  dry-run               = true
  verbose               = 2
  times                 = true
  log                   = true

# My fotos
[targets.fotos]
  source                = '/home/Data/Fotos/'

[options.fotos]
  log                   = false
  dry-run               = false

[filters.fotos]
  exclude               = [ '.precomp']
  filter                = [ ]

# On remote machine
[options.fotos.remote]
  log                   = true

[targets.fotos.remote]
  destination           = 'marcel@192.168.192.253:/home/Data/Fotos/'

# Duplicates
[options.fotos.dup]
  dry-run               = true

[targets.fotos.dup]
  sources               = [ '/home/Foo/Fotos/', '/home/Bar/Fotos/' ]
  destination           = '/mnt/Backup/Fotos/'
```
The following command;
```
fcopy config.toml fotos dup
```
will result in the rsync command and run
```
rsync --dry-run --times --verbose=2 --include='*.pdf' --exclude='.precomp' --exclude='*.html' '/home/Foo/Fotos/' '/home/Bar/Fotos/' '/mnt/Backup/Fotos/'
```

## Description

Rsync can be used from the commandline. The number of options is awsome and because of that difficult to remember. You can use the command from a script started by the cron schedular but, because there are so many options, it is difficult to remember what it does when you look at the command again. This distribution helps to replace those scripts with a command ```fcopy``` which merges one or more toml configuration files and construct the rsync command for you. The TOML file is easy to read and therefore easy to maintain.

## Documentation

See pod documentation in pdf format at

* [fcopy program](https://github.com/MARTIMM/RSync/blob/master/doc/fcopy.pdf)
* [File::RSync module](https://github.com/MARTIMM/RSync/blob/master/doc/RSync.pdf)

* [Release notes](https://github.com/MARTIMM/RSync/blob/master/doc/CHANGES.md)

## Versions of PERL, MOARVM

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## Changes
* 2020-05-31 0.3.2
  * make test changes after some errors.

## Authors

```
Marcel Timmerman (MARTIMM on github)
```
