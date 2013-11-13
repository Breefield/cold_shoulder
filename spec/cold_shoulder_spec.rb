require 'spec_helper'

module ActiveModel
  module Validations

    # Email addresses
    shared_examples :email_addresses do |boolean|
      it "finds the email address 'dustin.hoffman@breefield.com'" do
        @record = TestRecord.new('Email me at dustin.hoffman@breefield.com')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the email address 'dustin.hoffman [ a  t ] breefield.com'" do
        @record = TestRecord.new('Email me at dustin.hoffman [ at ] breefield.com')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the email address 'dustin.hoffman at breefield.com'" do
        @record = TestRecord.new('Email me at dustin.hoffman at breefield.com')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "doesn't think the following is an email address: 'let's meet at 2pm'" do
        @record = TestRecord.new('Lets meet at 2pm')
        expect(@record.valid?).to be_true
      end
    end

    # Phone numbers
    shared_examples :phone_numbers do |boolean|
      it "finds the phone number '208 871 2069'" do
        @record = TestRecord.new('Call me at 208 871 2069')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the phone number '(208)871-2069'" do
        @record = TestRecord.new('Call me at (208)871-2069')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the phone number '+1 (208)871-2069'" do
        @record = TestRecord.new('Call me at +1 (208)871-2069')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the phone number '2 0 8 8 7 1 2 0 6 9'" do
        @record = TestRecord.new('Call me at 2 0 8 8 7 1 2 0 6 9')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "finds the phone number '2088712069' hidden by newlines and other bullshit" do
        @record = TestRecord.new("2\n0\n8\n8\n7 Rob Ford smoked crack while in office \n1\n2\n0\n6\n9")
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "doesn't think dollar amounts are phone numbers: '$1,000,000,000'" do
        @record = TestRecord.new('Do you want $1,000,000,000 kid?')
        expect(@record.valid?).to be_true
      end
    end

    # Twitter handles
    shared_examples :twitter_handles do |boolean|
      it "finds a Twitter handle '@breefield'" do
        @record = TestRecord.new('Message me at @breefield on Twitter')
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "doesn't match arbitrary @ symbols followed by digits" do
        @record = TestRecord.new("Let's meet @ 2pm")
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end

      it "doesn't match arbitrary @ followed by non-digits" do
        @record = TestRecord.new("Let's meet @ the Standard")
        expect(@record.valid?).to (boolean ? be_true : be_false)
      end
    end

    describe 'cold_shoulder' do

      # Ensure the Test Record is fresh
      before do
        TestRecord.reset_callbacks(:validate)
      end

      context do
        before :each do
          TestRecord.validates :body, cold_shoulder: true
        end

        include_examples :twitter_handles, false
        include_examples :phone_numbers, false
        include_examples :email_addresses, false
      end

      context '(ignoring all)' do
        before :each do
          TestRecord.validates :body, cold_shoulder: {
            ignore_twitter: true,
            ignore_phone: true,
            ignore_email: true
          }
        end

        include_examples :twitter_handles, true
        include_examples :phone_numbers, true
        include_examples :email_addresses, true
      end

    end
    
  end
end