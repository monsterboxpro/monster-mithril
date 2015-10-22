module MonsterMithril
  module ControllerMethods
    def mithril scp, data, param={}
      MonsterMithril::Renderer.new scp, data, params
      render 'pages/home'
    end
  end
end

