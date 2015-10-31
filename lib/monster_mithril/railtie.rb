module MonsterMithril
  class Railtie < Rails::Railtie
    initializer :monster_mithril do |app|
        require 'monster_mithril/helper_methods'
      ActionView::Base.send :include, MonsterMithril::HelperMethods
    end

    config.after_initialize do
      ActiveSupport.on_load(:action_controller) do
        require 'monster_mithril/controller_methods'
        include MonsterMithril::ControllerMethods
      end
    end
  end
end

