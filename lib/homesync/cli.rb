require 'thor'
require 'pathname'
require 'yaml'

module HomeSync
  class CLI < Thor

    class_option :homesync_path, :aliases => "-p"

    desc "setup", "Create the launch agent and configure HomeSync"
    long_desc <<-EOH
      Create a launch agent to monitor changes of preferences files
      Store homesync path configuration (-p option) in ~/.homesync
    EOH
    def setup
      update_homesync_config
      update_launch_agent
    end

    desc "sync FILE", "Setup syncing for file or directory"
    long_desc <<-EOH
      Move the file to the HomeSync directory and create a symbolic link in its
      place. Or setup a symbolic link in this location if the file doesn't exist
      but a matching file in HomeSync does.

      When both files exist you will be asked what to do. Alternatively you could
      tell HomeSync which road to go using one of the options of this command.
    EOH
    def sync(path)
      path = Pathname.new(path).expand_path
      relative_from_home = path.relative_path_from(home_path)

      if relative_from_home.to_s =~ %r{^../}
        error "#{path} is not inside your home directory"
      end

      sync_path = homesync_path.join(relative_from_home)

      if path.exist?
      else
        if sync_path.exist?
          path.make_symlink(sync_path.to_s)
          say "Created link to #{sync_path}"
        else
          error "#{path} doesn't exist"
        end
      end
    end

  private

    def error(message)
      shell.error shell.set_color(message, :red)
    end

    def home_path
      Pathname.new(ENV['HOME'])
    end

    def homesync_path
      Pathname.new(options[:homesync_path] || "~/Dropbox/HomeSync").expand_path
    end

    def update_homesync_config
      config_file = home_path.join(".homesync")
      config = config_file.exist? ? YAML.load_file(config_file) : {}
      relative_homesync_path = "~/" + homesync_path.relative_path_from(home_path).to_s
      if config['homesync_path'] != relative_homesync_path
        config['homesync_path'] = relative_homesync_path
        config_file.open("w") { |f| f.write(config.to_yaml) }
        puts "Configuration written to #{config_file}"
      end
    end

    def update_launch_agent
      launch_agent_path = home_path.join("Library/LaunchAgents/com.icanscale.homesync.plist")
      executable_path = File.expand_path($0 =~ %r{/} ? $0 : %x{which #{$0}})
      launch_agent = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.icanscale.homesync</string>
	<key>OnDemand</key>
	<true/>
	<key>ProgramArguments</key>
	<array>
		<string>#{executable_path}</string>
		<string>sync:pref</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>WatchPaths</key>
	<array>
		<string>#{home_path}/Library/Preferences</string>
		<string>#{homesync_path}/Library/Preferences</string>
	</array>
</dict>
</plist>
      EOF

      if launch_agent_path.exist?
        if launch_agent_path.read == launch_agent
          puts "Launch Agent already exists"
        else
          launch_agent_path.open("w") { |f| f.write(launch_agent) }
          puts "Launch Agent updated"
        end
      else
        launch_agent_path.dirname.mkpath
        launch_agent_path.open("w") { |f| f.write(launch_agent) }
        puts "Launch Agent created"
      end
    end
  end

end
