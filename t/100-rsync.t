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
#  .say for @$cargs;

}, 'options';

#-------------------------------------------------------------------------------
subtest {
  my Array $cargs = [sort @($rs.config-arguments('filters'))];
  is $cargs.elems, 3, '3 filter options';
  is $cargs[0], '--exclude=old,Old,*.', "exclude filter: $cargs[0]";
#  .say for @$cargs;

  $cargs = [sort @($rs.config-arguments(< filters fotos>))];
  is $cargs[0], '--exclude=.precomp', "exclude filter: $cargs[0]";

#  .say for @$cargs;
}, 'filters';

#-------------------------------------------------------------------------------
done-testing;
