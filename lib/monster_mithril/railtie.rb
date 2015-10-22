module MonsterMithril
  class Railtie < Rails::Railtie
    initializer 'monster_mithril.middleware.rails' do |app|
      require 'monster_mithril/rails'
      app.config.middleware.insert_after MonsterMithril::Rails
    end

    config.after_initialize do
      ActiveSupport.on_load(:action_controller) do
        require 'monster_mithril/controller_methods'
        include MonsterMithril::ControllerMethods
      end
    end
  end
end

