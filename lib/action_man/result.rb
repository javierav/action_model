# frozen_string_literal: true

module ActionMan
  class Result
    attr_reader :status, :params, :errors, :output

    class << self
      def success(params: {}, output: nil)
        new(:success, params:, output:)
      end

      def failure(errors: {}, output: nil)
        new(:failure, errors:, output:)
      end
    end

    def initialize(status, params: {}, errors: {}, output: nil)
      @status = status.to_sym
      @params = params
      @errors = errors
      @output = output
    end

    def success?
      @status == :success
    end

    def failure?
      @status == :failure
    end
  end
end
