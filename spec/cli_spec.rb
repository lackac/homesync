require 'spec_helper'

describe HomeSync::CLI do

  before do
    tmp_path = Pathname.new(__FILE__).dirname.join("../tmp/test").expand_path
    tmp_path.rmtree if tmp_path.exist?
    ENV['HOME'] = "#{tmp_path}/Users/Alice"
    Pathname.new("~/Dropbox").expand_path.mkpath
  end

  describe '#setup' do

    let(:launch_agent_path) { Pathname.new(File.expand_path("~/Library/LaunchAgents/com.icanscale.homesync.plist")) }
    let(:launch_agent) { launch_agent_path.read }

    shared_examples_for "a launch agent" do
      specify { launch_agent_path.should exist; launch_agent.should =~ /<string>/ }
      specify { launch_agent.should =~ %r{<string>#{ENV['HOME']}/Library/Preferences</string>} }
      specify { launch_agent.should =~ %r{<string>#{homesync_path}/Library/Preferences</string>} }
    end

    shared_examples_for "a launch agent generator" do
      context "when launch agent doesn't exist" do
        before do
          @output = capture(:stdout) { subject.setup }
        end

        specify { @output.should =~ /Launch Agent created/ }
        it_should_behave_like "a launch agent"
      end

      context "when launch agent exists with same content" do
        before do
          silence(:stdout) { subject.setup }
          @output = capture(:stdout) { subject.setup }
        end

        specify { @output.should =~ /Launch Agent already exists/ }
        it_should_behave_like "a launch agent"
      end

      context "when launch agent exists with different content" do
        before do
          launch_agent_path.dirname.mkpath
          File.open(launch_agent_path, "w") { |f| f.write("x") }
          @output = capture(:stdout) { subject.setup }
        end

        specify { @output.should =~ /Launch Agent updated/ }
        it_should_behave_like "a launch agent"
      end
    end

    context "without options" do
      let(:homesync_path) { "#{ENV['HOME']}/Dropbox/HomeSync" }

      it_should_behave_like "a launch agent generator"
    end

    context "with -p option" do
      subject { HomeSync::CLI.new([], :homesync_path => "~/DB/HS") }
      let(:homesync_path) { "#{ENV['HOME']}/DB/HS" }

      it_should_behave_like "a launch agent generator"

      context "creates configuration file to store homesync path" do
        before do
          @output = capture(:stdout) { subject.setup }
        end

        specify { YAML.load_file(File.expand_path("~/.homesync"))['homesync_path'].should == "~/DB/HS" }
        specify { @output.should =~ /Configuration written to/ }
      end
    end

  end

end
