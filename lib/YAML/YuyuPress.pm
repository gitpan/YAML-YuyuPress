package YAML::Yuyu;

use strict;
use warnings;

=head1 NAME

YAML::YuyuPress - Tool for makine presentacions


=head1 SYNOPSIS

    my $yuyu = new YAML::YuyuPress( { plantilla => 'plantilla.tmpl',
                                          contenido => 'contenido.yaml' } );

=head1 DESCRIPTION

    Program for making presentations out of YAML files. Can be used as a module
    or from the C<yuyupress> script

Hereda de la clase Yuyu y de la HTTP::Server::Simple para servir páginas

=head1 METHODS

=cut

package YAML::YuyuPress;

use YAML qw(LoadFile); #Para configuración
use Template;
use Exporter;

our $VERSION="0.01";
our ($CVSVERSION) = ( '$Revision: 1.2 $' =~ /(\d+\.\d+)/ ) ;

use base qw/YAML::Yuyu HTTP::Server::Simple/;

=head2 handle_request CGI

This routine is called whenever your server gets a request it can handle. It's called with a CGI object that's been pre-initialized.  You want to override this method in your subclass


=cut


sub handle_request {
  my ( $self, $cgi ) = @_;
  if ( scalar  @{$cgi->{'.parameters'}} == 0 ) {
#    print "Defecto";
    print $self->portada;
  } elsif ( $cgi->{indice} ) {
#    print "Indice",
    print $self->indice;
  } elsif ( defined $cgi->{slide}->[0] ) {
#    print "Slide";
    print $self->slide( $cgi->{slide}->[0] );
  } else {
    print "No me entero", join( "-", @{$cgi->{'.parameters'}}),
      "parameters ", scalar  @{$cgi->{'.parameters'}};
  }
}



'Tostodo';
