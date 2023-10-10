# frozen_string_literal: true

require "test_helper"

class ExecutableTest < ActiveSupport::TestCase
  class DefaultChangeStatus < ActionMan::Base
  end

  class WithExecutableChangeStatus < ActionMan::Base
    param :status

    def executable?
      model.status == "inactive"
    end
  end

  class NotExecutableChangeStatus < ActionMan::Base
    self.exception_if_not_executable = true

    def executable?
      false
    end

    def execute; end
  end

  class DefaultExample < BaseExample
    action :change_status, "ExecutableTest::DefaultChangeStatus"
  end

  class WithExecutableExample < BaseExample
    action :change_status, "ExecutableTest::WithExecutableChangeStatus"
  end

  class NotExecutableExample < BaseExample
    action :change_status, "ExecutableTest::NotExecutableChangeStatus"
  end

  test "executable? returns true by default" do
    model = DefaultExample.new

    assert_predicate model, :change_status?
  end

  test "executable? returns false if can not be executed" do
    model = WithExecutableExample.new("active")

    assert_not model.change_status?
  end

  test "raise exception if executable? returns false and raise_exception_if_not_executable is true" do
    model = NotExecutableExample.new("active")

    assert_raise(ActionMan::NotExecutable) do
      model.change_status(status: "active")
    end
  end
end
