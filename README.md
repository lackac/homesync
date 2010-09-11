**Note**: this is a draft, I haven't started to implement it yet. In true [RDD](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) style here is the readme first.

# HomeSync

HomeSync makes it easy to synchronize any file under your home folder with other machines through Dropbox. It provides a simple commandline interface for adding and removing symlinks to your files and directories. It also knows how to handle several key folders correctly and how to synchronize Application configurations and data.

## How it works

HomeSync uses a folder in your dropbox (`~/Dropbox/HomeSync` by default) to store the files and directories you want to sync. When you add a file to homesync it moves the original file to this folder (with the same path the original file had relative to your home directory) and then creates a symbolic link to it.

## Synopsis

    $ homesync add ~/path/to/file
    $ homesync add ~/path/to/directory
      # decide how to handle files already in Dropbox
      # (replace or setup sync with existing file)

    $ homesync remove ~/path/to/file
    $ homesync remove ~/path/to/directory
      # decide what to do
      # (remove just link or Dropbox file as well?)

### Custom behaviors

    $ homesync add config TextMate
      # syncs ~/Library/Preferences/com.macromates.textmate.plist
    $ homesync add appsupport TextMate
      # syncs ~/Library/Application Support/TextMate
    $ homesync add app TextMate
      # does the previous two
