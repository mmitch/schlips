#!/usr/bin/perl -w
use strict;

# Module einbinden
use Tk;
use Tk::Table;
use Tk::Tiler;
use Tk::Photo;


my $mw = MainWindow->new();
my $image_id = 0;
my $datafile = 'data.dat';

############# Daten einliesen

# erstmal alle Bilder einlesen aus den drei Ordnern
my (@hemden, @anzuege, @schlipse);

sub read_images($)
# Liest alle Bilder aus einem Ordner ein
# 1:   $dir -> Name des Ordners, aus dem gelesen wird
# ret: Array mit den Bildern
{
    my ($dir) = (@_);
    my @files;

    opendir DIR, $dir or die "$!";
    foreach my $file (readdir DIR) {
	next unless $file =~ /\.gif$/;
	my $hash = {
	    NAME => $file,
	    FILE => "$dir$file",
	    ID => 'image'.$image_id++,
	};
	push @files, $hash;
	$mw->Photo($hash->{ID}, -file => '/home/mitch/git/schlips/'.$hash->{FILE});
    }
    closedir DIR or die "$!";

    return @files;
}
@hemden   = read_images('hemden/');
@anzuege  = read_images('anzuege/');
@schlipse = read_images('schlipse/');


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
		DATE => 0,
		KEY => "$anzug->{NAME}:$hemd->{NAME}:$schlips->{NAME}",
	    };
	    push @combinations, $combination;
	}
    }
}


## data IO

sub read_data(@)
{
    my (@combos) = (@_);
    return unless -e $datafile;
    
    my %input;
    open DATA, '<', $datafile or die "$!";
    while (my $line = <DATA>) {
	chomp $line;
	if ($line =~ /(.*:.*:.*):(\d):(\d+)/) {
	    $input{$1} = {
		RESULT => $2,
		DATE   => $3
	    };
	}
    }
    close DATA or die "$!";

    foreach my $combo (@combos) {
	my $key = $combo->{KEY};
	if (exists $input{$key}) {
	    $combo->{DATE} = $input{$key}->{DATE};
	    $combo->{RESULT} = $input{$key}->{RESULT};
	}
    }
}

sub save_data(@)
{
    my (@combos) = (@_);
    open DATA, '>', $datafile or die "$!";
    
    my $time = time();

    foreach my $combo (@combos) {
	if ($combo->{RESULT}) {
	    printf DATA "%s:%s:%s:%d:%d\n",
	    $combo->{ANZUG}->{NAME},
	    $combo->{HEMD}->{NAME},
	    $combo->{SCHLIPS}->{NAME},
	    $combo->{RESULT},
	    $combo->{DATE},
	    ;
	}
    }

    close DATA or die "$!";
}


############# grfx

my $buttons = $mw->Tiler(-columns => 2)->pack(-expand => 1);

$buttons->Button(
	    -text    => 'Quit',
	    -command => sub { 
		exit;
	    },
	    )->pack;

$buttons->Button(
	    -text    => 'Save',
	    -command => sub {
		save_data(@combinations);
		exit;
	    },
	    )->pack;

my $table = $mw->Table(
		    -columns => 5,
		    -rows => @combinations + 1,
		    -fixedrows => 1,
		    )->pack();

sub put_table_headers($$$$$$$) {
    my ($table, $row, @text) = (@_);
    my $col = 0;
    foreach my $text (@text) {
	$table->put($row, $col++, $text);
    }
}

sub new_label($$$) {
    my ($table, $row, $text) = (@_);
    $table->Label(-text => $text);
}

sub new_image($$$) {
    my ($table, $row, $file) = (@_);
    $table->Label(-image => $file->{ID});
}

sub put_table_row($$$) {
    my ($table, $row, $combo) = (@_);
    my $col = 0;
    
    $table->put($row, $col++, new_image($table, $row, $combo->{ANZUG}));
    $table->put($row, $col++, new_image($table, $row, $combo->{HEMD}));
    $table->put($row, $col++, new_image($table, $row, $combo->{SCHLIPS}));
    my $rbframe = $table->Tiler(-columns => 3);
    $rbframe->Radiobutton(-text => 'HUI' ,
			  -value => 1, -variable => \$combo->{RESULT},
			  -command => sub { $combo->{DATE} = time(); }
			  )->pack();
    $rbframe->Radiobutton(-text => 'OK'  ,
			  -value => 2, -variable => \$combo->{RESULT},
			  -command => sub { $combo->{DATE} = time(); }
			  )->pack();
    $rbframe->Radiobutton(-text => 'PFUI',
			  -value => 3, -variable => \$combo->{RESULT},
			  -command => sub { $combo->{DATE} = time(); }
			  )->pack();
    $table->put($row, $col++, $rbframe);
    $table->put($row, $col++, new_label($table, $row, $combo->{DATE} ? scalar localtime($combo->{DATE}) : ''));
}

read_data(@combinations);

my $row = 0;
put_table_headers($table, $row, 'Anzug', 'Hemd', 'Schlips', 'Auswahl', 'Datum');
foreach my $combo (@combinations) {
    put_table_row($table, ++$row, $combo);
}

MainLoop;
