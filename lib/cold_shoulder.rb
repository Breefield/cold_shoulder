require 'active_model'
require 'active_model/validations'

module ActiveModel
  module Validations

    # Extend the rails each validator so that this can be used like any Rails validator
    class ColdShoulderValidator < EachValidator
      def validate_each(record, attr_name, value)

        # These are somewhat simplistic
        # Main problem being that all of them can be sidestepped by including commas
        # TODO: Move this outside the validate_each method so we don't define it over and over
        twitter_regex = /@([A-Za-z0-9_]{1,15})/i
        formatted_phone_regex = /(?:\+?(\d{1,3}))?[- (]*(\d{3})[- )]*(\d{3})[- ]*(\d{4})(?: *x(\d+))?\b/i
        email_regex = /.+(\@|a\s*t).+\..+/i

        globbed_value = value.gsub ' ', ''
        bullshit_free_phone = value.gsub /[^0-9,]|\n/i, ''

        # Twitter handles
        if twitter_regex.match(globbed_value) && !options[:ignore_twitter]
          record.errors.add(attr_name, :contains_twitter_handle, options)
        end

        # Phone numbers with bullshit
        if (formatted_phone_regex.match(globbed_value) && !options[:ignore_phone]) or
          (formatted_phone_regex.match(bullshit_free_phone) && !options[:ignore_phone])
          record.errors.add(attr_name, :contains_phone_number, options)
        end

        # Email addys
        if email_regex.match(value) && !options[:ignore_email]
          record.errors.add(attr_name, :contains_email_address)
        end
      end

      module HelperMethods
        # Validates that the specified attributes do not contain contact information. 
        # Happens by default on save.
        #
        #   class Message < ActiveRecord::Base
        #     validates_no_contact_in :body
        #   end

        def validates_with_cold_shouldr(*attr_names)
          validates_with ColdShoulderValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end