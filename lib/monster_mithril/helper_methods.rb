module MonsterMithril
  module HelperMethods
    def iso_init_js
      js = @_init ? "#{@_init.to_json.gsub('/','\/')};".html_safe : "{};"
      @_isomorph + javascript_tag("var _init = #{js}")
    end
  end
end
