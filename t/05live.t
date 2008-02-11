#!/usr/bin/perl

use Test::More;
use lib qw(../lib lib);

BEGIN {
    if (eval { require LWP::Simple }) {
	plan tests => 7;
    } else {
	Test::More->import(skip_all =>"LWP::Simple not installed: $@");
    }
}

use YAML::YuyuPress;

print "Testing seriously\n";

my $path= 'lib/tmpl';;
my $plantilla = 'normal.tmpl';
if ( ! -e "$path/$plantilla" ) {
  $path = '../lib/tmpl'; # Just in case we're testing in-dir
}
print "Using $path for template\n";
my $contenido;
if ( -e 't/yyp-3.yaml' ) {
  $contenido = 't/yyp-3.yaml';
} else {
  $contenido = 'yyp-3.yaml'; # Just in case we're testing in-dir
}

my $yuyu = YAML::YuyuPress->new( { path => $path, 
				   plantilla => $plantilla, 
				   contenido => $contenido,
				   staticdir => $path } );
$yuyu->port(13432);
is($yuyu->port(),13432,"Constructor set port correctly");
my $pid=$yuyu->background();
like($pid, qr/^\d+$/, "pid $pid exists and is numeric");
my $content=LWP::Simple::get("http://localhost:13432/");
like($content,qr/YAML/,"Returns a page");
$content = LWP::Simple::get("http://localhost:13432/e.gif");
isnt( $content, '', "Returns static OK" );
$content = LWP::Simple::get("http://localhost:13432/slide/1");
like($content,qr/cosas/,"Returns a page via REST");
$content = LWP::Simple::get("http://localhost:13432/index");
like($content,qr/guay/,"Returns index via REST");
is(kill(9,$pid),1,'Signaled 1 process successfully');
