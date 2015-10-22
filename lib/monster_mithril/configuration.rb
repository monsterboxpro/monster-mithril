module MonsterMithril
  class Configuration
    attr_accessor :requires_before,
                  :requires_after,
                  :render
    def initialize
      self.requires_before ||= []
      self.requires_after  ||= []
      self.render          ||= 'pages/home'
    end
  end
end
