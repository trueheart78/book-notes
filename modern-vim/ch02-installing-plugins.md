[🔙 Get Modern Vim][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Opening Files 🔜][upcoming-chapter]

# Chapter 2. Installing Plugins

Plugins add new functionality to Vim. Previous versions of vim required plugin managers. Now with
Vim 8 and Neovim, that is a thing of the past.

## Tip 4: Understanding Scripts, Plugins, and Packages

_Packages are a new feature in Vim 8 that make it easy to manage your plugins. A package is a dir
that has one or more scripts, and a script is a standalone file containing instructions written in
Vim script._

### Scripts Add Functionality to Vim

Vim has had basic support for scripts since v5. Here's an example.

```vim
function! SayHello()
  echo 'Hello, world!'
endfunction

command! Hello call SayHello()

nnoremap Q :Hello<CR>
```

You can load a script manually by running `:source {path}`, where the path locates the script you
want to run. 

```vim
:source code/hello.vim
:Hello
Hello, world!
```

After sourcing the script, you can use the fn, commands, and mappings that it defines.

### Plugins Make It Easy to Organize and Share Scripts

If you write a script you want to share, you may create a plugin. That simply means creating a dir
with the name you want to give your plugin, then moving your script into a `plugin` sub dir.

```
demo-plugin
├── doc
│   └── demo.txt
└── plugin
    └── demo.vim
```

Vim has conventions on how it should all be structured and named. Depending on what it all does, it
may have scripts within subdirs named `ftplugin`, `indent`, etc. When a plugin is installed, Vim
auto sources the scripts it finds in these subdirs.

Installing a plugin means adding it to Vim's `runtimepath` (`:help runtimepath`). You can di this by
manpulating the `runtimepath` option by hand.... but you don't have to anymore. Vim 8 released the
packages feature to fill this gap.

### Packages Organize and Load Your plugins

A _package_ is a dir that contains one or more plugins. You create packages within a `$VIMCONFIG/pack`
dir. It should have a subdir called `start`, where plugins that run on startup are placed.

You can create as many packages as you like. You might have a `bundle` one for those remote ones you
love, but a `myplugins` for your local loves.

When Vim launches, it searches in `$VIMCONFIG/pack/*/start/`. Any plugins it finds are added to the
`runtimepath`. In a second pass, Vim sources all those found and added to the `runtimepath`.

### Indexing the Documentation for Installed Plugins

When you add a plugin to one of your packages, all you need to do to start using that plugin is
restart vim. If you need to access the docs, however, make sure to _index its documentation_ with
the `:helptags` command. 

When you use the `helptags` command, Vim parses the docs, builds an index of anchors, and writes them
to a file called `tags`. You only need to run `:helptags` once after installing a new plugin (or 
after updating one).

## Tip 5: Installing Plugins to Your Package

_Coming Soon_

[🔙 Get Modern Vim][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Opening Files 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-get-modern-vim.md
[upcoming-chapter]: ch03-opening-files.md
