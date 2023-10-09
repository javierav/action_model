require "active_support/callbacks"
require "active_support/core_ext/array/wrap"
require_relative "not_executable"
require_relative "result"

module ActionMan
  class Base
    include ActiveSupport::Callbacks

    RESULT_TYPES = %i[success failure].freeze

    class_attribute :transaction, default: true
    class_attribute :exception_if_not_executable, default: false
    class_attribute :use_execution_return, default: true

    attr_reader :model, :args, :params, :result

    define_callbacks :execute

    class << self
      def before(*filters, &blk)
        set_callback(:execute, :before, *filters, &blk)
      end

      def after(*filters, &blk)
        set_options_for_callbacks!(filters)
        set_callback(:execute, :after, *filters, &blk)
      end

      def after_success(*filters, &blk)
        set_options_for_callbacks!(filters, on: :success)
        set_callback(:execute, :after, *filters, &blk)
      end

      def after_failure(*filters, &blk)
        set_options_for_callbacks!(filters, on: :failure)
        set_callback(:execute, :after, *filters, &blk)
      end

      def param(name)
        define_method(name) do
          params[name]
        end
      end

      def params(*names)
        names.each { |name| param(name) }
      end

      def model(name)
        define_method(name) do
          model
        end
      end

      private

        def set_options_for_callbacks!(args, enforced_options = {})
          options = args.extract_options!.merge!(enforced_options)
          args << options

          if options[:on]
            fire_on = Array.wrap(options[:on])
            assert_valid_execute_on(fire_on)
            options[:if] = [
              -> { fire_on.any? { |on| on.to_sym == result.status.to_sym } },
              *options[:if]
            ]
          end
        end

        def assert_valid_execute_on(actions)
          if (actions - RESULT_TYPES).any?
            raise ArgumentError, ":on conditions for after callbacks have to be one of #{RESULT_TYPES}"
          end
        end
    end

    def initialize(model)
      @model = model
      @params = {}
    end

    def executable?
      true
    end

    def run(params = {})
      @params = params

      if executable?
        with_transaction do
          run_callbacks(:execute) do
            run_execute
          end
        end

        result
      elsif exception_if_not_executable
        raise NotExecutable
      else
        Result.failure
      end
    end

    private

      def execute
        raise NotImplementedError
      end

      def success!(params = {})
        throw :finish, Result.success(params:)
      end

      def failure!(errors = {})
        throw :finish, Result.failure(errors:)
      end

      def with_transaction(&block)
        if transaction && defined?(ActiveRecord::Base)
          ActiveRecord::Base.transaction do
            block.call

            raise ActiveRecord::Rollback if result.failure?
          end
        else
          block.call
        end
      end

      def run_execute
        response = catch :finish do
          execute
        end

        @result = convert_to_result(response)
      end

    def convert_to_result(response)
      if response.is_a?(Result)
        response
      elsif use_execution_return && !response
        Result.failure
      else
        Result.success
      end
    end
  end
end
