package Net::SSH2::Simple;

use warnings;
use strict;

use base qw/Net::SSH2/;

=head1 NAME

Net::SSH2::Simple - Simpler interface to Net::SSH2

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Net::SSH2::Simple provide limited but simpler interface to Net::SSH2.

Perhaps a little code snippet.

    use Net::SSH2::Simple;

    my $ssh2 = Net::SSH2::Simple->new();
    ...
    {
    	my ($stdout,$stderr, $exitcode) = $ssh2->cmd( "uname -sr" ) or die "cannot execute uname: $self->error";
    	if ($exitcode == 0) {
	    	print $stdout if $stdout;
	    	print $stderr if $stderr;
    	} else {
	    	print $stderr if $stderr;
	    	die "uname failed with exit code $exitcode";
    	}	
	}
	...	
	{
    	my ($stdout,$stderr, $exitcode) = $ssh2->cmd( "ls -latr", 'timeout' => 5_000, 'bufsize' => 4_096 );
	}
	
=head1 EXPORT

sub cmd

head1 CAVEAT

cmd: only one command line can be executed over this channel. No "ls -l;whoami" combo. Use ssh->shell instead	

head1 WORKAROUND

cmd: use parenthesis for cmd combo

	...
	{
		my ($stdout,$stderr,$exit)=$ssh->cmd("(echo \"workaround\" ; nice ps auxw)") or die "Cannot exec combo: $self->error";
	}

=head1 SUBROUTINES/METHODS

=head2 new

=cut

################
sub new { # needed to export our sub { ... }
	my $class=shift;
	my $this = $class->SUPER::new(@_);	
	bless( $this, $class);
	return $this;	
}

=head2 cmd

=cut

sub cmd {
# Exec command line $cmd using SSH2
# syntax: my ($stdout,$stderr, $exitcode) = $ssh2->cmd( command [, 'timeout' => integer] [, 'bufsize => integer ]);
	my $self=shift;
# params:	
	my $cmd=shift;				#command line string. E.g. "ls -latr"
	my %args=(timeout=>1_000,	#polling timeout
			  bufsize=>10_240,	#read buffer size when polling
			  @_);	
# Returns: stdout string or undef, stderr string or undef, exitcode or undef. Set $self->error if needed
	
	$self->blocking(1); #needed for ssh->channel
	my $chan=$self->channel() or $self->error(0, "cannot open SSH2 channel"), return undef; # create SSH2 channel

	# exec $cmd (caveat: only one command line can be executed over this channel. No "ls -l;whoami" combo. Use ssh->shell instead.
	$chan->exec($cmd) or $self->error(0, "cannot exec '$cmd' over SSH2 channel"), return undef;
	
	# defin polling context: will poll stdout (in) and stderr (ext)
	my @poll = ( { handle => $chan, events => ['in','ext'] } );
	
	my %std=();			# hash of strings. store stdout/stderr results
	$self->blocking( 0 ); # needed for channel->poll
	while(!$chan->eof) { # there still something to read from channel
    	$self->poll( $args{'timeout'}, [ @poll ] ); # if any event, it will be store into $poll;

    	my( $n, $buf );	# number of bytes read (n) into buffer (buf)
    	foreach my $poll ( @poll ) { # for each event
        	foreach my $ev ( qw( in ext ) ) { #for each stdout/stderr
            	next unless $poll->{revents}{$ev};

            	#there are something to read here, into $std{$ev} hash
            	if( $n = $chan->read( $buf, $args{'bufsize'}, $ev eq 'ext' ) ) { #got n byte into buf for stdout ($ev='in') or stderr ($ev='ext')
               		$std{$ev}.=$buf;
            	}
        	} #done foreach
    	}
	}
	$chan->wait_closed(); #not really needed but cleaner
	
    my $exit=$chan->exit_status();
    $chan->close(); #not really needed but cleaner
    
    $self->blocking(1); # set it back for sanity (future calls)

    return ($std{'in'},$std{'ext'},$exit); 
}

############# probably not needed
#sub DESTROY { return $_[0]->SUPER::DESTROY() } #really needed ?

=head1 AUTHOR

remi, C<< <remi at chez.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-ssh2-simple at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-SSH2-Simple>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::SSH2::Simple


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-SSH2-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-SSH2-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-SSH2-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-SSH2-Simple/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2009 remi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Net::SSH2::Simple
