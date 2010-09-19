require 'homesync'
require 'stringio'

RSpec.configure do |config|
  config.color_enabled = true
  #config.filter_run :focus => true

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  alias :silence :capture
end
