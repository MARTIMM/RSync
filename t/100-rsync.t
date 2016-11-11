use v6.c;
use Test;
use File::RSync;

my File::RSync $rs .= new( :config-name<100-rsync.toml>, :locations(['t']));

my Array $cargs = $rs.config-arguments('options');
is $cargs.elems, 2, 'Two options found';
is $cargs[0], '--times', "First is $cargs[0]";
is $cargs[1], '--verbose=2', "Second is $cargs[1]";


$cargs = $rs.config-arguments(< options fotos>);
is $cargs.elems, 5, 'Two options found';
is $cargs[0], '--nolog', "First is $cargs[0]";
is $cargs[1], '--destination=/mnt/Backup/Fotos', "Second is $cargs[1]";
is $cargs[2], '--source=/home/Data/Fotos/', "First is $cargs[2]";
is $cargs[3], '--times', "First is $cargs[3]";
is $cargs[4], '--verbose=2', "Second is $cargs[4]";

$cargs = $rs.config-arguments(< options fotos remote>);
is $cargs.elems, 5, 'Two options found';
.say for @$cargs;

done-testing;
