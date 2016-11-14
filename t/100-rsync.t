use v6.c;
use Test;
use File::RSync;

my File::RSync $rs .= new( :config-name<100-rsync.toml>, :locations(['t']));

#-------------------------------------------------------------------------------
subtest {
  my Array $cargs = [sort @($rs.config-arguments('options'))];
  is $cargs.elems, 4, 'Four options found';
  is $cargs[0], '--dry-run', "1st is $cargs[0]";
  is $cargs[1], '--log', "2nd is $cargs[0]";
  is $cargs[2], '--times', "3rd is $cargs[0]";
  is $cargs[3], '--verbose=2', "4th is $cargs[1]";
#.say for @$cargs;

  $cargs = [sort @($rs.config-arguments(< options fotos>))];
  is $cargs.elems, 2, 'Two options found';
  is $cargs[0], '--times', "1st is $cargs[0]";
  is $cargs[1], '--verbose=2', "2nd is $cargs[1]";

  $cargs = $rs.config-arguments(< options fotos remote>);
  is $cargs.elems, 3, 'Three options found';
#.say for @$cargs;

}, 'options';

#-------------------------------------------------------------------------------
subtest {
  my Array $fargs = $rs.config-filter('filters');
  is $fargs.elems, 7, '4 filter options';
  is $fargs[1], "--exclude='old'", "filter 1: $fargs[1]";
  is $fargs[2], "--exclude='Old'", "filter 2: $fargs[2]";
#say $fargs.perl;

  $fargs = $rs.config-filter(< filters fotos>);
  is $fargs[0], "--include='*.pdf'", "filter 0: $fargs[0]";
  is $fargs[1], "--exclude='.precomp'", "filter 1: $fargs[1]";

#say $fargs.perl;
}, 'filters';

#-------------------------------------------------------------------------------
subtest {
  my Array $targs;
  try {
    $targs = $rs.config-targets('targets');
    
    CATCH {
      when X::File::RSync {
        like .message, /:s No sources defined/, .message;
      }
    }
  }

  try {
    $targs = $rs.config-targets(< targets fotos>);
    
    CATCH {
      when X::File::RSync {
        like .message, /:s No destination defined/, .message;
      }
    }
  }

  $targs = $rs.config-targets(< targets fotos remote>);
  is $targs.elems, 2, 'Two targets';
#say $targs.perl;
  is $targs[0], "'/home/Data/Fotos/'", "Src: $targs[0]";
  is $targs[1], "'marcel@192.168.192.253:/home/Data/Fotos/'", "Dst: $targs[1]";

  $targs = $rs.config-targets(< targets fotos dup>);
  is $targs.elems, 3, 'Three targets';
  is $targs[1], "'/home/Bar/Fotos/'", "Src 2: $targs[1]";
  is $targs[2], "'/mnt/Backup/Fotos/'", "Dst: $targs[2]";
}, 'targets';

#-------------------------------------------------------------------------------
subtest {
  my Str $cmd = $rs.get-command(< fotos dup>);
#say $cmd;
  is $cmd, (
       [~] "rsync --dry-run --times --verbose=2 --include='*.pdf' --exclude='.precomp'",
           " --exclude='*.html' '/home/Foo/Fotos/' '/home/Bar/Fotos/'",
           " '/mnt/Backup/Fotos/'"
     ), 'Command ok';

  try {
    $rs.run-rsync(< fotos dup>);

    CATCH {
      default {
        like .message, /:s Partial transfer due to error/, .message;
        is .code, 23, "error code {.code}";
        is .command,
           "rsync --dry-run --times --verbose=2 --include='*.pdf' --exclude='.precomp' --exclude='*.html' '/home/Foo/Fotos/' '/home/Bar/Fotos/' '/mnt/Backup/Fotos/'",
           .command;
           
      }
    }
  }
}, 'command';

#-------------------------------------------------------------------------------
done-testing;
