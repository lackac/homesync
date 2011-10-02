require 'homesync'
require 'stringio'

RSpec.configure do |config|
  config.color_enabled = true
  #config.filter_run :focus => true

  def capture_io
    begin
      $stdout = StringIO.new
      $stderr = StringIO.new
      yield
      result = [ $stdout.string, $stderr.string ]
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end
    result
  end

  alias :silence :capture_io
end

def homesync(arguments)
  HomeSync::CLI.start(arguments.split(/\s+/))
end

def setup_fixtures
  tmp_path = Pathname.new(__FILE__).dirname.join("../tmp/test").expand_path
  tmp_path.rmtree if tmp_path.exist?
  tmp_path.join("Users").mkpath
  ENV['HOME'] = "#{tmp_path}/Users/Alice"
  fixtures = Pathname.new(__FILE__).dirname.join("fixtures/home")
  %x{ cp -a #{fixtures} #{ENV['HOME']} }
end
