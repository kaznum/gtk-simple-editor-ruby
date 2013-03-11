#!/usr/bin/ruby
#
# $Id: numakiti.rb,v 1.1.1.1 2002/12/28 19:53:02 kaz Exp $
#
# Numakiti Editor for Ruby GTK+
# Copyright(C) Kazuya NUMATA <kaznum@gol.com>
# You can redistribute this program under GNU General Public License.

require 'gtk'
require 'gdk_imlib'
require 'gnome'

class NKEdit<Gtk::Text
  attr_accessor :changed, :file_name
  def initialize(arg1,arg2)
    super
    @changed = false
    @file_name = ""
  end
  def load(filename)
    if  (FileTest::file?(filename) && FileTest::readable?(filename))
      File::open(filename,"r") { |f|
	self.insert(nil,nil,nil,f.read)
	self.file_name = filename
	self.changed = false
      }
    end
  end

  def load_file
    file_dlg = Gtk::FileSelection.new("Load from ...")
    file_dlg.set_modal(true)
    file_dlg.position(Gtk::WIN_POS_MOUSE)
    file_dlg.show
    file_dlg.ok_button.signal_connect("clicked") {
      load(file_dlg.get_filename)
      file_dlg.destroy
    }
    file_dlg.cancel_button.signal_connect("clicked") {
      file_dlg.destroy
    }
    file_dlg.show    
  end

  def save(filename)
    if (!FileTest::exist?(filename)  || (FileTest::file?(filename) \
					 && FileTest::writable?(filename)))
      File::open(filename,"w+") { |f|
	f.print self.get_chars(0,-1)
	self.file_name = filename
	self.changed = false
      }
    end
  end

  def save_as
    file_dlg = Gtk::FileSelection.new("Save as ...")
    file_dlg.set_modal(true)
    file_dlg.position(Gtk::WIN_POS_MOUSE)
    file_dlg.show
    file_dlg.ok_button.signal_connect("clicked") {
      save(file_dlg.get_filename)
      file_dlg.destroy
    }
    file_dlg.cancel_button.signal_connect("clicked") {
      file_dlg.destroy
    }
    file_dlg.show
  end
end

def confir_dlg
  dialog = Gtk::Dialog.new
  dialog.set_usize(200,100)
  label = Gtk::Label.new("The document was changed\n after last save.\n Really Quit?")
  dialog.vbox.pack_start(label)
  label.show
  button = Gtk::Button.new("OK")
  dialog.action_area.pack_start(button)
  button.show
  button.signal_connect("clicked") { exit }

  button = Gtk::Button.new("Cancel")
  dialog.action_area.pack_start(button)
  button.show
  button.signal_connect("clicked") { dialog.destroy }
  dialog.set_modal(true)
  dialog.set_policy(FALSE, FALSE, TRUE)
  dialog.position(Gtk::WIN_POS_MOUSE)
  dialog.show
end


window = Gtk::Window.new(Gtk::WINDOW_TOPLEVEL)
window.set_title("NUMAKITI")
vbox = Gtk::VBox.new(false,0)
window.add(vbox)
vbox.show

text = NKEdit.new(Gtk::Adjustment.new(0,0,0,0,0,0),
		     Gtk::Adjustment.new(0,0,0,0,0,0))
text.signal_connect("changed") {
  if !text.changed 
    text.changed = true
  end
}
text.set_usize(400, 200)
text.set_editable(true)
vbox.pack_end(text)
text.show
text.grab_focus

hbox = Gtk::HBox.new(false,0)
vbox.pack_start(hbox)
hbox.show

button = Gtk::Button.new("Open")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  text.load_file
  window.set_title(text.file_name)
}

button = Gtk::Button::new("Save")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  if text.file_name.empty? 
    text.save_as
  else
    text.save("filename")
    window.set_title(text.file_name)
  end
}

button = Gtk::Button::new("Save as...")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  text.save_as
  window.set_title(text.file_name)
}

button = Gtk::Button.new("Cut")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  text.cut_clipboard
}

button = Gtk::Button.new("Copy")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  text.copy_clipboard
}

button = Gtk::Button.new("Paste")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  text.paste_clipboard
}

button = Gtk::Button.new("About")
hbox.pack_start(button)
button.show
button.signal_connect("clicked") {
  authors = ["Kazuya NUMATA <kaznum@gol.com>"]
  about_dlg = Gnome::About.new("Numakiti Editor Ruby for GTK+",
			       "0.1",
			       "You can redistribute this program under GPL.",
			       authors,
			       "Numakiti is a simple editor written in Ruby.",
			       nil)
  about_dlg.set_modal(true)
  about_dlg.position(Gtk::WIN_POS_MOUSE)
  about_dlg.show
}

button = Gtk::Button.new("Exit")
hbox.pack_end(button)
button.show
button.signal_connect("clicked") { 
  if text.changed
    confir_dlg
  else 
    exit
  end
}

window.signal_connect("destroy") {
  if text.changed
    confir_dlg
  end
  exit
}

window.show
tmpfile = ARGV.shift
if tmpfile && !tmpfile.empty?
  text.load(tmpfile)
  window.set_title(text.file_name)
end

Gtk.main

