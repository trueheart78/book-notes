[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Installing Plugins 🔜][upcoming-chapter]

# Chapter 1. Get Modern Vim

You probably have Vim install on your system, but maybe not the latest. Let's get that sorted out.

```
$ vim --version

VIM - Vi IMproved 8.0 (2016 Sep 12, compiled Mar  2 2017 07:12:07)
MacOS X (unix) version
Included patches: 1-398
Compiled by Homebrew
Huge version without GUI.  Features included (+) or not (-):
+acl             +file_in_path    +mouse_sgr       +tag_old_static
+arabic          +find_in_path    -mouse_sysmouse  -tag_any_white
+autocmd         +float           +mouse_urxvt     -tcl
-balloon_eval    +folding         +mouse_xterm     +termguicolors
-browse          -footer          +multi_byte      +terminfo
++builtin_terms  +fork()          +multi_lang      +termresponse
+byte_offset     -gettext         -mzscheme        +textobjects
+channel         -hangul_input    +netbeans_intg   +timers
+cindent         +iconv           +num64           +title
-clientserver    +insert_expand   +packages        -toolbar
+clipboard       +job             +path_extra      +user_commands
+cmdline_compl   +jumplist        +perl            +vertsplit
+cmdline_hist    +keymap          +persistent_undo +virtualedit
+cmdline_info    +lambda          +postscript      +visual
+comments        +langmap         +printer         +visualextra
+conceal         +libcall         +profile         +viminfo
+cryptv          +linebreak       +python          +vreplace
+cscope          +lispindent      -python3         +wildignore
+cursorbind      +listcmds        +quickfix        +wildmenu
+cursorshape     +localmap        +reltime         +windows
+dialog_con      -lua             +rightleft       +writebackup
+diff            +menu            +ruby            -X11
+digraphs        +mksession       +scrollbind      -xfontset
-dnd             +modify_fname    +signs           -xim
-ebcdic          +mouse           +smartindent     -xpm
+emacs_tags      -mouseshape      +startuptime     -xsmp
+eval            +mouse_dec       +statusline      -xterm_clipboard
+ex_extra        -mouse_gpm       -sun_workshop    -xterm_save
+extra_search    -mouse_jsbterm   +syntax
+farsi           +mouse_netterm   +tag_binary
   system vimrc file: "$VIM/vimrc"
     user vimrc file: "$HOME/.vimrc"
 2nd user vimrc file: "~/.vim/vimrc"
      user exrc file: "$HOME/.exrc"
       defaults file: "$VIMRUNTIME/defaults.vim"
  fall-back for $VIM: "/usr/local/share/vim"
Compilation: clang -c -I. -Iproto -DHAVE_CONFIG_H   -DMACOS_X_UNIX  -g -O2 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1
Linking: clang   -L. -fstack-protector -L/usr/local/lib -L/usr/local/opt/libyaml/lib -L/usr/local/opt/openssl/lib -L/usr/local/opt/readline/lib  -L/usr/local/lib -o vim        -lncurses -liconv -framework Cocoa   -mmacosx-version-min=10.12 -fstack-protector-strong -L/usr/local/lib  -L/usr/local/Cellar/perl/5
.24.1/lib/perl5/5.24.1/darwin-thread-multi-2level/CORE -lperl -lm -lutil -lc -F/usr/local/opt/python/Frameworks -framework Python   -lruby.2.4.0 -lobjc
```

The first line shows the version (8.0), and you can see which features have been enabled in your
build of vVim. Crucial features are:

* `+job`
* `+channel`
* `+timers`
* `+packages`

If you are on an older version of Vim, it's time to upgrade. Let's cover that.

## Installing Vim 8 on Linux

_Skimmed_

## Switching to Neovim

_Skimmed_

## Contextual Instructions for Neovim

Throughout this book, you’ll come across generalized instructions that look like this:

```
$ mkdir -p $VIMCONFIG/pack/bundle/start
$ mkdir -p $VIMDATA/undo
```
When running Neovim on Unix, you could execute those commands by running:

```
$ mkdir -p ~/.config/nvim/pack/bundle/start
$ mkdir -p ~/.local/share/nvim/undo
```

Alternatively, you could set the `$VIMCONFIG` and `$VIMDATA` variables for your shell. For example, in bash you would run:

```
$ export VIMCONFIG=~/.config/nvim
$ export VIMDATA=~/.local/share/nvim
```

Having set these variables, you could then run the `mkdir -p $VIMCONFIG/pack/bundle/start` and `mkdir -p $VIMDATA/undo` commands verbatim.

_Tip 3: Enabling Python Support in Neovim_

## Enable the Python 3 Provider

Install the Python client:

```
pip3 install --user --upgrade neovim
```

This does require python 3 installed, which means `brew upgrade python` or whatever the Linux 
equivalent is.

## Installing `neovim-remote`

Neovim-remote is a tool that lets you control Neovim processes remotely. It does depend on the Python
3 client, so do make sure that's install first.

Then, do the following to install the `neovim-remote` tool with `pip`:

```
pip3 install --user --upgrade neovim-remote
```

The package is called `neovim-remote`, but you can execute it by calling `nvr`.

Verify it is installed with:

```
nvr -h

usage: nvr [arguments]
```

[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Installing Plugins 🔜][upcoming-chapter]

[readme]: README.md
[upcoming-chapter]: ch02-installing-plugins.md
