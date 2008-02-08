#!/usr/bin/perl

use Test::More;
use lib qw(../lib lib);

BEGIN {
    if (eval { require LWP::Simple }) {
	plan tests => 4;
    } else {
	Test::More->import(skip_all =>"LWP::Simple not installed: $@");
    }
}

use YAML::YuyuPress;

print "Testing seriously\n";

my $path = 'lib/tmpl';
my $plantilla = 'normal.tmpl';
my $contenido;
if ( -e 't/yyp-3.yaml' ) {
  $contenido = 't/yyp-3.yaml';
} else {
  $contenido = 'yyp-3.yaml'; # Just in case we're testing in-dir
}

my $yuyu = YAML::YuyuPress->new( path => $path, 
				 plantilla => $plantilla, 
				 contenido => $contenido );
$yuyu->port(13432);
is($yuyu->port(),13432,"Constructor set port correctly");
my $pid=$yuyu->background();
like($pid, qr/^\d+$/, "pid $pid exists and is numeric");
my $content=LWP::Simple::get("http://localhost:13432");
like($content,qr/YAML/,"Returns a page");
is(kill(9,$pid),1,'Signaled 1 process successfully');

