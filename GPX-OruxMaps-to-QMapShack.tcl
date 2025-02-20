# Convert Oruxmaps tracks to QMapShack tracks
# ===========================================

# Notes:
# - Additional user settings file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by "ini"
# - At least one additional localized resource file is mandatory!
#   Name of file = this script's full path
#   where file extension "tcl" is replaced by
#   2 lowercase letters ISO 639-1 code, e.g. "en"

# Force file encoding "utf-8"
# Usually required for Tcl/Tk version < 9.0 on Windows!

if {[encoding system] != "utf-8"} {
   encoding system utf-8
   exit [source $argv0]
}

if {![info exists tk_version]} {package require Tk}
wm withdraw .

set version "2025-02-20"
set script [file normalize [info script]]
set title [file tail $script]
set cwd [pwd]

# Required packages

foreach item {Thread msgcat tooltip} {
  if {[catch "package require $item"]} {
    ::tk::MessageBox -title $title -icon error \
	-message "Could not load required Tcl package '$item'" \
	-detail "Please install missing $tcl_platform(os) package!"
    exit
  }
}

# Procedure aliases

interp alias {} ::send {} ::thread::send
interp alias {} ::mc {} ::msgcat::mc
interp alias {} ::messagebox {} ::tk::MessageBox
interp alias {} ::tooltip {} ::tooltip::tooltip
interp alias {} ::style {} ::ttk::style
interp alias {} ::button {} ::ttk::button
interp alias {} ::checkbutton {} ::ttk::checkbutton
interp alias {} ::combobox {} ::ttk::combobox
interp alias {} ::radiobutton {} ::ttk::radiobutton
interp alias {} ::scrollbar {} ::ttk::scrollbar

# Define color palette

foreach {item value} {
Background #f0f0f0
ButtonHighlight #ffffff
Border #a0a0a0
ButtonText #000000
DisabledText #6d6d6d
Focus #e0e0e0
Highlight #0078d7
HighlightText #ffffff
InfoBackground #ffffe1
InfoText #000000
Trough #c8c8c8
Window #ffffff
WindowFrame #646464
WindowText #000000
} {set color$item $value}

# Global widget options

foreach {item value} {
background Background
foreground ButtonText
activeBackground Background
activeForeground ButtonText
disabledBackground Background
disabledForeground DisabledText
highlightBackground Background
highlightColor WindowFrame
readonlyBackground Background
selectBackground Highlight
selectForeground HighlightText
selectColor Window
troughColor Trough
Entry.background Window
Entry.foreground WindowText
Entry.insertBackground WindowText
Entry.highlightColor WindowFrame
Listbox.background Window
Listbox.highlightColor WindowFrame
Tooltip*Label.background InfoBackground
Tooltip*Label.foreground InfoText
} {option add *$item [set color$value]}

set dialog.wrapLength [expr [winfo screenwidth .]/2]
foreach {item value} {
Dialog.msg.wrapLength ${dialog.wrapLength}
Dialog.dtl.wrapLength ${dialog.wrapLength}
Dialog.msg.font TkDefaultFont
Dialog.dtl.font TkDefaultFont
Entry.highlightThickness 1
Label.borderWidth 1
Label.padX 0
Label.padY 0
Labelframe.borderWidth 0
Scale.highlightThickness 1
Scale.showValue 0
Scale.takeFocus 1
Tooltip*Label.padX 2
Tooltip*Label.padY 2
} {eval option add *$item $value}

# Global ttk widget options

style theme use clam

if {$tcl_version > 8.6} {
  if {$tcl_platform(os) == "Windows NT"} \
	{lassign {23 41 101 69 120} ry ul ll cy ht}
  if {$tcl_platform(os) == "Linux"} \
	{lassign { 3 21  81 49 100} ry ul ll cy ht}
  set CheckOff "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	"
  set CheckOn "
	<rect width='94' height='94' x='3' y='$ry'
	style='fill:white;stroke-width:3;stroke:black'/>
	<path d='M20 $ll L80 $ul M20 $ul L80 $ll'
	style='fill:none;stroke:black;stroke-width:14;stroke-linecap:round'/>
	"
  set RadioOff "
	<circle cx='49' cy='$cy' r='47'
	fill='white' stroke='black' stroke-width='3'/>
	"
  set RadioOn "
	<circle cx='49' cy='$cy' r='37'
	fill='black' stroke='white' stroke-width='20'/>
	<circle cx='49' cy='$cy' r='47'
	fill='none' stroke='black' stroke-width='3'/>
	"
  foreach item {CheckOff CheckOn RadioOff RadioOn} \
    {image create photo $item \
	-data "<svg width='125' height='$ht'>[set $item]</svg>"}

  foreach item {Check Radio} {
    style element create ${item}button.sindicator image \
	[list ${item}Off selected ${item}On]
    style layout T${item}button \
	[regsub indicator [style layout T${item}button] sindicator]
  }
}

if {$tcl_platform(os) == "Windows NT"}	{lassign {1 1} yb yc}
if {$tcl_platform(os) == "Linux"}	{lassign {0 2} yb yc}
foreach {item option value} {
. background $colorBackground
. bordercolor $colorBorder
. focuscolor $colorFocus
. darkcolor $colorWindowFrame
. lightcolor $colorWindow
. troughcolor $colorTrough
. selectbackground $colorWindow
. selectforeground $colorWindowText
TButton borderwidth 2
TButton padding "{0 -2 0 $yb}"
TCombobox arrowsize 15
TCombobox padding 0
TCheckbutton padding "{0 $yc}"
TRadiobutton padding "{0 $yc}"
} {eval style configure $item -$option [eval set . \"$value\"]}

foreach {item option value} {
TButton darkcolor {pressed $colorWindow}
TButton lightcolor {pressed $colorWindowFrame}
TButton background {focus $colorFocus pressed $colorFocus}
TCombobox background {focus $colorFocus pressed $colorFocus}
TCombobox bordercolor {focus $colorWindowFrame}
TCombobox selectbackground {focus $colorHighlight}
TCombobox selectforeground {focus $colorHighlightText}
TCheckbutton background {focus $colorFocus}
TRadiobutton background {focus $colorFocus}
Arrow.TButton bordercolor {focus $colorWindowFrame}
} {style map $item -$option [eval list {*}$value]}

# Global widget bindings

foreach item {TButton TCheckbutton TRadiobutton} \
	{bind $item <Return> {%W invoke}}
bind TCombobox <Return> {event generate %W <Button-1>}

bind Entry <FocusIn> {grab %W}
bind Entry <Tab> {grab release %W}
bind Entry <Button-1> {+button-1-press %W %X %Y}

proc scale_updown {w d} {$w set [expr [$w get]+$d*[$w cget -resolution]]}
bind Scale <MouseWheel> {scale_updown %W [expr %D>0?+1:-1]}
bind Scale <Button-4> {scale_updown %W -1}
bind Scale <Button-5> {scale_updown %W +1}
bind Scale <Button-1> {+focus %W}

proc button-1-press {W X Y} {
  set w [winfo containing $X $Y]
  if {"$w" == "$W"} {focus $W; return}
  grab release $W
  if {"$w" == ""} return
  focus $w
  switch [winfo class $w] {
    TCheckbutton -
    TRadiobutton -
    TButton	{$w instate !disabled {$w invoke}}
    TCombobox	{$w instate !disabled {ttk::combobox::Press "" $w \
		[expr $X-[winfo rootx $w]] [expr $Y-[winfo rooty $w]]}}
  }
}

# Bitmap arrow down

image create bitmap ArrowDown -data {
  #define x_width 9
  #define x_height 7
  static char x_bits[] = {
  0x00,0xfe,0x00,0xfe,0xff,0xff,0xfe,0xfe,0x7c,0xfe,0x38,0xfe,0x10,0xfe
  };
}

# Try using system locale for script
# If corresponding localized file does not exist, try locale "en" (English)
# Localized filename = script's filename where file extension "tcl"
# is replaced by 2 lowercase letters ISO 639-1 code

set locale [regsub {(.*)[-_]+(.*)} [::msgcat::mclocale] {\1}]
if {$locale == "c"} {set locale en}
#set locale en

set prefix [file rootname $script]

set list [list $locale en]
foreach item [glob -nocomplain -tails -path $prefix. -type f ??] \
	{lappend list [lindex [split $item .] end]}

unset locale
foreach item $list {
  set file $prefix.$item
  if {![file exists $file]} continue
  if {[catch {source $file} result]} {
    messagebox -title $title -icon error \
	-message "Error reading locale file '[file tail $file]':\n$result"
    exit
  }
  set locale $item
  ::msgcat::mclocale $locale
  break
}
if {![info exists locale]} {
  messagebox -title $title -icon error \
	-message "No locale file '[file tail $file]' found"
  exit
}

# Read user settings from file
# Filename = script's filename where file extension "tcl" is replaced by "ini"

set file [file rootname $script].ini
if {![file exist $file]} {
  messagebox -title $title -icon error \
	-message "[mc i01 [file tail $file]]"
  exit
} elseif {[catch {source $file} result]} {
  messagebox -title $title -icon error \
	-message "[mc i00 [file tail $file]]:\n$result"
  exit
}

# Process user settings:
# replace commands resolved by current search path
# replace relative paths by absolute paths

# - commands
set cmds {}
# - commands + folders + files
set list [concat $cmds ini_folder]

set drive [regsub {((^.:)|(^//[^/]*)||(?:))(?:.*$)} $cwd {\1}]
if {$tcl_platform(os) == "Windows NT"}	{cd $env(SystemDrive)/}
if {$tcl_platform(os) == "Linux"}	{cd /}

foreach item $list {
  if {![info exists $item]} continue
  set value [set $item]
  if {$value == ""} continue
  if {$tcl_version >= 9.0} {set value [file tildeexpand $value]}
  if {$item in $cmds} {
    set exec [auto_execok $value]
    if {$exec == ""} {
      messagebox -title $title -icon error -message [mc e04 $value $item]
      exit
    }
    set value [lindex $exec 0]
  }
  switch [file pathtype $value] {
    absolute		{set $item [file normalize $value]}
    relative		{set $item [file normalize $cwd/$value]}
    volumerelative	{set $item [file normalize $drive/$value]}
  }
}

cd $cwd

# Check operating system

if {$tcl_platform(os) == "Windows NT"} {
} elseif {$tcl_platform(os) == "Linux"} {
} else {
  error_message [mc e03 $tcl_platform(os)] exit
}

# Restore saved settings from folder ini_folder

if {![info exists ini_folder]} {set ini_folder "$env(HOME)/.GPX Tools"}
file mkdir $ini_folder

set project.rename 0
set waypoint.symbols 0
set waypoint.labels 0
set gpx.folder [pwd]
set gpx.prefix qms

set font.size [font configure TkDefaultFont -size]
set console.show 0
set console.geometry ""
set console.font.size 8

# Save/restore settings

proc save_settings {file args} {
  array set save {}
  set fd [open $file a+]
  seek $fd 0
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set save($name) $value
  }
  foreach name $args {set save($name) [set ::$name]}
  seek $fd 0
  chan truncate $fd
  foreach name [lsort [array names save]] {puts $fd $name=$save($name)}
  close $fd
}

proc restore_settings {file} {
  if {![file exists $file]} return
  set fd [open $file r]
  while {[gets $fd line] != -1} {
    regexp {^(.*?)=(.*)$} $line "" name value
    set ::$name $value
  }
  close $fd
}

# Restore saved settings

set settings [file rootname [file tail $script]].ini
restore_settings $ini_folder/$settings

# Restore saved font sizes

foreach item {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont} \
	{font configure $item -size ${font.size}}

# Configure main window

set title [mc t00]
wm title . $title
wm protocol . WM_DELETE_WINDOW "set action 0"
wm resizable . 0 0
. configure -bd 5 -bg $colorBackground

# Output console window

set console 0;			# Valid values: 0=hide, 1=show

set ctid [thread::create -joinable "
  package require Tk
  wm withdraw .
  wm title . \"$title - [mc l99]\"
  set font_size ${console.font.size}
  set geometry {${console.geometry}}
  ttk::style theme use clam
  ttk::style configure . -border $colorBorder -troughcolor $colorTrough
  thread::wait
  "]

proc ctsend {script} "return \[send $ctid \$script\]"

ctsend {
  foreach item {Consolas "Ubuntu Mono" "Noto Mono" "Liberation Mono"
  	[font configure TkFixedFont -family]} {
    set family [lsearch -nocase -exact -inline [font families] $item]
    if {$family != ""} break
  }
  font create font -family $family -size $font_size
  text .txt -font font -wrap none -setgrid 1 -state disabled -undo 0 \
	-width 120 -xscrollcommand {.sbx set} \
	-height 24 -yscrollcommand {.sby set}
  ttk::scrollbar .sbx -orient horizontal -command {.txt xview}
  ttk::scrollbar .sby -orient vertical   -command {.txt yview}
  grid .txt -row 1 -column 1 -sticky nswe
  grid .sby -row 1 -column 2 -sticky ns
  grid .sbx -row 2 -column 1 -sticky we
  grid columnconfigure . 1 -weight 1
  grid rowconfigure    . 1 -weight 1

  bind .txt <Control-a> {%W tag add sel 1.0 end;break}
  bind .txt <Control-c> {tk_textCopy %W;break}
  bind . <Control-plus>  {incr_font_size +1}
  bind . <Control-minus> {incr_font_size -1}
  bind . <Control-KP_Add>      {incr_font_size +1}
  bind . <Control-KP_Subtract> {incr_font_size -1}

  bind . <Configure> {
    if {"%W" != "."} continue
    scan [wm geometry %W] "%%dx%%d+%%d+%%d" cols rows x y
    set geometry "$x $y $cols $rows"
  }

  proc incr_font_size {incr} {
    set px [.txt xview]
    set py [.txt yview]
    set size [font configure font -size]
    incr size $incr
    if {$size < 5 || $size > 20} return
    font configure font -size $size
    update idletasks
    .txt xview moveto [lindex $px 0]
    .txt yview moveto [lindex $py 0]
  }

  set lines 0
  proc write {text} {
    incr ::lines
    .txt configure -state normal
    if {[string index $text 0] == "\r"} {
      set text [string range $text 1 end]
      .txt delete end-2l end-1l
    }
    .txt insert end $text
    .txt configure -state disabled
    .txt see end
    if {$::lines == 256} {update; set ::lines 0}
  }

  proc show_hide {show} {
    if {$show} {
      if {$::geometry == ""} {
	wm deiconify .
      } else {
	lassign $::geometry x y cols rows
	if {$x > [expr [winfo vrootx .]+[winfo vrootwidth .]] ||
	    $x < [winfo vrootx .]} {set x [winfo vrootx .]}
	wm positionfrom . program
	wm geometry . ${cols}x${rows}+$x+$y
	wm deiconify .
	wm geometry . +$x+$y
      }
    } else {
      wm withdraw .
    }
  }

  lassign [chan pipe] fdi fdo
  thread::detach $fdo
  fconfigure $fdi -blocking 0 -buffering line -translation lf
  fileevent $fdi readable "
    while {\[gets $fdi line\] >= 0} {write \"\$line\\n\"}
  "
}

set fdo [ctsend "set fdo"]
thread::attach $fdo
fconfigure $fdo -blocking 0 -buffering line -translation lf
interp alias {} ::cputs {} ::puts $fdo

if {$console == 1} {
  set console.show 1
  ctsend "show_hide 1"
}

# Mark output message

proc cputw {text} {cputs "\[+++\] $text"}
proc cputi {text} {cputs "\[===\] $text"}
proc cputx {text} {cputs "\[···\] $text"}

cputw [mc m51 [pid] [file tail [info nameofexecutable]]]
cputw "Tcl/Tk version $tcl_patchLevel"
cputw "Script '[file tail $script]' version $version"

# Show error message

proc error_message {message exit_return} {
  messagebox -title $::title -icon error -message $message
  eval $exit_return
}

# --- Begin of main window

# Title

font create title_font {*}[font configure TkDefaultFont] \
	-underline 0 -weight bold
label .title -text $title -font title_font -fg blue
pack .title -expand 1 -fill x

set github https://github.com/JFritzle/GPX-QMapShack-to-OruxMaps
tooltip .title $github
if {$tcl_platform(platform) == "windows"} \
	{set exec "exec cmd.exe /C START {} $github"}
if {$tcl_platform(os) == "Linux"} \
	{set exec "exec nohup xdg-open $github >/dev/null"}
bind .title <Button-1> "catch {$exec}"

frame .f
pack .f -fill x

# Choose GPX input files

labelframe .gpx_files -labelanchor nw -text [mc l10]:
pack .gpx_files -in .f -fill x -expand 1 -pady 1
set gpx_files {}
listbox .gpx_files_list -selectmode browse -activestyle none \
	-height 3 -listvariable gpx_files -state disabled
button .gpx_files_button -image ArrowDown -command choose_gpx_files
pack .gpx_files_button -in .gpx_files -side right -fill y -pady 1
pack .gpx_files_list -in .gpx_files -side left -fill x -expand 1

proc choose_gpx_files {} {
  set types [list [list [mc l11] .gpx]]
  set files [tk_getOpenFile -parent . -multiple 1 \
	-initialdir ${::gpx.folder} -filetypes $types \
	-title "$::title - [mc l10]"]
  if {![llength $files]} return
  set ::gpx.folder [file dirname [lindex $files 0]]
  set ::gpx_files [lmap file $files {lindex [file split $file] end}]
  set ::gpx_files [lsort -unique $::gpx_files]
}

# GPX output file prefix

labelframe .gpx_prefix -labelanchor w -text [mc l12]:
entry .gpx_prefix_value -textvariable gpx.prefix \
	-width 8 -justify left
pack .gpx_prefix -in .f -expand 1 -fill x -pady 1
pack .gpx_prefix_value -in .gpx_prefix \
	-side right -anchor e -expand 1 -padx {3 0}

# Validate file prefix for valid filename characters

.gpx_prefix_value configure -validate all -vcmd {
  set var [%W cget -textvariable]
  set val [string trim %P]
  if {"%V" == "key"} {
    return [regexp {^[^<>:;?"*|/\\]*$} $val];
  } elseif {"%V" == "focusin"} {
    set $var.prev $val
  } elseif {"%V" == "focusout"} {
    set prev [set $var.prev]
    if {[regexp {^[^<>:;?"*|/\\]+$} $val]} {
      set $var [string trimright $val .]
    } else {
      set $var $prev
    }
    after idle "%W config -validate all"
  }
  return 1
}

# Rename project?

checkbutton .project_rename -text [mc l01] -variable project.rename
pack .project_rename -in .f -expand 1 -fill x -pady {2 0}

# Waypoint symbols?

checkbutton .waypoint_symbols -text [mc l02] -variable waypoint.symbols
pack .waypoint_symbols -in .f -expand 1 -fill x -pady {2 0}

# Waypoint labels?

checkbutton .waypoint_labels -text [mc l03] -variable waypoint.labels
pack .waypoint_labels -in .f -expand 1 -fill x -pady {2 0}

# Action buttons

frame .buttons
button .buttons.continue -text [mc b01] -width 12 -command {set action 1}
button .buttons.cancel -text [mc b02] -width 12 -command {set action 0}
pack .buttons.continue .buttons.cancel -side left
pack .buttons -after .f -anchor n -pady 5

focus .buttons.continue

proc busy_state {state} {
  set busy {.f .buttons.continue}
  if {$state} {
    foreach item $busy {tk busy hold $item}
    .buttons.continue state pressed
    .buttons.cancel configure -text [mc b03] -command {set cancel 1}
  } else {
    .buttons.continue state !pressed
    .buttons.cancel configure -text [mc b02] -command {set action 0}
    foreach item $busy {tk busy forget $item}
  }
  update idletasks
}

# Show/hide output console window (show with saved geometry)

checkbutton .output -text [mc c99] -width 32 \
	-variable console.show -command show_hide_console
pack .output -after .buttons -anchor n -expand 1 -fill x

proc show_hide_console {} {ctsend "show_hide ${::console.show}";update}
show_hide_console

# Map/Unmap events are generated by Windows only!
set tid [thread::id]
ctsend "
  wm protocol . WM_DELETE_WINDOW \
	{thread::send -async $tid {.output invoke}}
  bind . <Unmap> {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 0}}}
  bind . <Map>   {if {\"%W\" == \".\"} \
	{thread::send -async $tid {set console.show 1}}}
"

# --- End of main window right column

# Recalculate and force toplevel window size

proc resize_toplevel_window {widget} {
  update idletask
  lassign [wm minsize $widget] w0 h0
  set w1 [winfo reqwidth $widget]
  set h1 [winfo reqheight $widget]
  if {$w0 == $w1 && $h0 == $h1} return
  wm minsize $widget $w1 $h1
  wm maxsize $widget $w1 $h1
}

# Global toplevel bindings

bind . <Control-plus>  {incr_font_size +1}
bind . <Control-minus> {incr_font_size -1}
bind . <Control-KP_Add>      {incr_font_size +1}
bind . <Control-KP_Subtract> {incr_font_size -1}

# Save global settings to folder ini_folder

proc save_script_settings {} {
  scan [wm geometry .] "%dx%d+%d+%d" width height x y
  set ::window.geometry "$x $y $width $height"
  set ::font.size [font configure TkDefaultFont -size]
  set ::console.geometry [ctsend "set geometry"]
  set ::console.font.size [ctsend "font configure font -size"]
  save_settings $::ini_folder/$::settings \
	window.geometry font.size \
	console.show console.geometry console.font.size \
	project.rename waypoint.symbols waypoint.labels \
	gpx.folder gpx.prefix
}

# Increase/decrease font size

proc incr_font_size {incr} {
  set size [font configure TkDefaultFont -size]
  if {$size < 0} {set size [expr round(-$size/[tk scaling])]}
  incr size $incr
  if {$size < 5 || $size > 20} return
  set fonts {TkDefaultFont TkTextFont TkFixedFont TkTooltipFont title_font}
  foreach item $fonts {font configure $item -size $size}
  set height [expr [winfo reqheight .title]-2]

  if {$::tcl_version > 8.6} {
    set scale [expr ($height+2)*0.0065]
    foreach item {CheckOff CheckOn RadioOff RadioOn} \
	{$item configure -format [list svg -scale $scale]}
  } else {
    set size [expr round(($height+3)*0.6)]
    set padx [expr round($size*0.3)]
    if {$::tcl_platform(os) == "Windows NT"} {set pady 0.1}
    if {$::tcl_platform(os) == "Linux"} {set pady -0.1}
    set pady [expr round($size*$pady)]
    set margin [list 0 $pady $padx 0]
    foreach item {TCheckbutton TRadiobutton} \
	{style configure $item -indicatorsize $size -indicatormargin $margin}
  }
  update idletasks

  resize_toplevel_window .
}

# Check selection for completeness

proc selection_ok {} {
  if {[llength $::gpx_files]} {return 1}
  error_message [mc e20] return
  return 0
}

# Get icon name from id

proc get_icon_name {id} {
  set i [lsearch -exact $::icons $id]
  return [expr {($i < 0) ? "" : [lindex $::icons $i+1]}]
}

# Get icon id from name

proc get_icon_id {name} {
  set i [lsearch -exact $::icons $name]
  return [expr {($i < 0) ? "" : [lindex $::icons $i-1]}]
}

# Convert all selected GPX files

proc run_convert_job {} {
  set ::cancel 0
  set cwd [pwd]
  cd ${::gpx.folder}
  while {[llength $::gpx_files]} {
    set ::gpx_files [lassign $::gpx_files file]
    convert_gpx_file $file
    update
    if {$::cancel} break
  }	
  cd $cwd
}

# Convert GPX file OruxMaps -> QMapShack

proc convert_gpx_file {file} {

  upvar #0 gpx.prefix prefix project.rename rename \
	waypoint.labels labels waypoint.symbols symbols

  cputi "[mc m61 $file] ..."
  set start [clock milliseconds]

  # Read GPX file
  set fd [open $file r]
  set data [read -nonewline $fd]
  close $fd

  # Check for creator
  regexp {(^.*<gpx.*?creator=")(.*?)(".*$)} $data {} head body tail
  cputx [mc m60 $body]
  # Replace creator
  set body "GPX-OruxMaps-to-QMapShack"
  set data $head$body$tail

  set i [string first "<trk>" $data]
  regsub -start $i {^(<trk>.*?<trkseg>).*$} $data {\1} trkhead
  regsub {^.*<name>(?:<!\[CDATA\[)(.*?)(?:\]\]>)</name>.*$} $trkhead \
	{\1} trkname
  cputx "[mc m62 $trkname] ..."
  update

  # Rename project name to file name, when requested
  if {$rename} {set trkname [file rootname [file tail $file]]}
  regsub "(<metadata>.*?<name>).*?(</name>.*?</metadata>)" \
	$data "\\1$trkname\\2" data

  set i [string first "<trk>" $data]
  set head [string range $data 0 $i-1]
  set data [string range $data $i end]
  regexp {^(<trk>.*?</trk>)(.*$)} $data {} body tail
  regsub -all "</trkseg>.*?<trkseg>" $body "" body
  regsub -all "<extensions>.*?</extensions>" $body "" body
  set data $head$body$tail

  # Map OM waypoints to QMS waypoints
  # Collect constraint track waypoints
  set latlons {}
  set i [string first "<wpt" $data]
  set head [string range $data 0 $i-1]
  set data [string range $data $i end]
  set result $head
  while {[regexp "(^.*?)(<wpt.*?</wpt>)(.*$)" $data {} head body tail]} {
    append result $head
    regsub {.*<name>(?:<!\[CDATA\[)(.*?)(?:\]\]>)</name>.*} $body {\1} name
    regsub {.*<om:ext type="ICON" subtype="0">([0-9]+?)</om:ext>.*} \
	$body {\1} id
    if {$name == "" || $id == 1} {
      # name == ""	... OM generated direction track waypoint
      # id   == 1	... User defined track waypoint
      lappend latlons [regsub {.*lat="(.*?)".*lon="(.*?)".*} $body {\1,\2}]
      set name [get_icon_name $id]
      if {!$labels} {regsub "<name>.*</name>" $body "" body} \
      else {regsub "(<name>).*(</name>)" $body "\\1$name\\2" body}
      if {!$symbols} {regsub "(<sym>).*(</sym>)" $body "\\1Waypoint\\2" body} \
      else {regsub "(<sym>).*(</sym>)" $body "\\1$name\\2" body}
    } else {
      # Other user defined standard waypoint
      cputx "[mc m63 $name] ..."
      regsub {.*<type>(.*?)</type>.*} $body {\1} type
      regsub "(<name>).*(</name>)" $body "\\1$name\\2" body
      regsub "(<sym>).*(</sym>)" $body "\\1$type\\2" body
    }
    regsub "<type>.*?</type>" $body "" body
    append result $body
    set data $tail
  }
  append result $data

  # Set QMS track flags depending on collected OM track waypoints:
  # flag = 0	... Constraint points, in QMS always visible
  # flag = 8	... Support points, in QMS visible as dots when editing track
  set prev {}
  set tail $result
  set result ""
   while {1} {
    set i [string first "<trkpt" $tail]
    set head [string range $tail 0 $i-1]
    set tail [string range $tail $i end]
    append result $head
    if {$i < 0} break
    set i [string first "</trkpt>" $tail]
    set body [string range $tail 0 $i-1]
    set tail [string range $tail $i end]
    regsub {.*lat="(.*?)".*lon="(.*?)".*} $body {\1,\2} next
    if {$next != $prev} {
      set flag [expr {$next in $latlons} ? 0 : 8]
      append body "<extensions><ql:flags>$flag</ql:flags></extensions>"
      append result $body
      set prev $next
    } else {
      set tail [string range $tail 8 end]
    }
  }
  append result $tail

  # Remove empty lines
  regsub -line -all {^\s*$\n?} $result {} result

  # Write converted GPX file
  set file $prefix.$file
  set fd [open $file w]
  puts -nonewline $fd $result
  close $fd

  set stop [clock milliseconds]
  set time [expr ($stop-$start)/1000.]

  cputx [mc m65 $time]
  cputi [mc m64 $file]

}

# Show main window (at saved position)

wm positionfrom . program
if {[info exists window.geometry]} {
  lassign ${window.geometry} x y width height
  # Adjust horizontal position if necessary
  set x [expr max($x,[winfo vrootx .])]
  set x [expr min($x,[winfo vrootx .]+[winfo vrootwidth .]-$width)]
  wm geometry . +$x+$y
}
incr_font_size 0
wm deiconify .

# Wait for valid selection or finish

while {1} {
  vwait action
  if {$action == 0} {
    save_script_settings
    exit
  }
  if {[selection_ok]} break
  unset action
}

# Wait for new selection or finish

update idletasks
if {![info exists action]} {vwait action}

# After changing settings: run render job

while {$action == 1} {
  unset action
  if {[selection_ok]} {
    busy_state 1
    run_convert_job
    busy_state 0
  }
  if {![info exists action]} {vwait action}
}
unset action

# Unmap main toplevel window

wm withdraw .

# Save settings to folder ini_folder

save_script_settings

# Wait until output console window was closed

if {[ctsend "winfo ismapped ."]} {
  ctsend "
    write \"\n[mc m99]\"
    wm protocol . WM_DELETE_WINDOW {}
    bind . <ButtonRelease-3> {destroy .}
    tkwait window .
  "
}

# Done

destroy .
exit
