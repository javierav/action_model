# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "action_man"
require "active_support"
require "minitest/autorun"
# require_relative "examples"

class BaseExample
  include ActionMan::Model

  attr_accessor :status

  def initialize(status="inactive")
    @status = status
  end
end
