package Storage;
use warnings;
use strict;

# benötigte Module einbinden
use Tk::Photo;
use Tk::JPEG;


my $datafile = 'data.dat';  # Dateiname für Benutzereingaben
my $image_id = 0;           # eindeutiger Zähler für die Bilder



#
# Liest die vorherigen Benutzereingaben
#
sub read_user_data($)
{
    my $data = shift;

    # zurück, wenn es die Datei nicht gibt
    return unless -e $datafile;
    
    # alle alten Eingaben lesen und in %input speichern
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

    # alle Daten im Speicher durchgehen und Treffer übernehmen
    foreach my $combo (@{$data}) {
	my $key = $combo->{KEY};
	if (exists $input{$key}) {
	    $combo->{DATE} = $input{$key}->{DATE};
	    $combo->{RESULT} = $input{$key}->{RESULT};
	}
    }
}



#
# Speichert die Benutzereingaben
#
sub save_user_data($)
{
    my $data = shift;

    open DATA, '>', $datafile or die "$!";
    
    my $time = time();

    foreach my $combo (@{$data}) {
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



#
# Liest alle Bilder aus einem Ordner ein und gibt sie als Array zurück
#
sub read_images($$)
{
    my ($mw, $dir) = (@_);

    my @files;

    opendir DIR, $dir or die "$!";
    foreach my $file (readdir DIR) {
	next unless $file =~ /\.jpg$/;
	my $hash = {
	    NAME => $file,
	    FILE => "$dir$file",
	    ID => 'image'.$image_id++,
	};
	push @files, $hash;
	# doof, dass wir hier beim Datenzugriff die GUI ($mw) kennen müssen!
	$mw->Photo($hash->{ID}, -file => $hash->{FILE}, -format => 'jpeg');
    }
    closedir DIR or die "$!";

    return @files;
}

1;
