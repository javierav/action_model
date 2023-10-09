module ActionMan
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def action(action_name, class_name = nil)
        define_method(action_name) do |params|
          (class_name || self.class.action_class(action_name)).constantize.new(self).run(params)
        end

        define_method("#{action_name}?") do
          (class_name || self.class.action_class(action_name)).constantize.new(self).executable?
        end
      end

      def action_class(action_name)
        "#{name.pluralize}::#{action_name.to_s.camelcase}"
      end
    end
  end
end
