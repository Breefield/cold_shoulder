require 'test_helper'

module ActiveModel
  module Validations

    describe ColdShoulder, "#score" do

      # Ensure the Test Record is fresh
      before do
        TestRecord.reset_callbacks(:validate)
      end

      it "finds Twitter handles" do
        TestRecord.validates :body, :contacts => false
        TestRecord.new('Message me at @breefield on Twitter').valid?.must_equal false
      end

    end

  end
end