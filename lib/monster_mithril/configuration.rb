module MonsterMithril
  class Configuration
    attr_accessor :requires_before,
                  :requires_after,
                  :requires_tree,
                  :render
    def initialize
      self.requires_before ||= []
      self.requires_after  ||= []
      self.requires_tree   ||= %w{models filters controllers views}
      self.render          ||= 'pages/home'
    end
  end
end
