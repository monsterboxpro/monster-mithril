module MonsterMithril
  module ControllerMethods
    def mithril scp, data, param={}
      nsp  = self.class.to_s =~ /::/ ? name.split("::").first.underscore : 'application'
      @_isomorph = MonsterMithril::Renderer.new nsp, scp, data, param, @_init
      render MonsterMithril.config.namespaces[nsp.to_sym].render
    end
  end
end
