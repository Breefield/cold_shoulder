require 'spec_helper'

module ActiveModel
  module Validations

    describe ColdShoulderValidator, "#score" do

      # Ensure the Test Record is fresh
      before do
        TestRecord.reset_callbacks(:validate)
      end

      it "finds Twitter handles" do
        TestRecord.validates :body, :contacts => false
        expect(TestRecord.new('Message me at @breefield on Twitter').valid?).to be_false
      end

    end
    
  end
end