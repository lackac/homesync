require 'spec_helper'

describe HomeSync::CLI do

  let(:stdout) { @stdout }
  let(:stderr) { @stderr }
  let(:command) { "" }
  let(:args) { "" }
  let(:home) { Pathname.new(ENV['HOME']) }
  let(:homesync_path) { home.join("Dropbox/HomeSync") }

  before do
    setup_fixtures
    @stdout, @stderr = capture_io { homesync "#{command} #{args}" }
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
        specify { stdout.should include("Launch Agent created") }
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

        specify { stdout.should include("Launch Agent updated") }
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
          todo.should be_symlink
          todo.readlink.should == homesync_path.join("todo.txt")
        end
      end
    end

    context "when argument is a link to the matching homesync file" do
    end

    context "when argument is a link to somewhere else" do
    end

    context "when argument is a regular file" do
      context "and matching file in homesync doesn't exist" do
      end

      context "but matching file in homesync already exists" do

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
