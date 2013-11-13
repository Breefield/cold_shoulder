require 'test_helper'

module ActiveModel
  module Validations

    describe DateValidator do

      before do
        TestMessageRecord.reset_callbacks(:validate)
      end
    end
  end
end