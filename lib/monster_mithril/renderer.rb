module MonsterMithril
  class Renderer
    attr_accessor :js
    def initialize scp, data, param={}
      collect_js
      preload_data data
      preload_param param
      self.js << "return render(app.#{scp.sub(/\//,'.')}.view(new app.#{scp.sub(/\//,'.')}.controller))"
    end

    def to_s
      html = nil
      html = ::ExecJS.exec self.js
      html.html_safe
    end

    def require_tree name
      tree  = Dir.glob(Rails.root.join('app','assets','javascripts',name,'**','*').to_s)
      tree.each do |file|
        self.js << render_coffee(file) if file.match(/coffee$/)
      end
    end

    def requires files
      lib  = Rails.root.join('app','assets','javascripts').to_s
      files = [files] if files.is_a?(String)
      files.each do |l|
        p = l[0] == '/' ? '' : lib+'/'
        n = l.match(/coffee$/) ? render_coffee("#{p}#{l}") :  IO.read("#{p}#{l}")
        self.js << n
      end
    end

    def preload_data data
      self.js << "_iso_preload = {};\n"
      if data
        data.each do |key,json|
          self.js << "_iso_preload['#{key}'] = #{json};\n"
        end
      end
    end

    def preload_param param
      self.js << "_iso_param = {};\n"
      param.each do |key,val|
        n = val.nil? ? 'null' : "'#{val}'"
        self.js << "_iso_param['#{key}'] = #{n};\n"
      end
    end

    def collect_js
      iso = Rails.cache.fetch('iso_data')
      if iso
        self.js = iso
      else
        self.js = 'var window = {};'
        requires [MonsterMithril.js_root('isostrap.coffee')]
        requires MonsterMithril.config.requires_before
        requires [
          MonsterMithril.js_root('mithril.js'),
          MonsterMithril.js_root('api_base.coffee'),
          MonsterMithril.js_root('monster.coffee'),
          MonsterMithril.js_root('render.js')
         ]
        requires requires MonsterMithril.config.requires_after
        MonsterMithril.config.requires_tree.each do |tree|
          require_tree tree
        end
        Rails.cache.write 'iso_data', self.js
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
