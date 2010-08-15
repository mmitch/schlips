package GUI;
use warnings;
use strict;

# Module importieren
use Tk::Table;
use Storage;



#
# Legt eine Tabellenzeile an
#
sub create_table_row($$$)
{
    my ($table, $row, $combo) = (@_);

    # Bilder erstellen
    my $anzug_image   = $table->Label(-image => $combo->{ANZUG}  ->{ID});
    my $hemd_image    = $table->Label(-image => $combo->{HEMD}   ->{ID});
    my $schlips_image = $table->Label(-image => $combo->{SCHLIPS}->{ID});

    # Radiobuttons erstellen
    my $hui_button  = $table->Radiobutton(-text => '' ,
					  -value => 1,
					  -variable => \$combo->{RESULT},
					  -command => sub { $combo->{DATE} = time(); }
					  );

    my $ok_button   = $table->Radiobutton(-text => '' ,
					  -value => 2,
					  -variable => \$combo->{RESULT},
					  -command => sub { $combo->{DATE} = time(); }
					  );

    my $pfui_button = $table->Radiobutton(-text => '' ,
					  -value => 3,
					  -variable => \$combo->{RESULT},
					  -command => sub { $combo->{DATE} = time(); }
					  );
    
    # Label letzte Änderung erstellen
    my $date_label = $table->Label(-text => $combo->{DATE} ? scalar localtime($combo->{DATE}) : '');

    # Elemente in die Tabellenzeile übernehmen
    $table->put($row, 0, $anzug_image  );
    $table->put($row, 1, $hemd_image   );
    $table->put($row, 2, $schlips_image);
    $table->put($row, 3, $hui_button   );
    $table->put($row, 4, $ok_button    );
    $table->put($row, 5, $pfui_button  );
    $table->put($row, 6, $date_label   );
}



#
# legt die Tabelle oben im Fenster an
#
sub create_table($$)
{
    my ($mw, $data) = (@_);

    # Tabelle anlegen
    my $table = $mw->Table(
			   -columns => 7,
			   -rows => @{$data} + 1,
			   -fixedrows => 1,
			   );
    
    # Überschrift anlegen
    my $col = 0;
    foreach my $text (qw/Anzug Hemd Schlips HUI OK PFUI Datum/) {
	$table->put(0, $col++, $text);
    }

    # Datenzeilen anlegen
    my $row = 0;
    foreach my $triplet (@{$data}) {
	create_table_row($table, ++$row, $triplet);
    }

    # Tabelle ins Hauptfenster packen
    $table->pack(-side => 'top', -fill => 'both');
}



#
# legt die Buttons unten im Fenster an
#
sub create_buttons($$)
{
    my ($mw, $data) = (@_);

    # Rahmen für die Buttons anlegen
    my $button_frame = $mw->Frame();

    # Buttons anlegen
    my $quit_button = $button_frame->Button(
					    -text    => 'Quit',
					    -command => sub { exit; },
					    );

    my $save_button = $button_frame->Button(
					    -text    => 'Save',
					    -command => sub { Storage::save_data($data); exit; },
					    );
    
    # Buttons in den Rahmen packen
    $quit_button->pack(-side => 'right');
    $save_button->pack(-side => 'right');

    # Rahmen ins Hauptfenster packen
    $button_frame->pack(-side => 'bottom', -fill => 'x');
}



#
# baut das Hauptfenster auf
#
sub create_gui($$)
{
    my ($mw, $data) = (@_);

    create_buttons($mw, $data);
    create_table($mw, $data);

}

1;
