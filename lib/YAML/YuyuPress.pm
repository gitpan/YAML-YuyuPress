package YAML::YuyuPress;

use strict;
use warnings;

=head1 NAME

YAML::YuyuPress - Tool for making presentacions out of YAML files.


=head1 SYNOPSIS

    my $yuyu = new YAML::YuyuPress( { path => $path, 
                                      plantilla => 'plantilla.tmpl', 
                                      contenido => 'contenido.yaml' } );

    $yuyu->port(13432); # Set the server port
    my $pid=$yuyu->background(); # or
    $yuyu->run(); # Both inherited from HTML::Server::Simple::CGI

=head1 DESCRIPTION

    Program for making presentations out of YAML files. Can be used as a module
    or from the C<yuyupress> script

    Inherits from C<YAML::Yuyu> and C<HTTP::Server::Simple::CGI> for serving pages

=head1 METHODS

=cut

use HTTP::Server::Simple::CGI;

our $VERSION="0.05_1";
our ($CVSVERSION) = ( '$Revision: 1.13 $' =~ /(\d+\.\d+)/ ) ;

use base qw/YAML::Yuyu HTTP::Server::Simple::CGI/;
#use HTTP::Server::Simple::CGI;
#our @ISA = qw(HTTP::Server::Simple::CGI);

=head2 handle_request CGI

    Overrides default to return the main page ('portada'), index or any of the slides.

=cut


sub handle_request {
  my ( $self, $cgi ) = @_;
  my $path = $cgi->path_info();
  print "HTTP/1.0 200 OK\r\n",
    $cgi->header();
  if ( $path eq '/' ) {
    if ( !$cgi->param() ) {
      print $self->portada;
      return 1;
    }
    if ( $cgi->param('indice') ){
      print $self->indice;
      return 1;
    }
    if ( $cgi->param('slide') ne '' ) {
      print $self->slide( $cgi->param('slide') );
      return 1;
    }
  } else {
    print "HTTP/1.0 404 Not found\r\n";
    print $cgi->start_html('Not found'),
      $cgi->h1('Not found'),
	$cgi->end_html;
  }
}
     
'Tostodo';
