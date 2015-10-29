module MonsterMithril
  module ControllerMethods
    def mithril scp, data, param={}
      @_isomorph = MonsterMithril::Renderer.new scp, data, param
      render MonsterMithril.config.render
    end
  end
end
