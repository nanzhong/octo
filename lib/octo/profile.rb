require 'octo'

module Octo::Profile
  attr_reader :config

  def config_file
    "#{Dir.home}/.octorc"
  end

  def profile_exists?(type, profile)
    @config[type].keys.include? profile
  end

  def list(type, profile = nil)
    if profile.nil?
      @config[type].keys
    else
      @config[type].each do |name, servers|
        if name == profile
          return servers
        end
      end

      return nil
    end
  end

  def add(type, profile, server)
    @config[type][profile] = [] if @config[type][profile].nil?
    @config[type][profile] << server
  end

  def rm(type, profile, server)
    @config[type][profile].delete(server)
    @config[type].delete(profile) if @config[type][profile].empty?
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
