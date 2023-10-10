# frozen_string_literal: true

require "test_helper"

class ResultTest < ActiveSupport::TestCase
  class ChangeStatusImplicit < ActionMan::Base
    param :status

    def execute
      model.status = status
    end
  end

  class ImplicitExample < BaseExample
    action :change_status, "ResultTest::ChangeStatusImplicit"
  end

  test "returns success result" do
    model = ImplicitExample.new

    result = model.change_status(status: "active")

    assert_predicate result, :success?
    assert_predicate result.params, :empty?
    assert_equal "active", result.output
    assert_equal "active", model.status
  end
end
