module MonsterMithril
  module ControllerMethods
    def mithril scp, data, param={}
      @_isomorph = MonsterMithril::Renderer.new scp, data, params
      render MonsterMithril.config.render
    end
  end
end

