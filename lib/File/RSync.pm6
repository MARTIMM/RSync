use v6.c;
use Config::DataLang::Refine;

class File::RSync:auth<https://github.com/MARTIMM> {

  has Str $!config-name;
  has Config::DataLang::Refine $!cdr;

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str :$config-name, Array :$locations ) {
  
    $!cdr .= new( :$config-name, :merge, :$locations);
  }

  #-----------------------------------------------------------------------------
  method start-copy ( Str:D $target, *@options ) {

    my Array $o = self.config-arguments( 'options', |@options);
    my Array $f = self.config-arguments( 'filters', |@options);

  } 

  #-----------------------------------------------------------------------------
  method config-arguments ( *@keys --> Array ) {

    $!cdr.refine-str( @keys, :filter, :str-mode(C-UNIX-OPTS-T2));
  }
}
