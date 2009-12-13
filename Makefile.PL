use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::SSH2::Simple',
    AUTHOR              => q{remi <remi@chez.com>},
    VERSION_FROM        => 'lib/Net/SSH2/Simple.pm',
    ABSTRACT_FROM       => 'lib/Net/SSH2/Simple.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-SSH2-Simple-*' },
);
