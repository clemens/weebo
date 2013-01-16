module Weebo
  require 'weebo/railtie' if defined?(Rails)

  autoload :Experiment,    'weebo/experiment'
  autoload :RoutingFilter, 'weebo/routing_filter'

  class << self
    def experiments
      @experiments ||= {}
    end

    def experiment_by_name(name)
      return unless name.present?
      experiments[name.to_sym]
    end

    def experiment(options = {})
      options = options.symbolize_keys!
      path, name, code = options.values_at(:path, :name, :code)
      raise ArgumentError.new('must define :path') unless path.present?
      raise ArgumentError.new('must define :name') unless name.present?
      raise ArgumentError.new('must define :code') unless code.present?

      experiments[name.to_sym] = Experiment.new(name.to_s, code)
      RoutingFilter.set_for(path, name)
    end
  end
end
