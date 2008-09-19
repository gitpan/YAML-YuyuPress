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
		  'YAML' => 0.36,
		  'Template' => 2.14,
		  'HTTP::Server::Simple::CGI' => 0.02,
                  'HTTP::Server::Simple::Static' => 0.01,
		  'Object::props' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'YAML-YuyuPress-*' },
);
