package YAML::Yuyu;

use strict;
use warnings;

use Carp;

=head1 NAME

    YAML::Yuyu - Easily create presentations from a YAML file.

=head1 SYNOPSIS

    my $yuyu = new YAML::Yuyu( path => $path, 
                                 plantilla => 'plantilla.tmpl',
                                 contenido => 'contenido.yaml' ); 

    # From an array of pre-loaded or programatically created slides 
    use YAML qw(LoadFile);
    @slides = LoadFile('yourslides.yaml');
    my $yuyu = new YAML::Yuyu( path => $path, 
                               plantilla => 'plantilla.tmpl',
                               contenido => \@slides  ); 
    
    # From a glob; v. gr. data behind the __END__ marker
    my $yuyu3 = YAML::Yuyu->new( path => $path, 
			         plantilla => $plantilla, 
			         contenido => \*main::DATA );

    my $nth_slide = $yuyu->slide( $n ); 
    my $front_page = $yuyu->portada();
    my $index = $yuyu->index();

=cut

=head1 DESCRIPTION

Derived from L<Object::props>, which is a way cool module, this module
loads a YAML from which it derives a presentation: index, slides, and
so on. It can be used from another module, but you'll usually want to
do it from the scripts for standalone presentations (with its own web
server, no less) or to generate a single or several HTML pages you'll
want to present from somewhere else or upload to a website.

=head1 USAGE

Stand-alone presentation tool. It will use default templates, if none
is indicated 

    bash$ yuyupress presentation.yaml [path-to-templates] [template(s)] 

Generate a web page with the presentation

    bash$ yuyugen presentation.yaml [path-to-templates] [template(s)]

=head1 METHODS

=cut

use YAML qw(LoadFile Load); # Para configuraci�n
use Template;
use Exporter;

our ($CVSVERSION) = ( '$Revision: 1.15 $' =~ /(\d+\.\d+)/ ) ;

#Declaraci�n de propiedades
use Object::props qw( path plantilla contenido );

use Class::constr { 
  init => sub { 
    my $template = Template->new( {INCLUDE_PATH => $_[0]->path } );
    $_[0]->{_template} = $template;
    my @stream;
    if ( ref $_[0]->contenido eq '' ) {
      @stream =  LoadFile( $_[0]->contenido );
    } elsif ( ref $_[0]->contenido eq 'ARRAY' ) {
      @stream = @{$_[0]->contenido};
    } elsif ( ref $_[0]->contenido eq 'GLOB' ) {
      my $glob = $_[0]->contenido;
      my $stream = join('',<$glob>);
      @stream = Load($stream);
    }
    carp "Bad content stream" if !@stream;
    $_[0]->{_portada} = shift @stream;
    $_[0]->{_slides} = \@stream;
    $_[0]->{_doc} = $_[0]->plantilla;
    $_[0]->{_size } = scalar @stream - 1;
  }
};

=head2 portada

C<portada> is the main page; it returns the title and general front matter for the presentation

=cut

sub portada {
  my $self = shift;
  my %data = %{$self->{_portada}->[0]};
  my $contenido=<<EIF;
<h2>$data{'autor'}</h2>

<var>$data{'email'}</var>

<h3>$data{'sitio'}</h3>

<div style='margin:0 auto'><a href='?slide=0'>Comienzo</a></div>
EIF
  my $salida;
  $self->{_template}->process( $self->plantilla, 
			       { titulo => $data{'titulo'},
				 contenido => $contenido }, 
			       \$salida )
    || die $self->{_template}->error(), "\n"; ;
  return $salida;
}


=head2 slide

C<slide>( $slide_number) returns the $slide_number'th slide from the presentation

=cut

sub slide {
  my $self = shift;
  my $nr = shift || 0;
  die if ($nr > $self->{_size}) || ($nr < 0);
  my @slide = @{$self->{_slides}[$nr]};
  my $salida;
  my $titulo = shift @slide;
  my $contenido;
  $contenido = procesa(\@slide  );
  my $navegacion;
  if ( $nr ) {
    $navegacion .= "<a href='?slide=".($nr-1)."'>Anterior</a> ";
  }
  $navegacion .= "<a href='?indice=1'>�ndice</a> ";
  if ( $nr < $self->{_size} ) {
    $navegacion .= "<a href='?slide=".($nr+1)."'>Siguiente</a> ";
  }
  $self->{_template}->process( $self->plantilla, 
			       { titulo => $titulo,
				 contenido => $contenido,
				 navegacion => $navegacion,
				 number => $nr+1
			       }, 
			       \$salida )
    || die $self->{_template}->error(), "\n"; ;
  return $salida;
};

=head2 indice

Returns the presentation index

=cut

sub indice {
  my $self = shift;
  my $i;
  my $contenido="<ol>".
    join("\n", 
	 map("<li><a href='?slide=".$i++."'>".$_->[0]."</a></li>", @{$self->{_slides}} ) )."</ol>";
    
  my $salida;
  $self->{_template}->process( $self->plantilla, 
			       { titulo => 'Indice',
				 contenido => $contenido
			       }, 
			       \$salida )
    || die $self->{_template}->error(), "\n"; ;
  return $salida;
}


sub procesa {
  my $yref = shift;
  my $contenido='';  
  if (@$yref > 0 ) {
    $contenido = "<ul>".procesaArray( $yref )."</ul>";
  } else {
    $contenido = procesaItem( $yref );
  }
  return $contenido;
}

sub procesaArray {
  my $yref = shift;
  my $contenido='';
  for ( @$yref ) {
    $contenido .= procesaItem( $_ )."\n";
  }
  return $contenido;
}

sub procesaHash {
  my $yref = shift;
  my $contenido='<LI><dl>';
  for ( keys %$yref ) {
    $contenido .= "<dt>$_</dt><dd>\n";
    for my $i ( @{$yref->{$_}} ) {
      $contenido .= procesaItem( $i );
    }
    $contenido .="\n</dd>";
  }
  $contenido .= "</dl></li>";
  return $contenido;
}

sub procesaItem {
  my $yref = shift;
  my $contenido='';
  if ( ref $yref eq '' ) {
    $contenido.= "<li>$yref</li>";
  } else {
    my $tag = ref $yref;
    if ( $tag eq 'ARRAY' ) {
      $contenido = procesaArray( $yref );
    } elsif ( $tag eq 'HASH' ) {
      $contenido = procesaHash( $yref );
    } else {
      $contenido = "<$tag";
      for ( keys %$yref ) {
	if ( $_ ne 'body' ) {
	  $contenido .= " $_='$yref->{$_}'";
	}
      }
      if ( $yref->{'body'} ) {
	$contenido.=">".$yref->{'body'}."</$tag>";
      } else {
	$contenido.=">";
      }
    }
  }
  return $contenido;
}

=head1 Copyright

  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2008/02/11 13:03:55 $
  $Header: /home/jmerelo/repos/yuyupress/lib/YAML/Yuyu.pm,v 1.15 2008/02/11 13:03:55 jmerelo Exp $
  $Author: jmerelo $
  $Revision: 1.15 $

=cut


'Sacab�';
