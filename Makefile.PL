use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'YAML::YuyuPress',
    AUTHOR              => 'J. J. Merelo <jjmerelo@gmail.com>',
    VERSION_FROM        => 'lib/YAML/YuyuPress.pm',
    ABSTRACT_FROM       => 'lib/YAML/YuyuPress.pm',
    EXE_FILES           => [ 'bin/yuyupress', 'bin/yuyugen', 'bin/yuyucheck' ],
    PREREQ_PM => {
		  'Test::More' => 0,
		  'YAML' => 0.35,
		  'Template' => 2.14,
		  'HTTP::Server::Simple' => 0.02,
		  'Object::props' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'YAML-YuyuPress-*' },
);
