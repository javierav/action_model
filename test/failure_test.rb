# frozen_string_literal: true

require "test_helper"

class FailureTest < ActiveSupport::TestCase
  class ChangeStatusWithDefault < ActionMan::Base
    param :status

    after_success :after_change_status_success
    after_failure :after_change_status_failure

    def execute
      false
    end

    def after_change_status_success
      model.status = "success"
    end

    def after_change_status_failure
      model.status = "failure"
    end
  end

  class ChangeStatusWithFailure < ActionMan::Base
    param :status

    after_success :after_change_status_success
    after_failure :after_change_status_failure

    def execute
      failure! status: "can not be changed"
      true
    end

    def after_change_status_success
      model.status = "success"
    end

    def after_change_status_failure
      model.status = "failure"
    end
  end

  class ChangeStatusWithDefaultExample < BaseExample
    action :change_status, "FailureTest::ChangeStatusWithDefault"
  end

  class ChangeStatusWithFailureExample < BaseExample
    action :change_status, "FailureTest::ChangeStatusWithFailure"
  end

  test "executes after_failure callback" do
    model = ChangeStatusWithDefaultExample.new

    result = model.change_status(status: "active")

    assert_predicate result, :failure?
    assert_equal "failure", model.status
  end

  test "executes after_failure callback when call failure!" do
    model = ChangeStatusWithFailureExample.new

    result = model.change_status(status: "active")

    assert_predicate result, :failure?
    assert_equal "failure", model.status
  end
end
