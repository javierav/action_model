# frozen_string_literal: true

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

    attr_reader :model, :args, :params, :result

    define_callbacks :execute

    class << self
      def before(...)
        set_callback(:execute, :before, ...)
      end

      def after(*filters, &)
        set_options_for_callbacks!(filters)
        set_callback(:execute, :after, *filters, &)
      end

      def after_success(*filters, &)
        set_options_for_callbacks!(filters, on: :success)
        set_callback(:execute, :after, *filters, &)
      end

      def after_failure(*filters, &)
        set_options_for_callbacks!(filters, on: :failure)
        set_callback(:execute, :after, *filters, &)
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

        def set_options_for_callbacks!(args, enforced_options={})
          options = args.extract_options!.merge!(enforced_options)
          args << options

          return unless options[:on]

          fire_on = Array.wrap(options[:on])
          assert_valid_execute_on(fire_on)
          options[:if] = [
            -> { fire_on.any? { |on| on.to_sym == result.status.to_sym } },
            *options[:if]
          ]
        end

        def assert_valid_execute_on(actions)
          return unless (actions - RESULT_TYPES).any?

          raise ArgumentError, ":on conditions for after callbacks have to be one of #{RESULT_TYPES}"
        end
    end

    def initialize(model)
      @model = model
      @params = {}
    end

    def executable?
      true
    end

    def run(params={})
      @params = params

      if executable?
        run_execute
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

      def success!(params={})
        throw :finish, Result.success(params:)
      end

      def failure!(errors={})
        throw :finish, Result.failure(errors:)
      end

      def finish!(value)
        value ? success! : failure!
      end

      def run_execute
        with_transaction do
          run_callbacks(:execute) do
            run_with_catch
          end
        end

        result
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

      def run_with_catch
        response = catch :finish do
          execute
        end

        @result = response.is_a?(Result) ? response : Result.success(output: response)
      end
  end
end
