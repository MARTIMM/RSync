#!/usr/bin/env perl6

use v6.c;
use File::RSync;
use Config::DataLang::Refine;

# Allow switches after positionals. Pinched from an older panda version. Now
# it is possible to make the toml file executable with the path of this
# program.
#
my @a = grep( /^ <-[-]>/, @*ARGS);
@*ARGS = (|grep( /^ '-'/, @*ARGS), |@a);

#say "A: ", @*ARGS;
#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $config-name, *@keys,  Bool :r($run) = False, Str :l($loc-str),
  Bool :d($display) = False;
) {

  try {
    my Array $locations = [($loc-str // '').split(/\s? ',' \s?/)];
    my File::RSync $rs .= new( :$config-name, :$locations);

    if $display {
      say "\nCommand: ",
          $rs.get-command( |@keys, :inject($run ?? '' !! '--dry-run')),
          "\n";
    }

    else {
      $rs.run-rsync( |@keys, :inject($run ?? '' !! '--dry-run'));
    }

    CATCH {
      when X::File::RSync {
        say "\nError running command";
        say 'Error: ', .message;
        say "Error code: ", .code if .code > 0;
        say "Command: ", .command if ?.command;
        say ' ';
      }
    }
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  say Q:to/EOHELP/;

  Program to help synchronizing files between other locations using rsync.
  The configuration file is in YAML format with entries describing the work.

  Usage:
    fcopy [<options>] <config-file> <key> ...

  Where:
    config-file         TOML configuration filename. If not present, fcopy.toml
                        is used. The configuration data will be merged starting
                        with files found in directories from the locations list.
                        Then the hidden file from the home directory e.g.
                        /home/foo/.fcopy.toml. After that the hidden and visual
                        files in the current directory are searched, e.g.
                        .fcopy.toml and fcopy.toml
    key                 Part of tablename in the config file

  Options:
    --help
    -h                  This information

    -l                  Locations where configfiles are to be found. This is a
                        string of directory paths separated by comma's.

    -r                  When ommitted rsync will do a dry run only showing
                        what it would do if -r is used.

  EOHELP
}
