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

    my Array $cargs = self.config-arguments( 'options', |@options);

  } 

  #-----------------------------------------------------------------------------
  method config-arguments ( *@options --> Array ) {

    $!cdr.refine-str( @options, :str-mode(C-UNIX-OPTS-T2));
  }
}
