module Weebo
  class Railtie < Rails::Railtie
    initializer 'weebo' do |app|
      ActiveSupport.on_load(:action_controller) do
        Weebo::Railtie.setup_action_controller
      end

      experiments_path = Rails.root.join('app/experiments')
      Rails.application.config.autoload_paths += [experiments_path]

      Dir["#{experiments_path}/*.rb"].each do |experiment_file|
        require experiment_file
      end
    end

    def self.setup_action_controller
      ActionController::Base.class_eval do
        before_filter :weebo_add_variation_view_path
        after_filter :weebo_inject_experiment_js

      private

        def weebo_experiment
          @weebo_experiment ||= Weebo::Experiment.from_params(params)
        end
        helper_method :weebo_experiment

        def weebo_experiment?
          weebo_experiment.present?
        end
        helper_method :weebo_experiment?

        def weebo_add_variation_view_path
          return unless weebo_experiment? && weebo_experiment.variation_requested?
          weebo_experiment.add_variation_view_path(self)
        end

        def weebo_inject_experiment_js
          return unless weebo_experiment? && weebo_experiment.original_requested?
          weebo_experiment.inject_experiment_js(self)
        end
      end
    end
  end
end
