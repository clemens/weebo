require 'routing_filter'

module Weebo
  class RoutingFilter < ::RoutingFilter::Filter
    def self.set_for(target_path, name)
      filter = Class.new(Weebo::RoutingFilter)
      filter.class_eval <<-ruby
        def around_recognize(path, env, &block)
          yield.tap do |params|
            if #{target_path.inspect} === path
              params.merge!(:gace_exp => '#{name}')
            end
          end
        end
      ruby

      class_name = name.to_s.classify
      ::RoutingFilter.const_set(class_name.to_sym, filter)
      Rails.application.routes.prepend do
        filter class_name.underscore.to_sym
      end
    end

    def around_generate(params, &block)
      yield
    end
  end
end
