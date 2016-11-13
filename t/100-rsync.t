use v6.c;
use Test;
use File::RSync;

my File::RSync $rs .= new( :config-name<100-rsync.toml>, :locations(['t']));

#-------------------------------------------------------------------------------
subtest {
  my Array $cargs = [sort @($rs.config-arguments('options'))];
  is $cargs.elems, 4, 'Two options found';
  is $cargs[0], '--dry-run', "1st is $cargs[0]";
  is $cargs[1], '--log', "2nd is $cargs[0]";
  is $cargs[2], '--times', "3rd is $cargs[0]";
  is $cargs[3], '--verbose=2', "4th is $cargs[1]";
#.say for @$cargs;

  $cargs = [sort @($rs.config-arguments(< options fotos>))];
  is $cargs.elems, 4, 'Four options found';
  is $cargs[0], '--destination=/mnt/Backup/Fotos', "1st is $cargs[0]";
  is $cargs[1], '--source=/home/Data/Fotos/', "2nd is $cargs[1]";
  is $cargs[2], '--times', "3rd is $cargs[2]";
  is $cargs[3], '--verbose=2', "4th is $cargs[3]";

  $cargs = $rs.config-arguments(< options fotos remote>);
  is $cargs.elems, 4, 'Four options found';
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
done-testing;
