#!/usr/bin/perl

use lib qw( ../lib lib);

use Test::More 'no_plan';
use YAML::Yuyu;

print "Probando en serio\n";

my $path = 'lib/tmpl';
my $plantilla = 'normal.tmpl';
my $contenido = 't/yyp-3.yaml';

my $yuyu = YAML::Yuyu->new( path => $path, 
			    plantilla => $plantilla, 
			    contenido => $contenido );

isa_ok( $yuyu, 'YAML::Yuyu' );

like( $yuyu->portada, qr/Merelo/, 'Frontpage OK');
like( $yuyu->indice, qr/titulo/, 'Index OK');
like( $yuyu->slide(3), qr/img/, 'Slide with images OK' );
like( $yuyu->slide(4), qr/blockquote/, 'Slide with types OK' );
like( $yuyu->slide(5), qr/Editable/, 'Slide with recursion OK' );
