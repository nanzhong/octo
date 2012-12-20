require 'octo'

module Octo::Profile
  attr_reader :config

  def config_file
    "#{Dir.home}/.octorc"
  end

  def list(profile = nil)
    if profile.nil?
      @config.keys
    else
      @config[profile]
    end
  end

  def add(profile, server)
    @config[profile] = [] if @config[profile].nil?
    @config[profile] << server
  end

  def rm(profile, server)
    @config[profile].delete(server)
    @config.delete(profile) if @config[profile].empty?
  end

  def load
    if File.exists?(config_file)
      @config = YAML.load_file(config_file)
    else
      @config = {}
    end
  end

  def save
    File.open(config_file, 'w') do |f|
      f.write YAML.dump(@config)
    end
  end
end
