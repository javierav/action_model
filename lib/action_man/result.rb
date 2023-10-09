module ActionMan
  class Result
    attr_reader :status, :params, :errors

    class << self
      def success(params: {})
        new(:success, params: params)
      end

      def failure(errors: {})
        new(:failure, errors: errors)
      end
    end

    def initialize(status, params: {}, errors: {})
      @status = status.to_sym
      @params = params
      @errors = errors
    end

    def success?
      @status == :success
    end

    def failure?
      @status == :failure
    end
  end
end
