module MonsterMithril
  class Renderer
    attr_accessor :js
    def initialize nsp, scp, data, param={}, init={}
      collect_js nsp.to_sym
      preload_data data
      preload_init init
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

    def preload_init init
      self.js << "var _init  = #{init.to_json};"
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

    def collect_js nsp
      iso = Rails.cache.fetch('iso_data')
      if iso
        self.js = iso
      else
        self.js = 'var window = {};'
        requires [MonsterMithril.js_root('isostrap.coffee')]
        requires MonsterMithril.config.namespaces[nsp].requires_before
        requires [
          MonsterMithril.js_root('mithril.js'),
          MonsterMithril.js_root('monster.coffee'),
          #core ---------------------------------------
          MonsterMithril.js_root('core/api.coffee'),
          MonsterMithril.js_root('core/comp.coffee'),
          MonsterMithril.js_root('core/controller.coffee'),
          MonsterMithril.js_root('core/dom.coffee'),
          MonsterMithril.js_root('core/events.coffee'),
          MonsterMithril.js_root('core/filter.coffee'),
          MonsterMithril.js_root('core/layout.coffee'),
          MonsterMithril.js_root('core/model.coffee'),
          MonsterMithril.js_root('core/popup.coffee'),
          MonsterMithril.js_root('core/service.coffee'),
          MonsterMithril.js_root('core/util.coffee'),
          MonsterMithril.js_root('core/view.coffee'),
          #helpers ------------------------------------
          MonsterMithril.js_root('helpers/form.coffee'),
          MonsterMithril.js_root('helpers/list.coffee'),
          MonsterMithril.js_root('helpers/popup.coffee'),
          MonsterMithril.js_root('helpers/show.coffee'),
          #virtual node render ------------------------
          MonsterMithril.js_root('render.js')
         ]
        requires MonsterMithril.config.namespaces[nsp].requires_after
        MonsterMithril.config.namespaces[nsp].requires_tree.each do |tree|
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
