module MonsterMithril
  class Renderer
    def initialize scp, data, param={}
      @initial_data = { logged_in: logged_in? }
      collect_js
      preload_init
      preload_data data
      preload_param param

      @_isomorph << "return render(app.#{scp.sub(/\//,'.')}.view(new app.#{scp.sub(/\//,'.')}.controller))"
      #puts "[mithril] ".red +  @_isomorph
      html = nil
      html = ::ExecJS.exec @_isomorph
      @_isomorph = html.html_safe
    end

    def require_tree name
      tree  = Dir.glob(Rails.root.join('app','assets','javascripts',name,'**','*').to_s)
      tree.each do |file|
        @_isomorph << render_coffee(file) if file.match(/coffee$/)
      end
    end

    def requires files
      lib  = Rails.root.join('app','assets','javascripts').to_s
      files = [files] if files.is_a?(String)
      files.each do |l|
        n = l.match(/coffee$/) ? render_coffee(lib+"/#{l}") :  IO.read(lib+"/#{l}")
        @_isomorph << n
      end
    end

    def preload_data data
      @_isomorph << "app.preload = {};"
      if data
        data.each do |key,json|
          @_isomorph << "app.preload['#{key}'] = #{json};"
        end
      end
    end

    def preload_param param
      @_isomorph << "app.param = {};"
      param.each do |key,val|
        n = val.nil? ? 'null' : "'#{val}'"
        @_isomorph << "app.param['#{key}'] = #{n};"
      end
    end

    def preload_init
      @_isomorph << "var _initial_data = #{@initial_data.to_json};"
    end

    def collect_js
      iso = Rails.cache.fetch('iso_data')
      if iso
        @_isomorph = iso
      else
        @_isomorph = 'var window = {};'
        requires %w{lib/isostrap.coffee}
        requires self.config.requires_before
        requires %w{
          lib/mithril.js
          lib/mithril-monster.coffee
          lib/mithril-render.js
        }
        requires requires self.config.requires_after
        require_tree 'helpers'
        require_tree 'controllers'
        Rails.cache.write 'iso_data', @_isomorph
      end
    end

    def render_coffee path
      Tilt::CoffeeScriptTemplate.default_bare = true
      data = IO.read path
      template = Tilt::CoffeeScriptTemplate.new { data }
      Tilt::CoffeeScriptTemplate.default_bare = false
      template.render
    end
  end

end

