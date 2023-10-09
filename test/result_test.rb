# frozen_string_literal: true

require "test_helper"

class ResultTest < ActiveSupport::TestCase
  class ChangeStatus < ActionMan::Base
    param :status

    def execute
      model.status = status
    end
  end

  class ChangeStatusAndReturnFalse < ActionMan::Base
    param :status

    def execute
      model.status = status
      false
    end
  end

  class ChangeStatusAndReturnFalseNotUseExecution < ChangeStatusAndReturnFalse
    self.use_execution_return = false
  end

  class Example < BaseExample
    action :change_status, "ResultTest::ChangeStatus"
  end

  class ExampleWithFalseReturn < BaseExample
    action :change_status, "ResultTest::ChangeStatusAndReturnFalse"
  end

  class ExampleWithFalseReturnNotUseExecution < BaseExample
    action :change_status, "ResultTest::ChangeStatusAndReturnFalseNotUseExecution"
  end

  test "returns success result" do
    model = Example.new

    result = model.change_status(status: "active")

    assert_predicate result, :success?
    assert_predicate result.params, :empty?
    assert_equal "active", model.status
  end

  test "returns false result when execute returns false value if use_execution_return is true" do
    model = ExampleWithFalseReturn.new

    result = model.change_status(status: "active")

    assert_predicate result, :failure?
    assert_equal "active", model.status
  end

  test "returns true result when execute returns false value if use_execution_return is false" do
    model = ExampleWithFalseReturnNotUseExecution.new

    result = model.change_status(status: "active")

    assert_predicate result, :success?
    assert_equal "active", model.status
  end
end
