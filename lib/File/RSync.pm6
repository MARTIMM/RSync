use v6.c;
use Config::DataLang::Refine;

class File::RSync:auth<https://github.com/MARTIMM> {

  has Str $!config-name;
  has Config::DataLang::Refine $!cdr;
  has %!map = e => '--exclude', i => '--include', f => '--filter';

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str :$config-name, Array :$locations ) {
  
    $!cdr .= new( :$config-name, :merge, :$locations);
  }

  #-----------------------------------------------------------------------------
  method start-copy ( Str:D $target, *@options ) {

    my Array $o = self.config-arguments( 'options', |@options);
    my Array $f = self.config-filter( 'filters', |@options);

    
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
}
