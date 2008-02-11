package YAML::YuyuPress;

use strict;
use warnings;

=head1 NAME

YAML::YuyuPress - Tool for making presentations out of YAML files.


=head1 SYNOPSIS

    use YAML::YuyuPress;

    my $yuyu = new YAML::YuyuPress( { path => $path, #to templates dir
                                      plantilla => 'plantilla.tmpl', #template
                                      contenido => 'contenido.yaml', #slides
                                      staticdir => '/path/to/dir' # static dir
                                      ); 

    $yuyu->run(); # Runs in port 8080 by default

    $yuyu->port(13432); # Set the server port
    my $pid=$yuyu->background(); # or
    $yuyu->run(); # Both inherited from HTML::Server::Simple::CGI

The presentation can then be run from http://localhost:13432/, slides
accessed via http://localhost:13432/?slide=1 or, REST-style,
http://localhost:13432/slide/1, 
index via http://localhost:13432/?indice=1 or 
http://localhost:13432/index

=head1 DESCRIPTION

Program for making presentations out of YAML files. Can be used as a
module or from the C<yuyupress> script 

Inherits from L<YAML::Yuyu> and L<HTTP::Server::Simple::CGI> for serving pages. Use C<yuyuhowto> for a quick presentation of the things that can be done, and how to do them; the presentation itself is contained in the C<bin> directory of the distro under the name C<howto.yaml>. C<yyp-?.yaml>, in the C<t> dir, are examples also of correct presentations.

=head1 METHODS

=cut

our $VERSION="0.07";
our ($CVSVERSION) = ( '$Revision: 1.21 $' =~ /(\d+\.\d+)/ ) ;

use base qw/HTTP::Server::Simple::CGI/;
use HTTP::Server::Simple::Static;
use YAML::Yuyu;

=head2 new

     Creates a new copy of the object

=cut

sub new {
  my $class = shift;
  my ($opts ) = shift;
  my $self = $class->SUPER::new();
  $self->{'staticdir'} = $opts->{'staticdir'};
  my $yuyu = YAML::Yuyu->new(path =>   $opts->{'path'}, 
			     plantilla => $opts->{'plantilla'}, 
			     contenido =>  $opts->{'contenido'} );
  $self->{'_yuyu'} = $yuyu;
  return $self;
}

=head2 handle_request CGI

    Overrides default to return the main presentation page
    ('portada'), index or any of the slides.

=cut


sub handle_request {
  my ( $self, $cgi ) = @_;
  my $path = $cgi->path_info();
  my $yuyu = $self->{'_yuyu'};
  if ( $path ne "/" and (-e $self->{'staticdir'}."/$path") ) { # First of all, static stuff
    $self->serve_static( $cgi, $self->{'staticdir'});
  } else {
    print "HTTP/1.0 200 OK\r\n",
      $cgi->header();
    if ( $path eq '/' ) {
      if ( !$cgi->param() ) {
	print $yuyu->portada;
	return 1;
      }
      if ( $cgi->param('indice') ){
	print $yuyu->indice;
	return 1;
      }
      if ( $cgi->param('slide') ne '' ) {
	print $yuyu->slide( $cgi->param('slide') );
	return 1;
      }
    } else {
      $self->process_REST( $cgi, $path );
    }
  }
}

sub process_REST( ) {
  my $self = shift;
  my $cgi = shift;
  my $path = shift;
  my $yuyu = $self->{'_yuyu'};
  my ($foo, $command, @args) = split("/", $path );
  if ( $command eq 'index' ) {
    print $yuyu->indice;
  } elsif ( $command eq 'slide' ) {
    print $yuyu->slide( $args[0] );
  } else {
    print "HTTP/1.0 404 Not found\r\n";
    print $cgi->start_html('Not found'),
      $cgi->h1("$path Not found"),
	$cgi->end_html;
  }
}


=head1 Copyright

  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2008/02/11 09:41:08 $
  $Header: /home/jmerelo/repos/yuyupress/lib/YAML/YuyuPress.pm,v 1.21 2008/02/11 09:41:08 jmerelo Exp $
  $Author: jmerelo $
  $Revision: 1.21 $

=cut

'Tostodo';
