# $Id: TestShell.pm 34 2011-06-13 04:35:00Z stro $

package TestShell;
use strict;
use warnings;

use CPAN;

# CPAN FrontEnd (default: CPAN::Shell) prints some information to STDOUT, which
# can brake TAP output and mark some tests as out-of-sequence. To avoid this
# problem, myprint and mywarn should be silenced.

$CPAN::FrontEnd = 'TestShell'; 

sub myprint {
    return;
}

sub mywarn {
    return;
}