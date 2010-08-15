#!/usr/bin/perl
use warnings;
use strict;

# benötigte Module einbinden
use Tk;
use GUI;
use Storage;


# Hauptfenster anlegen
my $mw = MainWindow->new();


# Bilder aus den einzelnen Ordnern einlesen
my (@hemden, @anzuege, @schlipse);
@hemden   = Storage::read_images($mw, 'hemden/');
@anzuege  = Storage::read_images($mw, 'anzuege/');
@schlipse = Storage::read_images($mw, 'schlipse/');


# alle Kombinationen erstellen
my $data;
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
	    push @{$data}, $combination;
	}
    }
}


# alte Benutzereingaben dazumischen
Storage::read_user_data($data);


# GUI initialisieren...
GUI::create_gui($mw, $data);


# ...und laufen lassen
MainLoop;
