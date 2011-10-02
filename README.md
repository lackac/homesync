**Note**: This project is being developed following the [RDD](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) model. Not all of the functionality described in this README have been implemented yet. Missing pieces are noted in the Usage section.

# HomeSync

HomeSync makes it easy to synchronize any file under your home directory with other machines through Dropbox by providing a simple commandline interface for adding and removing symlinks to your files. Furthermore, it knows how to handle several key directories correctly and how to synchronize application preferences and data.

## Installation

    $ gem install homesync
    $ homesync setup [-p ~/path/to/dropbox/homesync]

## How it works

HomeSync uses a directory in your dropbox (`~/Dropbox/HomeSync` by default) to store the files and directories you want to be synchronized. When you add a file to HomeSync it moves the original file to this location and creates a symbolic link in its original place.

Files are always stored in HomeSync with the same relative path they had in your home directory. For example, if you have a file in `~/Code/script.rb` and you have it synchronized by HomeSync, it will be moved to `~/Dropbox/HomeSync/Code/script.rb` and `~/Code/script.rb` will be a symbolic link pointing to this new path.

HomeSync handles `plist` files in `~/Library/Preferences/` a bit differently. These files are usually overwritten when their application exits. HomeSync uses a launch agent to watch this directory and the corresponding HomeSync directory for changes. When a file that needs to be synced is changed in either of these directories, it would be copied to the other folder.

## Usage

    $ homesync setup [-p ~/path/to/dropbox/homesync]

Creates a launch agent to monitor changes of preferences files. The `-p` option tells HomeSync where to put synchronized files (defaults to `~/Dropbox/HomeSync`). This will be stored in the `~/.homesync` configuration file, but all the other commands accept this option too.

    $ homesync sync [--overwrite-local | --overwrite-homesync] ~/path/to/file_or_dir

Tells HomeSync to synchronize the file. This is the default command meaning that the command name may be omitted. The outcome of this command depends on whether the file exists and whether there's a file with the same relative path in HomeSync:

* original file doesn't exist
  * and homesync file doesn't exist: error
  * and homesync file exists: create symbolic link to the homesync file
* original file is a symbolic link
  * to its homesync file: nothing to do
  * to somewhere else: error (homesync doesn't handle this case)
* original file is a regular file or directory
  * and homesync file doesn't exist: move it to homesync and create symbolic link to it
  * and homesync file exists: asks whether to overwrite the current local file and sync what's in HomeSync (`--overwrite-local` to do this without aking) or update HomeSync with the current local file in and sync that instead (`--overwrite-homesync` to do this without asking)

    $ homesync unsync [-r] ~/path/to/file_or_directory

*Not implemented yet.* Given that the argument is a symbolic link to an existing file or directory in HomeSync, copies this file to its original place overwriting the symbolic link. Use the `-r` option to remove the file from homesync afterwards.

### Custom behaviors (*none of it implemented yet*)

    $ homesync sync:pref Application
    $ homesync unsync:pref Application

Syncs or unsyncs the preferences file of the application (e.g. for TextMate this would be `~/Library/Preferences/com.macromates.textmate.plist`). Symlinking wouldn't work because of overwrites, so this works by using a launch agent to monitor changes to this file.

    $ homesync sync:appsupport Application
    $ homesync unsync:appsupport Application

Syncs or unsyncs the application support directory of the application (e.g. for TextMate this would be `~/Library/Application Support/TextMate`).

    $ homesync sync:app Application
    $ homesync unsync:app Application

Syncs or unsyncs both the application's preferences file and its application support directory.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 László Bácsi. See LICENSE for details.
