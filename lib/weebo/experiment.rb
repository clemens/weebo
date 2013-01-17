module Weebo
  class Experiment
    attr_reader :name, :code, :variation

    def self.from_params(params)
      experiment = Weebo.experiment_by_name(params[:gace_exp])
      return unless experiment.present?

      experiment.variation = params[:gace_var]
      experiment
    end

    def initialize(name, code)
      @name, @code = name, code
    end

    def original_requested?
      variation.blank?
    end

    def variation_requested?
      !original_requested?
    end

    def path
      Rails.root.join("app/experiments/#{name}")
    end

    def variation_path
      path.join(variation)
    end

    def variation=(variation)
      @variation = variations.include?(variation) ? variation : nil
    end

    def variations
      @variations ||= Dir["#{path}/*"].map { |path| File.basename(path) if File.directory?(path) }.compact
    end

    def add_variation_view_path(controller)
      controller.prepend_view_path(variation_path) if path.exist? && variation_path.exist?
    end

    def inject_experiment_js(controller)
      controller.response_body.each do |body_part|
        body_part.gsub! /<head([^>]*)?>/, <<-script
          <head\\1>
            <script>function utmx_section(){}function utmx(){}(function(){var
              k='#{code}',d=document,l=d.location,c=d.cookie;
              if(l.search.indexOf('utm_expid='+k)>0)return;
              function f(n){if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.
              indexOf(';',i);return escape(c.substring(i+n.length+1,j<0?c.
              length:j))}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;d.write(
              '<sc'+'ript src="'+'http'+(l.protocol=='https:'?'s://ssl':
              '://www')+'.google-analytics.com/ga_exp.js?'+'utmxkey='+k+
              '&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='+new Date().
              valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
              '" type="text/javascript" charset="utf-8"><\/sc'+'ript>')})();
            </script><script>utmx('url','A/B');</script>
        script
      end
    end
  end
end
