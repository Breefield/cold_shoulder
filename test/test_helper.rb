require 'test/unit'

require 'active_support/core_ext'
require 'active_model'
require 'cold_shoulder'

class TestMessageRecord
  include ActiveModel::Validations
  attr_accessor :body

  def initialize(expiration_date)
    @body = body
  end
end