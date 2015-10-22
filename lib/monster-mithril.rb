require 'monster_mithril/version'
require 'monster_mithril/configuration'
require 'monster_mithril/renderer'
require 'monster_mithril/railtie'

module MonsterMithril
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield self.config
  end

  def self.root
    File.dirname __dir__
  end

  def self.js_root name
    File.join self.root, 'app', 'assets', 'javascripts', 'monster_mithril', name
  end

  class Engine < ::Rails::Engine
  end
end
