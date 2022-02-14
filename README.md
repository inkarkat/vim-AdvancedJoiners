ADVANCED JOINERS
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin ...

### SOURCE
(Original Vim tip, Stack Overflow answer, ...)

### SEE ALSO
(Plugins offering complementary functionality, or plugins using this library.)

### RELATED WORKS
(Alternatives from other authors, other approaches, references not used here.)

USAGE
------------------------------------------------------------------------------

    ["x][count]dJ           Delete the following [count] lines.

    :[range]JoinFolded[!] [{separator}]
                            Join all folded lines into a single long line
                            separated by a space (or passed {separator}).
                            With [!] the join does not insert or delete any
                            spaces.

    [count]J                For me, this means "execute J [count] times", not the
                            default "Join [count] lines", which joins one line
                            less that expected.

    [count]gcJ, {Visual}gcJ Join lines removing any leading comment characters and
                            following indentation. This works like adding "j" to
                            'formatoptions'.
    :: This is a      gcJ     :: This is a multiline     gcJ    :: This is a multiline comment.
    :: multiline   -------->  :: comment.             -------->
    :: comment.
                            On non-comment lines: Fuse lines together, i.e. join
                            and remove any hyphen, whitespace and following
                            indentation.
    The foo-          gcJ      The foobar can be ta-     gcJ     The foobar can be taken off.
    bar can be ta- -------->         ken off.         -------->
          ken off.

    [count]gqJ, {Visual}gqJ Join lines removing any diff quirks (leading + / -,
                            possibly preceded by a ^M) in between.

    [count]gcqJ, {Visual}gcqJ
                            Join lines removing any diff quirks (leading + / -,
                            possibly preceded by a ^M) and following comment
                            characters and indentation.

    [count]gsJ, {Visual}gsJ Join lines removing any trailing and leading
                            whitespace completely.

    [count]g#J, {Visual}g#J Join lines on the final keywords / non-whitespace
                            non-keywords in the first line, removing everything up
                            to that same text on following line(s).
    let foo =              g#J    let foo = "goodbye"
    let bar = "goodbye" -------->

    :[range]Join[!] {separator}
                            Join lines in [range] with {separator} in between.
                            With [!] does not remove spaces.

    [count]<Leader>j        Query a separator string that is inserted between all
    {Visual}<Leader>j       joined lines; indent is removed.
    [count]<Leader>J        Join with the previously queried separator string.
    {Visual}<Leader>J

    [count]<Leader>gj       Query a separator string that is inserted between all
    {Visual}<Leader>gj      joined lines. Don't remove any spaces, like gJ.
    [count]<Leader>gJ       Like above, with the previously queried separator
    {Visual}<Leader>gJ      string.

    :[range]Unjoin[!] [{pattern}]
                            Un-join current line / lines in [range] whereever
                            {pattern} (or the previously queried separator
                            pattern of a mapping) matches.
                            With [!] does not indent the added lines, and does not
                            automatically insert the current comment leader.

    [count]<Leader>uj       Query a separator pattern and un-join [count] lines,
    {Visual}<Leader>uj      i.e. replace each separator match with a <CR> and
                            proper indent.
    [count]<Leader>uJ       Un-join on the previously queried separator pattern.
    {Visual}<Leader>uJ

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-AdvancedJoiners
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim AdvancedJoiners*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.044 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

plugmap

INTEGRATION
------------------------------------------------------------------------------

The gcJ command also removes comment prefixes defined in the whitelist of
the IndentCommentPrefix.vim plugin ([vimscript #2529](http://www.vim.org/scripts/script.php?script_id=2529))
(see|g:IndentCommentPrefix\_Whitelist|).

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-AdvancedJoiners/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### GOAL
First published version.

##### 0.01    19-Jul-2005
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2005-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
