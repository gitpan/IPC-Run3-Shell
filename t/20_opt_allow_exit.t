#!/usr/bin/env perl
use warnings;
use strict;

# Tests for the Perl module IPC::Run3::Shell
# 
# Copyright (c) 2014 Hauke Daempfling (haukex@zero-g.net).
# 
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl 5 itself.
# 
# For more information see the "Perl Artistic License",
# which should have been distributed with your copy of Perl.
# Try the command "perldoc perlartistic" or see
# http://perldoc.perl.org/perlartistic.html .

use FindBin ();
use lib $FindBin::Bin;
use IPC_Run3_Shell_Testlib;

use Test::More tests => 20;
use Test::Fatal 'exception';

use IPC::Run3::Shell;
use warnings FATAL=>'IPC::Run3::Shell';

my $s = IPC::Run3::Shell->new();

$s->perl('-e',';'); is $?, 0, 'allow_exit 1';
$s->perl({allow_exit=>[0,123]},'-e','exit'); is $?, 0, 'allow_exit 2';
$s->perl({allow_exit=>[0,123]},'-e','exit 123'); is $?, 123<<8, 'allow_exit 3';
like exception { $s->perl({allow_exit=>[0,123]},'-e','exit 124'); 1 },
	qr/exit (status|value) 124\b/, "allow_exit 4";
$s->perl({allow_exit=>[23]},'-e','exit 23'); is $?, 23<<8, 'allow_exit 5';
$s->perl({allow_exit=>23},'-e','exit 23'); is $?, 23<<8, 'allow_exit 6';
like exception { $s->perl({allow_exit=>[123]},'-e','$x=1'); 1 },
	qr/exit (status|value) 0\b/, 'allow_exit 7';

$s->perl({allow_exit=>'ANY'},'-e','exit'); is $?, 0, 'allow_exit any 1';
$s->perl({allow_exit=>'ANY'},'-e','exit 1'); is $?, 1<<8, 'allow_exit any 2';
$s->perl({allow_exit=>'ANY'},'-e','exit 23'); is $?, 23<<8, 'allow_exit any 3';
$s->perl({allow_exit=>'ANY'},'-e','exit 123'); is $?, 123<<8, 'allow_exit any 4';

my @w1 = warns {
		use warnings NONFATAL=>'IPC::Run3::Shell';
		$s->perl({allow_exit=>[]},'-e','exit');
		is $?, 0, 'allow_exit err 1';
	};
is @w1, 2, "warnings on empty allow_exit 1";
like $w1[0], qr/allow_exit is empty/, "warnings on empty allow_exit 2";
like $w1[1], qr/exit (status|value) 0\b/, "warnings on empty allow_exit 3";
like exception { $s->perl({allow_exit=>'any'},'-e','exit 5'); 1 },
	qr/allow_exit.+isn't numeric/, 'allow_exit err 2';
like exception { $s->perl({allow_exit=>[0,'A',123]},'-e','exit 5'); 1 },
	qr/allow_exit.+isn't numeric/, 'allow_exit err 3';
like exception { $s->perl({allow_exit=>[0,undef,123]},'-e','exit 5'); 1 },
	qr/allow_exit.+isn't numeric/, 'allow_exit err 4';

$s->perl({allow_exit=>[123]},{allow_exit=>undef},'-e','exit');
	is $?, 0, 'allow_exit unset 1';
like exception { $s->perl({allow_exit=>[123]},{allow_exit=>undef},'-e','exit 123'); 1 },
	qr/exit (status|value) 123\b/, 'allow_exit unset 2';

