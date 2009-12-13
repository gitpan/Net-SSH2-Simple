#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::SSH2::Simple' ) || print "Bail out!
";
}

diag( "Testing Net::SSH2::Simple $Net::SSH2::Simple::VERSION, Perl $], $^X" );
