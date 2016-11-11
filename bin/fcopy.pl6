#!/usr/bin/env perl6

use v6.c;
use File::RSync;
use Config::DataLang::Refine;

# Allow switches after positionals. Pinched from an older panda version. Now
# it is possible to make the sxml file executable with the path of this
# program.
#
my @a = grep( /^ <-[-]>/, @*ARGS);
@*ARGS = (|grep( /^ '-'/, @*ARGS), |@a);

say "A: ", @*ARGS;
#-------------------------------------------------------------------------------
sub MAIN (
  Str $config-file, Str:D :$s,
  Bool :r($run) = False
) {

  my Array $sync-selection = [$s.split(/ [ \s* ',' \s* | \s+ ] /)];
  say "CF: ", $config-file;
  say "SS: ", $sync-selection;
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  say Q:to/EOHELP/;

  Program to help synchronizing files between other locations using rsync.
  The configuration file is in YAML format with entries describing the work.

  Usage:
    fcopy [<options>] <config-file> <sync-selection>

  Where:
    config-file         YAML configuration
    sync-selection      Name of synchronization part in the config file

  Options:
    -h                  This information

    -r                  When ommitted rsync will do a dry run only showing
                        what it would do if -r is used.

  EOHELP
}
