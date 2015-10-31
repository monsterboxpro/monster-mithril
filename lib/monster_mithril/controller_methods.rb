module MonsterMithril
  module ControllerMethods
    def mithril scp, data, param={}
      @_isomorph = MonsterMithril::Renderer.new scp, data, param, @_init
      render MonsterMithril.config.render
    end
  end
end
