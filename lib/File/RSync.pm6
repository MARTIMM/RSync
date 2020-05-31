use v6;
use Config::DataLang::Refine;

class X::File::RSync is Exception {
  has Str $.message;
  has Int $.code;
  has Str $.command;

#  submethod BUILD ( Str :$message, Int :$code ) {
#    $!message = $message;
#    $!code = $code;
#  }
}

class File::RSync:auth<https://github.com/MARTIMM> {
#`{{
  enum RSyncErrorCode is export <
    FRS-Success FRS-Syntax FRS-Protocol FRS-IO-files FRS-Action-not-supported
    FRS-Error-client-server FRS-Unable-to-append-log-file FRS-Error-socket
    FRS-Error-file FRS-Error-rsync FRS-Errors-program FRS-Error-IPC
    FRS-SIGUSR1-SIGINT FRS-error-waitpid FRS-Error-memory-buffers
    FRS-Partial-transfer-error FRS-Partial-transfer-vanished-source
    FRS-Error-max-delete-limit FRS-Timeout
  >;
}}

  has Array $!map-errors = [
    'Success',
    'Syntax or usage error',
    'Protocol incompatibility',
    'Errors selecting input/output files, dirs',

    'Requested action not supported: an attempt was made  to  manipu-
late  64-bit files on a platform that cannot support them; or an
option was specified that is supported by the client and not  by
the server.',

    'Error starting client-server protocol',
    'Daemon unable to append to log-file',
    '', '', '',
    'Error in socket I/O',
    'Error in file I/O',
    'Error in rsync protocol data stream',
    'Errors with program diagnostics',
    'Error in IPC code',
    '', '', '', '', '',
    'Received SIGUSR1 or SIGINT',
    'Some error returned by waitpid()',
    'Error allocating core memory buffers',
    'Partial transfer due to error',
    'Partial transfer due to vanished source files',
    'The --max-delete limit stopped deletions',
    '', '', '', '', '',
    'Timeout in data send/receive',
    '', '', '', '', '',
  ];

  has Str $!config-name;
  has Config::DataLang::Refine $!cdr;
  has %!map = e => '--exclude', i => '--include', f => '--filter';

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str :$config-name, Array :$locations ) {

    try {
      if ?$config-name {

        $!cdr .= new( :$config-name, :merge, :$locations);
      }

      else {

        $!cdr .= new( :merge, :$locations);
      }

      CATCH {
        when X::Config::DataLang::Refine {

          die X::File::RSync.new( :message(.message), :code(-1), :command(''))
        }
      }
    }
  }

  #-----------------------------------------------------------------------------
  method run-rsync ( *@keys, Str :$inject = '' ) {

    my $cmd = self.get-command( |@keys, :$inject);
    say ' ';
    my Proc $p = shell $cmd;
    say ' ';

    die X::File::RSync.new(
      :code($p.exitcode),
      :message($!map-errors[$p.exitcode]),
      :command($p.command.join(' '))
    ) if $p.exitcode;
  }

  #-----------------------------------------------------------------------------
  method get-command ( *@keys, Str :$inject = '' --> Str ) {

    my Array $o = self.config-arguments( 'options', |@keys);
    my Array $f = self.config-filter( 'filters', |@keys);
    my Array $t = self.config-targets( 'targets', |@keys);

    ( 'rsync', $inject, @$o, @$f, @$t).join(' ');
  }

  #-----------------------------------------------------------------------------
  method config-arguments ( *@keys --> Array ) {

    $!cdr.refine-str( @keys, :filter, :str-mode(C-UNIX-OPTS-T2));
  }

  #-----------------------------------------------------------------------------
  method config-filter ( *@keys --> Array ) {

    my Array $fargs = [];

    my Hash $f = $!cdr.refine( @keys, :filter);

    my Array $filter-sequence;
    if $f<filter-sequence>:exists and $f<filter-sequence> ~~ Array {
      $filter-sequence = $f<filter-sequence>;
    }

    else {
      $filter-sequence = [ 'i=include', 'e=exclude', 'f=filter'];
    }

    for @$filter-sequence -> $fitem {
      # Entries are like e=foo, f=bar, i=baz for exclude, filter, include resp
      ( my Str $type, my $entry) = $fitem.split('=');
      my Str $option = %!map{$type} // '';
      next unless ?$option;

      if $f{$entry}:exists and $f{$entry} ~~ Array {
        for @($f{$entry}) -> $entry-item {
          $fargs.push: "$option='$entry-item'";
        }
      }
    }

    $fargs;
  }

  #-----------------------------------------------------------------------------
  method config-targets ( *@keys --> Array ) {

    my Array $targs = [];

    my Hash $t = $!cdr.refine( @keys, :filter);
    if $t<sources>:exists and $t<sources> ~~ Array and $t<sources>.elems {
      for @($t<sources>) -> $titem {
        $targs.push: "'$titem'";
      }
    }

    elsif $t<source>:exists and ? $t<source> {
      $targs.push: "'$t<source>'";
    }

    else {
      die X::File::RSync.new(
        :message('No sources defined to copy files from')
        :code(-1),
        :command<->
      );
    }

    if $t<destination>:exists and ? $t<destination> {
      $targs.push: "'$t<destination>'";
    }

    else {
      die X::File::RSync.new(
        :message('No destination defined to copy files to')
        :code(-1),
        :command<->
      );
    }

    $targs;
  }
}
