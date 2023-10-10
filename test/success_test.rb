# frozen_string_literal: true

require "test_helper"

class SuccessTest < ActiveSupport::TestCase
  class ChangeStatusWithDefault < ActionMan::Base
    param :status

    after_success :after_change_status_success
    after_failure :after_change_status_failure

    def execute
      model.status = status
    end

    def after_change_status_success
      model.status = "success"
    end

    def after_change_status_failure
      model.status = "failure"
    end
  end

  class ChangeStatusWithSuccess < ActionMan::Base
    param :status

    before :store_previous_status
    after_success :after_change_status_success
    after_failure :after_change_status_failure

    def execute
      success! previous_status: @previous_status
    end

    def store_previous_status
      @previous_status = model.status
    end

    def after_change_status_success
      model.status = "success"
    end

    def after_change_status_failure
      model.status = "failure"
    end
  end

  class ChangeStatusWithDefaultExample < BaseExample
    action :change_status, "SuccessTest::ChangeStatusWithDefault"
  end

  class ChangeStatusWithSuccessExample < BaseExample
    action :change_status, "SuccessTest::ChangeStatusWithSuccess"
  end

  test "executes after_success callback with default result" do
    model = ChangeStatusWithDefaultExample.new

    result = model.change_status(status: "active")

    assert_predicate result, :success?
    assert_equal "success", model.status
    assert_equal "active", result.output
  end

  test "executes after_success callback when call success!" do
    model = ChangeStatusWithSuccessExample.new

    result = model.change_status(status: "active")

    assert_predicate result, :success?
    assert_equal "success", model.status
    assert_equal "inactive", result.params[:previous_status]
    assert_nil result.output
  end
end
