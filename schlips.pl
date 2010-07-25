#!/usr/bin/perl -w
use strict;

use Tk;
use Tk::Table;


############# data

my @hemden   = qw(rot schwarz weiß);
my @anzuege  = qw(schwarz grau);
my @schlipse = qw(rot blau grün);

my @combinations;

## permute
foreach my $anzug (@anzuege) {
    foreach my $hemd (@hemden) {
	foreach my $schlips (@schlipse) {
	    my $combination = {
		ANZUG => $anzug,
		HEMD => $hemd,
		SCHLIPS => $schlips,
		RESULT => 0,
		DATE => '',
	    };
	    push @combinations, $combination;
	}
    }
}


############# grfx 

my $mw = MainWindow->new();

$mw->Label(-text => 'Hello, world!')->pack;
my $table = $mw->Table(
		    -columns => 5,
		    -rows => @combinations + 1,
#		    -scrollbars => anchor,
		    -fixedrows => 1,
		    )->pack;

sub put_table_row($$$$$$$) {
    my ($table, $row, @text) = (@_);
    my $col = 0;
    foreach my $text (@text) {
	$table->put($row, $col++, $text);
    }
}

my $row = 0;
put_table_row($table, $row, 'Anzug', 'Hemd', 'Schlips', 'Auswahl', 'Datum');
foreach my $combo (@combinations) {
    put_table_row($table, ++$row,
		  $combo->{ANZUG},
		  $combo->{HEMD},
		  $combo->{SCHLIPS},
		  $combo->{RESULT},
		  $combo->{DATE}
		  );
}

$mw->Button(
	    -text    => 'Quit',
	    -command => sub { exit },
	    )->pack;

MainLoop;
