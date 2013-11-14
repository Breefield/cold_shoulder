require 'active_model'
require 'active_model/validations'

require 'action_view'
require 'action_view/helpers/number_helper.rb'

module ColdShoulder
  if defined?(Rails)
    class Railtie < Rails::Railtie
      config.before_configuration do
        I18n.load_path << File.join(File.dirname(__FILE__), '../', 'locales', 'en.yml')
      end
    end
  end
end

# The validations
# TODO require in another file? This was failing when actually deployed through rubygems
module ActiveModel
  module Validations

    # Extend the rails each validator so that this can be used like any Rails validator
    class ColdShoulderValidator < EachValidator
      include ActionView::Helpers::NumberHelper if defined?(Rails)

      def validate_each(record, attr_name, value)

        # These are somewhat simplistic
        # Main problem being that all of them can be sidestepped by including commas
        # TODO: Move this outside the validate_each method so we don't define it over and over
        twitter_regex = /(@[A-Za-z0-9_]{1,15})/i
        formatted_phone_regex = /((?:\+?(\d{1,3}))?[- (]*(\d{3})[- )]*(\d{3})[- ]*(\d{4})(?: *x(\d+))?\b)/i
        email_regex = /(\b[^\s]+?\s*(@|at)\s*[^\s]+?\.[^\s]+?\b)/i # Very general so as to catch BS

        # Remove spaces (the most basic way to avoid these detections)
        globbed_value = value.gsub ' ', ''
        bullshit_free_phone = value.gsub /[^0-9,]|\n/i, ''

        # Look for matches
        twitter_handles = globbed_value.scan twitter_regex
        email_addresses = value.scan email_regex
        phone_numbers = globbed_value.scan(formatted_phone_regex).concat(
          bullshit_free_phone.scan(formatted_phone_regex)
        ).uniq

        # Phone numbers
        unless phone_numbers.empty? or options[:ignore_phone]
          record.errors.add(attr_name, :contains_phone_number, options.merge(
            phone_numbers: phone_numbers.map{ |p| 
              defined?(Rails) ? number_to_phone(p[0]) : p[0]
            }.join(', ')
          ))
        end

        # Email addys
        unless email_addresses.empty? or options[:ignore_email]
          record.errors.add(attr_name, :contains_email_address, options.merge(
            email_addresses: email_addresses.map{|p| p[0] }.join(', ')
          ))
        else

          # Twitter handles
          # Any email address is going to register twitter handles as well
          unless twitter_handles.empty? or options[:ignore_twitter]
            record.errors.add(attr_name, :contains_twitter_handle, options.merge(
              handles: twitter_handles.map{|p| p[0] }.join(', ')
            ))
          end

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