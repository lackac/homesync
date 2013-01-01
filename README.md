# HomeSync

HomeSync makes it easy to synchronize any file under your home directory
with other machines through Dropbox by providing a simple commandline
interface for adding and removing symlinks to your files. Furthermore,
it knows how to handle several key files and directories correctly and
how to synchronize application preferences and data.

## Installation

1. Check out homesync into `~/.homesync`.

    ~~~ sh
    $ git clone https://github.com/lackac/homesync.git ~/.homesync
    ~~~

2. Add `homesync init` to your shell to enable homesync commands.

    ~~~ sh
    $ echo 'eval "$($HOME/.homesync/bin/homesync init -)"' >> ~/.bash_profile
    ~~~

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Restart your shell. You can now begin using homesync.

    ~~~ sh
    $ exec $SHELL
    ~~~

4. Setup homesync optionally providing an alternate path to the
   `HomeSync` directory.

    ~~~ sh
    $ homesync setup [-p ~/path/to/dropbox/homesync]
    ~~~

## How it works

HomeSync uses a directory in your dropbox (`~/Dropbox/HomeSync` by
default) to store the files and directories you want synchronized.
When you add a file to HomeSync it moves the original file to this
directory and creates a symbolic link in its original location.

Files are always stored in HomeSync with the same relative path they had
in your home directory. For example, if you have a file in
`~/Code/script.rb` and you have it synchronized by HomeSync, it will be
moved to `~/Dropbox/HomeSync/Code/script.rb` and `~/Code/script.rb` will
be a symbolic link pointing to this new path.

HomeSync handles `plist` files in `~/Library/Preferences/` a bit
differently. These files are usually overwritten when the application
exits. HomeSync uses a launch agent to watch this directory and the
corresponding HomeSync directory for changes. When a file that needs to
be synced is changed in either of these directories, it would be copied
to the other folder.

## Usage

Run `homesync help` for a list of commands and their descriptions. Run
`homesync help command` for further help.

## Copyright

Copyright (c) 2013 László Bácsi. See LICENSE for details.
