module MonsterMithril
  class Configuration
    attr_accessor :namespaces

    def initialize
      self.namespaces = {}
    end

    def namespace name
      self.namespaces[name] = Namespace.new name
      yield self.namespaces[name]
    end
  end

  class Namespace
    attr_accessor :requires_before,
                  :requires_after,
                  :requires_tree,
                  :render
    def initialize name

      self.requires_before ||= []
      self.requires_after  ||= []
      self.requires_tree   ||= [
        "#{name}/models",
        "#{name}/filters",
        "#{name}/controllers",
        "#{name}/views"
      ]
      self.render ||= 'pages/home'
    end
  end
end
