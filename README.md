[Per-Directory-History][home]
=============================

This is an implementation of per directory history for ZSH:

- Typed commands are saved both in a global history, as well as a
  per-directory history.

- A hotkey (<kbd>Alt</kbd><kbd>L</kbd> by default) toggles the current
  history, used for ZSH history navigation and search.

- Directory histories are saved in a hierarchy under your home
  directory mirroring the filesystem hierarchy.

This implementation is loosely based on [the implementation by Jim
Hester][old].  Notable differences:

- Works smoothly with very large (global) history files.
  The global history file is only read in full when switching to it
  with the hotkey.
  
- Works smoothly with `share_history` (commands are flushed to history
  files immediately, and become visible in other shell instances).
  
- Some subjectively saner defaults and namespacing fixes.

<!--
  - Does not override a key with a predefined default meaning by default.
  
  - Does not break in paths containing a path component named `history`.
  
  - Uses a more meaningful location for the per-directory history trees.
-->

Usage
-----

1.  Load this script into your interactive ZSH session:

        % source zsh-per-directory-history.zsh

2.  The default mode is per-directory history, interact with your history as normal.

3.  Press <kbd>Alt</kbd><kbd>L</kbd> (lowercase) to toggle between
    local and global histories.  If you would prefer a different
    shortcut, please set the `PER_DIRECTORY_HISTORY_TOGGLE` shell
    variable.

-------------------------------------------------------------------------------
Configuration
-------------------------------------------------------------------------------

* `PER_DIRECTORY_HISTORY_BASE` is a shell variable which defines the
  base directory in which the directory histories are stored.

* `PER_DIRECTORY_HISTORY_FILE` is a shell variable which defines the
  name of the files which will contain the directory histories.  It
  should be set to something that's unlikely to occur as a path
  component in any paths you intend to visit on your filesystem.

* `per-directory-history-toggle-history` is the function to toggle the
  history mode.

[home]: https://github.com/CyberShadow/per-directory-history
[old]: http://github.com/jimhester/per-directory-history
