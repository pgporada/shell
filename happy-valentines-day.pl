#!/usr/bin/env perl
use strict;
use warnings;
use Term::Screen;
use Term::ANSIColor qw(:constants);

my $step = 0;
my $var;
my $scr = new Term::Screen;
unless ($scr) { die " Something's wrong \n"; }
$scr->new;
$scr->clrscr();

while (1) {
	print " H    V    D\n";
	print "  a    a    a\n";
	print "   p    l    y\n";
	print "    p    e    !\n";
	print "     y    n\n";
	print "           t\n";
	print "            i\n";
	print "             n\n";
	print "              e\n";
	print "               s\n";
	# Draws the giant box
	$scr->at(0,0)->puts($var);
	for (my $i = 19; $i < 30; $i++) {
	    for (my $j = 0; $j < 7 ; $j++) {
		$scr->at($j,$i)->puts(ON_BRIGHT_YELLOW." ");
	    }  
	}    

	if ($step == 0) { 
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(2,28)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(3,27)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(4,26)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(5,25)->puts(ON_BRIGHT_RED."\|".RESET);

	$scr->at(1,27)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(2,20)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(3,21)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(4,22)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(5,23)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(6,24)->puts(ON_BRIGHT_RED."\|".RESET); 

	$scr->at(1,23)->puts(ON_BRIGHT_RED."\|".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\|".RESET); 

	$step=1; 
	}
	elsif ($step == 1) { 
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(2,28)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(3,27)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(4,26)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(5,25)->puts(ON_BRIGHT_RED."\\".RESET);

	$scr->at(1,27)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(2,20)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(3,21)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(4,22)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(5,23)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(6,24)->puts(ON_BRIGHT_RED."\/".RESET); 

	$scr->at(1,23)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\/".RESET); 

	$step=2; 
	}
	elsif ($step == 2) { 
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(2,28)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(3,27)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(4,26)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(5,25)->puts(ON_BRIGHT_RED."\-".RESET); 

	$scr->at(1,27)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(2,20)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(3,21)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(4,22)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(5,23)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(6,24)->puts(ON_BRIGHT_RED."\-".RESET); 

	$scr->at(1,23)->puts(ON_BRIGHT_RED."\-".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\-".RESET); 

	$step=3; 
	}
	elsif ($step == 3) {
	$scr->at(1,21)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(2,28)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(3,27)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(4,26)->puts(ON_BRIGHT_RED."\/".RESET); 
	$scr->at(5,25)->puts(ON_BRIGHT_RED."\/".RESET); 

	$scr->at(1,27)->puts(ON_BRIGHT_RED."\\".RESET);
	$scr->at(2,20)->puts(ON_BRIGHT_RED."\\".RESET);
	$scr->at(3,21)->puts(ON_BRIGHT_RED."\\".RESET);
	$scr->at(4,22)->puts(ON_BRIGHT_RED."\\".RESET);
	$scr->at(5,23)->puts(ON_BRIGHT_RED."\\".RESET);
	$scr->at(6,24)->puts(ON_BRIGHT_RED."\\".RESET);

	$scr->at(1,23)->puts(ON_BRIGHT_RED."\\".RESET); 
	$scr->at(1,25)->puts(ON_BRIGHT_RED."\/".RESET); 

	$step=0; 
	}

	# Bottom/Top of the heart
	$scr->at(6,24)->puts(ON_BRIGHT_RED."V".RESET); 
	$scr->at(2,24)->puts(ON_BRIGHT_RED."V".RESET); 
	$scr->at(0,22)->puts(ON_BRIGHT_RED."\^".RESET); 
	$scr->at(0,26)->puts(ON_BRIGHT_RED."\^".RESET); 
	# Fills in the heart
	$scr->at(1,22)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(1,26)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,21)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,22)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,23)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,25)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,26)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(2,27)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(3,22)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(3,23)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(3,24)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(3,25)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(3,26)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(4,23)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(4,24)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(4,25)->puts(ON_BRIGHT_MAGENTA.".".RESET);
	$scr->at(5,24)->puts(ON_BRIGHT_MAGENTA.".".RESET);

	# Homes the cursor to 0,0 per documentation
	$scr->new;
	$var = ''; # Resets var to be nothing so we can rebuild the concatenated text block in the inner for loop
	select(undef, undef, undef, 0.40);
}

$scr->clrscr();
