require 'yaml'
require 'net/ssh/multi'
require 'mysql2'
require 'terminal-table'
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

  def run_ssh(profile, command)
    Net::SSH::Multi.start do |session|
      @config['ssh'][profile].each do |server|
        session.use server
      end

      buffer = Hash.new("")
      session.exec command do |ch, stream, data|
        data.lines.each do |line|
          stream = stream == :stderr ? $stderr : $stdout
          buffer[ch] += line
        end
        lines = buffer[ch].split("\n")
        buffer[ch] = lines.pop
        lines.each do |line|
          stream.puts "[#{green(ch.properties[:server].to_s)}] #{line}"
        end
      end
      session.loop
    end
  end

  def run_mysql(profile, query)
    @config['mysql'][profile].each do |server|
      print "Running query on #{server}... "

      begin
        server_data = server.match(/(.+):(.+)@(.+)\/(.+)/)
        client = Mysql2::Client.new(username: server_data[1],
                                    password: server_data[2],
                                    host: server_data[3],
                                    database: server_data[4])

        results = client.query(query)
        puts "#{results.count} results"
        table = Terminal::Table.new(headings: results.fields) do |t|
          results.each(as: :array) do |row|
            t << row
          end
        end

        puts table
      rescue Exception => e
        puts "ERROR: #{e.inspect}"
      end
    end
  end
end
