use Test::More tests => 2;

use lib "lib";

BEGIN {
use_ok( 'YAML::YuyuPress' );
use_ok( 'YAML::Yuyu' );
}

diag( "Testing YAML::YuyuPress $YAML::YuyuPress::VERSION" );
