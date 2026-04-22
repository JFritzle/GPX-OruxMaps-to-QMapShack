# GPX-OruxMaps-to-QMapShack
Graphical user interface to convert GPX files exported from *OruxMaps* for import into *QMapShack*

### About
Conversion tool maps OruxMaps tracks and waypoints to QMapShack tracks and waypoints. Optionally
- OruxMaps project name can be replaced by file name with file extension cut off
- OruxMaps direction waypoints can be mapped to QMapShack symbols
- OruxMaps direction waypoints can be labeled 

Converted GPX files are ready to import into QMapShack. In order to see direction waypoint symbols on map, user-defined QMapShack waypoint symbols equally named to OruxMaps waypoint symbols must exist.

### Graphical user interface
Graphical user interface is a single script written in _Tcl/Tk_ scripting language and is executable on _Microsoft Windows_ and _Linux_ operating system. Language-neutral script file _GPX-OruxMaps-to-QMapShack.tcl_ requires an additional user settings file and at least one localized resource file. Additional files must follow _Tcl/Tk_ syntax rules too. 

User settings file is named _GPX-OruxMaps-to-QMapShack.ini_. A template file is provided.

Resource files are named _GPX-OruxMaps-to-QMapShack.<locale\>_, where _<locale\>_ matches locale’s 2 lowercase letters ISO 639-1 code. English localized resource file _GPX-OruxMaps-to-QMapShack.en_ and German localized resource file _GPX-OruxMaps-to-QMapShack.de_ are provided. Script can be easily localized to any other system’s locale by providing a corresponding resource file using English resource file as a template. 

Screenshot of graphical user interface: 

![Image](https://github.com/user-attachments/assets/a5c5586e-c2d3-43a7-8314-6cf64af329c2)

![Image](https://github.com/user-attachments/assets/77132514-8d19-42ef-b68b-8271e34e85b6)


### Installation

1.	**Tcl/Tk scripting language version 8.6 or higher binaries**  
**Windows**: Download and install latest stable version of Tcl/Tk, currently 9.0.  
See https://wiki.tcl-lang.org/page/Binary+Distributions for available binary distributions. A suitable Windows binary distribution is from [Magicsplat](https://sourceforge.net/projects/magicsplat/files/magicsplat-tcl/) repository. Select most recent installation file _tcl-9.0.3-installer-2.0.6-x64.msi_ or newer. Install into your Tcl/Tk installation folder, e.g. _%ProgramFiles%/Tcl_.  
**Linux**: Install packages _tcl, tcllib, tcl-thread, tk_, _tklib_, _x11-utils_  and _wmctrl_ using Linux package manager. 
(Ubuntu: _apt install tcl tcllib tcl-thread tk tklib_ _x11-utils_ _wmctrl_)   
**macOS**: If not yet installed, install _tcl-tk_ using _Homebrew_ package manager by _brew install tcl-tk_. Unfortunately, _tklib_ containing required package _tooltip_ is not part of _tcl-tk_. Download _tklib0.9_ from [sourceforge.net](https://sourceforge.net/projects/tcllib/files/tklib/0.9) and install into folder _\<root>/Cellar/tcl-tk/\<version>/lib/tklib0.9_.  

2.	**GPX-OruxMaps-to-QMapShack graphical user interface script**  
Download language-neutral script file _GPX-OruxMaps-to-QMapShack.tcl_, user settings file _GPX-OruxMaps-to-QMapShack.ini_ and at least one localized resource file.  
**Windows**: Copy downloaded files into installation folder, e.g. into folder _%ProgramFiles%/GPX Tools_.  
**Linux** and **macOS**: Copy downloaded files into installation folder, e.g. into folder _~/GPX Tools_.  
**Note**: Edit _user-defined script variables settings section_ of user settings file _GPX-OruxMaps-to-QMapShack.ini_ to match files and folders of your local installation. Always use character slash “/” as directory separator in script, for Microsoft Windows too!  

### Script file execution

**Windows**:  
Associate file extension _.tcl_ to Tcl/Tk window shell’s binary _wish.exe_. Right-click script file and open file’s properties window. Change data type _.tcl_ to be opened by _Wish application_ e.g. by executable _%ProgramFiles%/Tcl/bin/wish.exe_. Once file extension has been associated, double-click script file to run.

**Linux**:  
Either run script file from command line by
```
wish <path-to-script>/GPX-OruxMaps-to-QMapShack.tcl
```
or create a desktop starter file _GPX-OruxMaps-to-QMapShack.desktop_
```
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=GPX-OruxMaps-to-QMapShack
Exec=wish <path-to-script>/GPX-OruxMaps-to-QMapShack.tcl
```
or associate file extension _.tcl_ to Tcl/Tk window shell’s binary _/usr/bin/wish_ and run script file by double-click file in file manager.  

**macOS**:  
Either run script file from command line by
```
wish <path-to-script>/GPX-OruxMaps-to-QMapShack.tcl
```

or use _Automator -> Application -> Run Shell Script -> /usr/local/bin/wish \"$@\"_ to create an application for Tcl/Tk window shell’s binary _wish_, then associate all _.tcl_ files to this application and run script file by double-click file in file manager.

Having _.tcl_ files associated to this application, a desktop starter from script file can be created by _Make Alias_ and dragging the alias and dropping it to desktop.  