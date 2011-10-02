require 'spec_helper'

describe HomeSync::CLI do

  let(:stdin)  { nil }
  let(:stdout) { @stdout }
  let(:stderr) { @stderr }
  let(:command) { "" }
  let(:args) { "" }
  let(:home) { Pathname.new(ENV['HOME']) }
  let(:homesync_path) { home.join("Dropbox/HomeSync") }

  before do
    setup_fixtures
    @stdout, @stderr = capture_io(stdin) { homesync "#{command} #{args}" }
  end

  describe '#setup' do

    let(:command) { "setup" }

    let(:launch_agent_path) { Pathname.new(File.expand_path("~/Library/LaunchAgents/com.icanscale.homesync.plist")) }
    let(:launch_agent) { launch_agent_path.read }

    shared_examples_for "a launch agent" do
      specify { launch_agent_path.should exist }
      specify { launch_agent.should =~ %r{<string>#{ENV['HOME']}/Library/Preferences</string>} }
      specify { launch_agent.should =~ %r{<string>#{homesync_path}/Library/Preferences</string>} }
    end

    shared_examples_for "a launch agent generator" do
      context "when launch agent doesn't exist" do
        specify { stdout.should include("Created Launch Agent") }
        it_should_behave_like "a launch agent"
      end

      context "when launch agent exists with same content" do
        before do
          @stdout, @stderr = capture_io { homesync "#{command} #{args}" }
        end

        specify { stdout.should include("Launch Agent already exists") }
        it_should_behave_like "a launch agent"
      end

      context "when launch agent exists with different content" do
        before do
          launch_agent_path.dirname.mkpath
          File.open(launch_agent_path, "w") { |f| f.write("x") }
          @stdout, @stderr = capture_io { homesync "#{command} #{args}" }
        end

        specify { stdout.should include("Updated Launch Agent") }
        it_should_behave_like "a launch agent"
      end
    end

    context "without options" do
      it_should_behave_like "a launch agent generator"
    end

    context "with -p option" do
      let(:args) { "-p ~/DB/HS" }
      let(:homesync_path) { home.join("DB/HS") }

      it_should_behave_like "a launch agent generator"

      context "creates configuration file to store homesync path" do
        specify { stdout.should include("Configuration written to") }
        specify { YAML.load_file(File.expand_path("~/.homesync"))['homesync_path'].should == "~/DB/HS" }
      end
    end

  end

  describe '#sync' do

    let(:command) { "sync" }

    context "when argument is not under user's home" do
      let(:args) { "/bin/bash" }
      specify { stderr.should include("is not inside your home directory") }
    end

    context "when argument doesn't exist" do
      context "and matching file in homesync doesn't exist either" do
        let(:args) { "~/404" }
        specify { stderr.should include("doesn't exist") }
      end

      context "but matching file in homesync does" do
        let(:args) { "~/todo.txt" }
        let(:todo) { home.join("todo.txt") }

        specify { stdout.should include("Created link to #{ENV['HOME']}/Dropbox/HomeSync/todo.txt") }

        it "should create a link to the file in HomeSync" do
          todo.readlink.should == homesync_path.join("todo.txt")
        end
      end
    end

    context "when argument is a link to the matching homesync file" do
      let(:args) { "~/synced" }
      specify { stderr.should include("is already syncing") }
    end

    context "when argument is a link to somewhere else" do
      let(:args) { "~/existing_link" }
      specify { stderr.should include("is a symlink pointing somewhere else") }
    end

    context "when argument is a regular file" do
      context "and matching file in homesync doesn't exist" do
        let(:args) { "~/Code/hello_world.rb" }
        let(:original_file) { home.join("Code/hello_world.rb") }
        let(:homesync_file) { homesync_path.join("Code/hello_world.rb") }

        specify { stdout.should include("Moved #{original_file} to HomeSync and created a symlink to it") }

        it "should move the original file to HomeSync" do
          homesync_file.should be_file
        end

        it "should create a link to the file in HomeSync" do
          original_file.readlink.should == homesync_file
        end
      end

      context "and matching file in homesync also exists" do
        let(:args) { "~/bin/colors" }
        let(:local_path) { home.join("bin/colors") }
        let(:sync_path) { homesync_path.join("bin/colors") }
        let(:contents) { File.read(local_path) }

        context "without options" do
          context "answering Yes to overwrite local" do
            let(:stdin) { "y\n" }

            specify { stdout.should include("Overwrite #{local_path}?") }
            specify { stdout.should include("Replaced #{local_path} with symlink to #{sync_path}") }

            it "should create a link to the file in HomeSync" do
              local_path.readlink.should == sync_path
            end

            it "should keep the HomeSync version of the file" do
              contents.should include("with numbers")
            end
          end

          context "answering No to overwrite local and Yes to overwrite HomeSync" do
            let(:stdin) { "n\ny\n" }

            specify { stdout.should include("Overwrite #{local_path}?") }
            specify { stdout.should include("Overwrite #{sync_path}?") }
            specify { stdout.should include("Replaced #{sync_path} with local version and created symlink to it") }

            it "should create a link to the file in HomeSync" do
              local_path.readlink.should == sync_path
            end

            it "should keep the local version of the file" do
              contents.should include("with color names")
            end
          end

          context "answering No both to overwrite local and HomeSync" do
            let(:stdin) { "n\nn\n" }

            specify { stdout.should include("Overwrite #{local_path}?") }
            specify { stdout.should include("Overwrite #{sync_path}?") }
            specify { stdout.should include("Kept both versions, syncing has been cancelled") }

            it "should keep the local file in place" do
              contents.should include("with color names")
            end

            it "should keep the HomeSync version of the file" do
              File.read(sync_path).should include("with numbers")
            end
          end
        end

        context "using --overwrite-local option" do
          let(:args) { "~/bin/colors --overwrite-local" }

          specify { stdout.should include("Replaced #{local_path} with symlink to #{sync_path}") }

          it "should create a link to the file in HomeSync" do
            local_path.readlink.should == sync_path
          end

          it "should keep the HomeSync version of the file" do
            contents.should include("with numbers")
          end
        end

        context "using --overwrite-homesync option" do
          let(:args) { "~/bin/colors --overwrite-homesync" }

          specify { stdout.should include("Replaced #{sync_path} with local version and created symlink to it") }

          it "should create a link to the file in HomeSync" do
            local_path.readlink.should == sync_path
          end

          it "should keep the local version of the file" do
            contents.should include("with color names")
          end
        end

        context "using both --overwrite-local and --overwrite-homesync options" do
          # this does not make any sense
          let(:args) { "~/bin/colors --overwrite-local --overwrite-homesync" }
          specify { stderr.should include("--overwrite-local and --overwrite-homesync cannot be used together") }
        end
      end
    end

    context "when argument is a directory" do
      context "and matching directory in homesync doesn't exist" do
        let(:args) { "~/Code/hello_world" }
        let(:original_dir) { home.join("Code/hello_world") }
        let(:homesync_dir) { homesync_path.join("Code/hello_world") }

        specify { stdout.should include("Moved #{original_dir} to HomeSync and created a symlink to it") }

        it "should move the original directory to HomeSync" do
          homesync_dir.should be_directory
        end

        it "should create a link to the directory in HomeSync" do
          original_dir.readlink.should == homesync_dir
        end
      end

      context "and matching directory in homesync also exists" do
        let(:args) { "~/tasks" }
        let(:local_path) { home.join("tasks") }
        let(:sync_path) { homesync_path.join("tasks") }
        let(:dir_entries) { local_path.entries.map(&:basename).map(&:to_s) - %w(. ..) }

        context "using --overwrite-local option" do
          let(:args) { "~/tasks --overwrite-local" }

          specify { stdout.should include("Replaced #{local_path} with symlink to #{sync_path}") }

          it "should create a link to the directory in HomeSync" do
            local_path.readlink.should == sync_path
          end

          it "should keep the HomeSync version of the directory" do
            dir_entries.should =~ %w(home work world_hunger)
          end
        end

        context "using --overwrite-homesync option" do
          let(:args) { "~/tasks --overwrite-homesync" }

          specify { stdout.should include("Replaced #{sync_path} with local version and created symlink to it") }

          it "should create a link to the directory in HomeSync" do
            local_path.readlink.should == sync_path
          end

          it "should keep the local version of the directory" do
            dir_entries.should =~ %w(home garden shopping)
          end
        end
      end
    end

    context "with custom homesync path" do
      context "provided by the -p option" do
      end

      context "stored in ~/.homesync configuration" do
      end
    end

  end

end
