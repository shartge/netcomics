#-*-mode: Perl; tab-width: 4 -*-
#---------------------------------------------------------------------
# This module creates the interface for Comic Page.
#---------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#---------------------------------------------------------------------
package Netcomics::GtkComics;

BEGIN {
	our @ISA = qw(Exporter);
	our $VERSION = 0.0.1;
	use Gnome;
	use Exporter;
}

sub create_main_window {
	my ($style, $pixmap, $mask, $window, $pixmapwid);

	my $that  = shift;
	my $class = ref($that) || $that;
    
	my ($forms, $widgets, $data, $work, $info);

    #
    # Construct a GtkWindow 'window_comic_page'
    $widgets->{'window_comic_page'} = new Gtk::Window;
    $widgets->{'window_comic_page'}->set_title('Comic Page' );
    $widgets->{'window_comic_page'}->position('none' );
    $widgets->{'window_comic_page'}->set_policy(0, 1, 0 );
    $widgets->{'window_comic_page'}->set_modal(0 );
    $widgets->{'window_comic_page'}->set_default_size(0, 675 );
    $widgets->{'window_comic_page'}->set_wmclass('Comics Page', 'comic_page_main_window' );
    $widgets->{'window_comic_page'}->realize;
    $forms->{'window_comic_page'}{'tooltips'} = new Gtk::Tooltips;
    $forms->{'window_comic_page'}{'accelgroup'} = new Gtk::AccelGroup;
    $forms->{'window_comic_page'}{'accelgroup'}->attach($widgets->{'window_comic_page'} );
    $forms->{'window_comic_page'}{'window_comic_page'} = $widgets->{'window_comic_page'};
	#
	# Construct a GtkVBox 'vbox1'
	$widgets->{'vbox1'} = new Gtk::VBox(0, 0 );
	$forms->{'window_comic_page'}{'window_comic_page'}->add($widgets->{'vbox1'} );
	$widgets->{'vbox1'}->show;
	$forms->{'window_comic_page'}{'vbox1'} = $widgets->{'vbox1'};
	    #
	    # Construct a GtkMenuBar 'menubar1'
	    $widgets->{'menubar1'} = new Gtk::MenuBar;
	    $widgets->{'menubar1'}->set_shadow_type('out' );
	    $forms->{'window_comic_page'}{'vbox1'}->add($widgets->{'menubar1'} );
	    $widgets->{'menubar1'}->show;
	    $forms->{'window_comic_page'}{'menubar1'} = $widgets->{'menubar1'};
		#
		# Construct a GtkMenuItem 'file1'
		$widgets->{'file1'} = new Gtk::MenuItem('_File');
		$forms->{'window_comic_page'}{'menubar1'}->append($widgets->{'file1'} );
		$widgets->{'file1'}->show;
		$forms->{'window_comic_page'}{'file1'} = $widgets->{'file1'};
		$forms->{'window_comic_page'}{'file1-key'} = $forms->{'window_comic_page'}{'file1'}->child->parse_uline('_File');
		$forms->{'window_comic_page'}{'file1'}->add_accelerator('activate_item', $forms->{'window_comic_page'}{'accelgroup'}, $forms->{'window_comic_page'}{'file1-key'}, 'mod1_mask', ['visible', 'locked'] );
		    #
		    # Construct a GtkMenu 'menu_file'
		    $widgets->{'menu_file'} = new Gtk::Menu;
		    $forms->{'window_comic_page'}{'file1'}->set_submenu($widgets->{'menu_file'} );
		    $forms->{'window_comic_page'}{'menu_file'} = $widgets->{'menu_file'};
			#
			# Construct a GtkPixmapMenuItem 'menu_file_exit'
			$widgets->{'menu_file_exit'} = Gnome::Stock->menu_item('Menu_Quit', 'Exit');
			$forms->{'window_comic_page'}{accelgroup}->add(81, ['control_mask'], ['visible', 'locked'], $widgets->{'menu_file_exit'}, 'activate');
			$forms->{'window_comic_page'}{'menu_file'}->append($widgets->{'menu_file_exit'} );
			$widgets->{'menu_file_exit'}->show;
			$forms->{'window_comic_page'}{'menu_file_exit'} = $widgets->{'menu_file_exit'};
		#
		# Construct a GtkMenuItem 'help1'
		$widgets->{'help1'} = new Gtk::MenuItem('_Help');
		$forms->{'window_comic_page'}{'menubar1'}->append($widgets->{'help1'} );
		$widgets->{'help1'}->show;
		$forms->{'window_comic_page'}{'help1'} = $widgets->{'help1'};
		$forms->{'window_comic_page'}{'help1-key'} = $forms->{'window_comic_page'}{'help1'}->child->parse_uline('_Help');
		$forms->{'window_comic_page'}{'help1'}->add_accelerator('activate_item', $forms->{'window_comic_page'}{'accelgroup'}, $forms->{'window_comic_page'}{'help1-key'}, 'mod1_mask', ['visible', 'locked'] );
		    #
		    # Construct a GtkMenu 'menu_help'
		    $widgets->{'menu_help'} = new Gtk::Menu;
		    $forms->{'window_comic_page'}{'help1'}->set_submenu($widgets->{'menu_help'} );
		    $forms->{'window_comic_page'}{'menu_help'} = $widgets->{'menu_help'};
			#
			# Construct a GtkPixmapMenuItem 'menu_help_about'
			$widgets->{'menu_help_about'} = Gnome::Stock->menu_item('Menu_About', 'About');
			$forms->{'window_comic_page'}{'menu_help'}->append($widgets->{'menu_help_about'} );
			$widgets->{'menu_help_about'}->show;
			$forms->{'window_comic_page'}{'menu_help_about'} = $widgets->{'menu_help_about'};
	    $forms->{'window_comic_page'}{'vbox1'}->set_child_packing($forms->{'window_comic_page'}{'menubar1'}, 0, 0, 0, 'start' );
	    #
	    # Construct a GtkNotebook 'notebook1'
	    $widgets->{'notebook1'} = new Gtk::Notebook;
	    $forms->{'window_comic_page'}{'vbox1'}->add($widgets->{'notebook1'} );
	    $widgets->{'notebook1'}->show;
	    $forms->{'window_comic_page'}{'notebook1'} = $widgets->{'notebook1'};
	    $forms->{'window_comic_page'}{'notebook1'}->can_focus(1 );
	    $forms->{'window_comic_page'}{'notebook1'}->set_tab_pos('top' );
	    $forms->{'window_comic_page'}{'notebook1'}->set_show_tabs(1 );
	    $forms->{'window_comic_page'}{'notebook1'}->set_show_border(1 );
	    $forms->{'window_comic_page'}{'notebook1'}->set_scrollable(0 );
	    $forms->{'window_comic_page'}{'notebook1'}->set_tab_hborder(2 );
	    $forms->{'window_comic_page'}{'notebook1'}->set_tab_vborder(2 );
		#
		# Construct a GtkVPaned 'vpaned1'
		$widgets->{'vpaned1'} = new Gtk::VPaned;
		$widgets->{'vpaned1'}->handle_size(10 );
		$widgets->{'vpaned1'}->gutter_size(6 );
		$widgets->{'vpaned1'}->show;
		$forms->{'window_comic_page'}{'vpaned1'} = $widgets->{'vpaned1'};
		    #
		    # Construct a GtkHBox 'hbox1'
		    $widgets->{'hbox1'} = new Gtk::HBox(0, 0 );
		    $forms->{'window_comic_page'}{'vpaned1'}->add($widgets->{'hbox1'} );
		    $widgets->{'hbox1'}->show;
		    $forms->{'window_comic_page'}{'hbox1'} = $widgets->{'hbox1'};
			#
			# Construct a GtkCalendar 'calendar_date_comic_selection'
			$widgets->{'calendar_date_comic_selection'} = new Gtk::Calendar;
			$widgets->{'calendar_date_comic_selection'}->display_options(['show_heading', 'show_day_names'] );
			$work->{'calendar_date_comic_selection-date'} = [localtime];
			$widgets->{'calendar_date_comic_selection'}->select_day($work->{'calendar_date_comic_selection-date'}[3] );
			$widgets->{'calendar_date_comic_selection'}->select_month($work->{'calendar_date_comic_selection-date'}[4], $work->{'calendar_date_comic_selection-date'}[5] + 1900);
			$forms->{'window_comic_page'}{'hbox1'}->add($widgets->{'calendar_date_comic_selection'} );
			$widgets->{'calendar_date_comic_selection'}->show;
			$forms->{'window_comic_page'}{'calendar_date_comic_selection'} = $widgets->{'calendar_date_comic_selection'};
			$forms->{'window_comic_page'}{'calendar_date_comic_selection'}->can_focus(1 );
			$forms->{'window_comic_page'}{'hbox1'}->set_child_packing($forms->{'window_comic_page'}{'calendar_date_comic_selection'}, 1, 1, 0, 'start' );
			#
			# Construct a GtkScrolledWindow 'scrolledwindow1'
			$widgets->{'scrolledwindow1'} = new Gtk::ScrolledWindow( undef, undef);
			$widgets->{'scrolledwindow1'}->set_policy('never', 'always' );
			$widgets->{'scrolledwindow1'}->border_width(0 );
			$widgets->{'scrolledwindow1'}->hscrollbar->set_update_policy('continuous' );
			$widgets->{'scrolledwindow1'}->vscrollbar->set_update_policy('continuous' );
			$forms->{'window_comic_page'}{'hbox1'}->add($widgets->{'scrolledwindow1'} );
			$widgets->{'scrolledwindow1'}->show;
			$forms->{'window_comic_page'}{'scrolledwindow1'} = $widgets->{'scrolledwindow1'};
			    #
			    # Construct a GtkViewport 'viewport1'
			    $widgets->{'viewport1'} = new Gtk::Viewport(new Gtk::Adjustment( 0.0, 0.0, 101.0, 0.1, 1.0, 1.0), new Gtk::Adjustment( 0.0, 0.0, 101.0, 0.1, 1.0, 1.0) );
			    $widgets->{'viewport1'}->set_shadow_type('in' );
			    $forms->{'window_comic_page'}{'scrolledwindow1'}->add_with_viewport($widgets->{'viewport1'} );
			    $widgets->{'viewport1'}->show;
			    $forms->{'window_comic_page'}{'viewport1'} = $widgets->{'viewport1'};
				#
				# Construct a GtkList 'list1'
	            my @titles = ("Title", "abbr.", "dbh");
				$widgets->{'list1'} = new_with_titles Gtk::CList( @titles );
				$widgets->{'list1'}->set_selection_mode('single' );
              	$widgets->{'list1'}->set_column_width( 0, 300 );
                $widgets->{'list1'}->set_column_width( 1, 100 );
	            $widgets->{'list1'}->set_column_width( 2, 25 );
                $widgets->{'list1'}->set_shadow_type( 'out' );

				$forms->{'window_comic_page'}{'viewport1'}->add($widgets->{'list1'} );
				$widgets->{'list1'}->show;
				$forms->{'window_comic_page'}{'list1'} = $widgets->{'list1'};
			$forms->{'window_comic_page'}{'hbox1'}->set_child_packing($forms->{'window_comic_page'}{'scrolledwindow1'}, 1, 1, 0, 'start' );
		    #
		    # Construct a GtkVBox 'vbox5'
		    $widgets->{'vbox5'} = new Gtk::VBox(0, 0 );
		    $forms->{'window_comic_page'}{'vpaned1'}->add($widgets->{'vbox5'} );
		    $widgets->{'vbox5'}->show;
		    $forms->{'window_comic_page'}{'vbox5'} = $widgets->{'vbox5'};
			#
			# Construct a GtkScrolledWindow 'scrolledwindow_comic_archive_window'
			$widgets->{'scrolledwindow_comic_archive_window'} = new Gtk::ScrolledWindow( undef, undef);
			$widgets->{'scrolledwindow_comic_archive_window'}->set_policy('never', 'always' );
			$widgets->{'scrolledwindow_comic_archive_window'}->border_width(0 );
			$widgets->{'scrolledwindow_comic_archive_window'}->hscrollbar->set_update_policy('continuous' );
			$widgets->{'scrolledwindow_comic_archive_window'}->vscrollbar->set_update_policy('continuous' );
			$forms->{'window_comic_page'}{'vbox5'}->add($widgets->{'scrolledwindow_comic_archive_window'} );
			$widgets->{'scrolledwindow_comic_archive_window'}->show;
			$forms->{'window_comic_page'}{'scrolledwindow_comic_archive_window'} = $widgets->{'scrolledwindow_comic_archive_window'};
			    #
			    # Construct a GtkViewport 'viewport_comic_archive'
			    $widgets->{'viewport_comic_archive'} = new Gtk::Viewport(new Gtk::Adjustment( 0.0, 0.0, 101.0, 0.1, 1.0, 1.0), new Gtk::Adjustment( 0.0, 0.0, 101.0, 0.1, 1.0, 1.0) );
			    $widgets->{'viewport_comic_archive'}->set_shadow_type('in' );
			    $forms->{'window_comic_page'}{'scrolledwindow_comic_archive_window'}->add_with_viewport($widgets->{'viewport_comic_archive'} );
			    $widgets->{'viewport_comic_archive'}->show;
			    $forms->{'window_comic_page'}{'viewport_comic_archive'} = $widgets->{'viewport_comic_archive'};
				#
				# Construct a GnomePixmap 'pixmap1'
				$widgets->{'pixmap1'} = new_from_file Gnome::Pixmap("" );
				$forms->{'window_comic_page'}{'viewport_comic_archive'}->add($widgets->{'pixmap1'} );
				$widgets->{'pixmap1'}->show;
				$forms->{'window_comic_page'}{'pixmap1'} = $widgets->{'pixmap1'};
			$forms->{'window_comic_page'}{'vbox5'}->set_child_packing($forms->{'window_comic_page'}{'scrolledwindow_comic_archive_window'}, 1, 1, 0, 'start' );
		#
		# Construct a GtkLabel 'label_comic_archive'
		$widgets->{'label_comic_archive'} = new Gtk::Label('Comic Archive');
		$widgets->{'label_comic_archive'}->set_justify('center' );
		$widgets->{'label_comic_archive'}->set_line_wrap(0 );
		$forms->{'window_comic_page'}{'notebook1'}->append_page($forms->{'window_comic_page'}{'vpaned1'}, $widgets->{'label_comic_archive'} );
		$widgets->{'label_comic_archive'}->show;
		$forms->{'window_comic_page'}{'label_comic_archive'} = $widgets->{'label_comic_archive'};
		$forms->{'window_comic_page'}{'label_comic_archive'}->set_alignment(0.5, 0.5 );
	    $forms->{'window_comic_page'}{'vbox1'}->set_child_packing($forms->{'window_comic_page'}{'notebook1'}, 1, 1, 0, 'start' );
	    #
	    # Construct a GnomeAppBar 'appbar1'
	    $widgets->{'appbar1'} = new Gnome::AppBar(1, 1, 'user');
	    $forms->{'window_comic_page'}{'vbox1'}->add($widgets->{'appbar1'} );
	    $widgets->{'appbar1'}->show;
	    $forms->{'window_comic_page'}{'appbar1'} = $widgets->{'appbar1'};
	    $forms->{'window_comic_page'}{'vbox1'}->set_child_packing($forms->{'window_comic_page'}{'appbar1'}, 0, 0, 0, 'start' );

	bless $forms;
	return $forms;
}


1;
