#!/usr/bin/perl

use lib qw( ../lib lib);

use Test::More 'no_plan';
use YAML::Yuyu;
use YAML qw(LoadFile);

print "This is not a drill\n";

my $path;
my $plantilla = 'normal.tmpl';
if ( -e "$path/$plantilla" ) {
  $path = 'lib/tmpl';
} else {
  $path = '../lib/tmpl'; # Just in case we're testing in-dir
}

my $contenido;
if ( -e 't/yyp-3.yaml' ) {
  $contenido = 't/yyp-3.yaml';
} else {
  $contenido = 'yyp-3.yaml'; # Just in case we're testing in-dir
}

my $yuyu = YAML::Yuyu->new( path => $path, 
			    plantilla => $plantilla, 
			    contenido => $contenido );

isa_ok( $yuyu, 'YAML::Yuyu' );

like( $yuyu->portada, qr/Merelo/, 'Frontpage OK');
like( $yuyu->indice, qr/titulo/, 'Index OK');
like( $yuyu->slide(3), qr/img/, 'Slide with images OK' );
like( $yuyu->slide(4), qr/blockquote/, 'Slide with types OK' );
like( $yuyu->slide(5), qr/Editable/, 'Slide with recursion OK' );

my @slides = LoadFile( $contenido );
my $yuyu2 = YAML::Yuyu->new( path => $path, 
			     plantilla => $plantilla, 
			     contenido => \@slides );
like( $yuyu2->indice, qr/titulo/, 'Index OK creating from array ref');

my $yuyu3 = YAML::Yuyu->new( path => $path, 
			     plantilla => $plantilla, 
			     contenido => \*main::DATA );
like( $yuyu3->slide(1), qr/real/, 'Slides OK creating from GLOB');

__END__
---  
- Title
- First point
- Second pint of beer

--- 
- This is another title
- More stuff goes here

---
- This is for real
- !perl/$img 
  src: imagen.jpg
- There is an image here
