use v6;
use Test;
use File::RSync;

#-------------------------------------------------------------------------------
# setup environment
my Str $sd = 't/src-dir';
mkdir $sd, 0o777 unless $sd.IO.e;
my Str $text-data = 'abcdef';
"$sd/f1.txt".IO.spurt($text-data);
"$sd/f2.txt".IO.spurt($text-data);
"$sd/f3.txt".IO.spurt($text-data);

#-------------------------------------------------------------------------------
my File::RSync $rs .= new( :config-name<100-rsync.toml>, :locations(['t']));

#-------------------------------------------------------------------------------
subtest 'options', {
  my Array $cargs = [sort @($rs.config-arguments('options'))];
  is $cargs.elems, 4, '4 options found';
  is $cargs[0], '--dry-run', "1st is $cargs[0]";
  is $cargs[1], '--log', "2nd is $cargs[0]";
  is $cargs[2], '--times', "3rd is $cargs[0]";
  is $cargs[3], '--verbose=2', "4th is $cargs[1]";
#.say for @$cargs;

  $cargs = [sort @($rs.config-arguments(< options src >))];
  is $cargs.elems, 3, '3 options found';
  is $cargs[0], '--dry-run', "1st is $cargs[0]";
  is $cargs[1], '--times', "2nd is $cargs[1]";
  is $cargs[2], '--verbose=2', "3rd is $cargs[2]";

  $cargs = $rs.config-arguments(< options src remote>);
  is $cargs.elems, 4, '4 options found';
#.say for @$cargs;

};

#-------------------------------------------------------------------------------
subtest 'filters', {
  my Array $fargs = $rs.config-filter('filters');
  is $fargs.elems, 7, '4 filter options';
  is $fargs[1], "--exclude='old'", "filter 1: $fargs[1]";
  is $fargs[2], "--exclude='Old'", "filter 2: $fargs[2]";
#say $fargs.perl;

  $fargs = $rs.config-filter(< filters src>);
  is $fargs[0], "--include='*.pdf'", "filter 0: $fargs[0]";
  is $fargs[1], "--exclude='.precomp'", "filter 1: $fargs[1]";

#say $fargs.perl;
};

#-------------------------------------------------------------------------------
subtest 'targets', {
  my Array $targs;
  throws-like { $targs = $rs.config-targets('targets'); },
      Exception, 'No sources defined',
      :message(/:s No sources defined/);

  throws-like { $targs = $rs.config-targets(< targets src>); },
      Exception, 'No destination defined',
      :message(/:s No destination defined/);

  $targs = $rs.config-targets(< targets src remote>);
  is $targs.elems, 2, 'Two targets';
#say $targs.perl;
  is $targs[0], "'t/src-dir'", "Src: $targs[0]";
  is $targs[1], "'marcel@192.168.192.253:/tmp/dest-dir'", "Dst: $targs[1]";

  $targs = $rs.config-targets(< targets src dup>);
  is $targs.elems, 2, 'Two targets';
  is $targs[0], "'t/src-dir'", "Src 2: $targs[0]";
  is $targs[1], "'t/dest-dir'", "Dst: $targs[1]";
};

#-------------------------------------------------------------------------------
subtest 'command', {
  my Str $cmd = $rs.get-command(< src dup >);
#  note $cmd;

  like $cmd, /"--verbose=2"/, 'Has verbose';
  like $cmd, /"--include='*.pdf'"/, 'Has include pdf';
  $rs.run-rsync( < src dup >, :inject<-r>);

  ok 't/dest-dir/src-dir'.IO.d, 'dir copied';
  ok 't/dest-dir/src-dir/f3.txt'.IO.e, 'files copied';
};

#-------------------------------------------------------------------------------
# cleanup
unlink "$sd/f1.txt";
unlink "$sd/f2.txt";
unlink "$sd/f3.txt";
rmdir $sd;

$sd = 't/dest-dir/src-dir';
unlink "$sd/f1.txt";
unlink "$sd/f2.txt";
unlink "$sd/f3.txt";
rmdir $sd;
rmdir 't/dest-dir';

#-------------------------------------------------------------------------------
done-testing;
