package YAML::Yuyu;

use strict;
use warnings;


=head1 NAME

    YAML::Yuyu - Clase para hacer presentaciones fácilmente a partir de un fichero YAML

=head1 SYNOPSIS

    my $yuyu = new YAML::Yuyu( { path => $path, 
                                 plantilla => 'plantilla.tmpl',
                                 contenido => 'contenido.yaml',
                                 staticdir => `pwd`
                                  } );

=head1 DESCRIPTION

Clase base que contiene la conexión a la base de datos y otros objetos
tales como el generador de claves. 

=head1 USAGE

  bash$ yuyupress presentation.yaml [path-to-templates] [template(s)]

=head1 METHODS

=cut

package YAML::Yuyu;

use YAML qw(LoadFile); #Para configuración
use Template;
use Exporter;

our ($VERSION) = ( '$Revision: 1.6 $' =~ /(\d+\.\d+)/ ) ;

#Declaración de propiedades
use Object::props qw( path plantilla contenido staticdir );

use Class::constr { 
  init => sub { 
    my $template = Template->new( {INCLUDE_PATH => $_[0]->path } );
    $_[0]->{_template} = $template;
    my @stream =  LoadFile( $_[0]->contenido );
    $_[0]->{_portada} = shift @stream;
    $_[0]->{_slides} = \@stream;
    $_[0]->{_doc} = $_[0]->plantilla;
    $_[0]->{_size } = scalar @stream - 1;
  }
};

sub portada {
  my $self = shift;
  my %data = %{$self->{_portada}->[0]};
  my $contenido=<<EIF;
<h2>$data{'autor'}</h2>

<var>$data{'email'}</var>

<h3>$data{'sitio'}</h3>

<div style='margin:0 auto'><a href='?slide=1'>Comienzo</a></div>
EIF
  my $salida;
  $self->{_template}->process( $self->plantilla, 
			       { titulo => $data{'titulo'},
				 contenido => $contenido }, 
			       \$salida )
    || die $self->{_template}->error(), "\n"; ;
  return $salida;
}

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
  $navegacion .= "<a href='?indice=1'>Índice</a> ";
  if ( $nr < $self->{_size} ) {
    $navegacion .= "<a href='?slide=".($nr+1)."'>Siguiente</a> ";
  }
  $self->{_template}->process( $self->plantilla, 
			       { titulo => $titulo,
				 contenido => $contenido,
				 navegacion => $navegacion
			       }, 
			       \$salida )
    || die $self->{_template}->error(), "\n"; ;
  return $salida;
};

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

'Sacabó';
