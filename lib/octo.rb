require 'yaml'
require 'net/ssh/multi'
require 'term/ansicolor'

class Octo
  require 'octo/profile'
  include Octo::Profile
  include Term::ANSIColor

  def initialize(options = {})
    @options = options.merge({
      file: false,
      multi: false
    })

    self.load
  end

  def run(profile, command)
    Net::SSH::Multi.start do |session|
      @config[profile].each do |server|
        session.use server
      end

      session.exec command do |ch, stream, data|
        data.lines.each do |line|
          stream = stream == :stderr ? $stderr : $stdout
          stream.puts "[#{green(ch.properties[:server].to_s)}] #{line}"
        end
      end
      session.loop
    end
  end
end
