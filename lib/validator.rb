# For monkeypatch
require 'active_model'
require 'active_model/validations'

# For formatting phone numbers in errors
require 'action_view'
require 'action_view/helpers'

# The validations
# TODO require in another file? This was failing when actually deployed through rubygems
module ActiveModel
  module Validations

    # Extend the rails each validator so that this can be used like any Rails validator
    class ColdShoulderValidator < EachValidator
      include ActionView::Helpers::NumberHelper if defined?(Rails)

      # These are somewhat simplistic
      # Main problem being that all of them can be sidestepped by including commas
      TWITTER_REGEX = /(@[A-Za-z0-9_]{1,15})/i
      PHONE_REGEX = /((?:\+?(\d{1,3}))?[- (]*(\d{3})[- )]*(\d{3})[- ]*(\d{4})(?: *x(\d+))?\b)/i
      EMAIL_REGEX = /(\b[^\s]+?\s*(@|at)\s*[^\s]+?\.[^\s]+?\b)/i
      URL_REGEX = /\b(\S+?\.\S+?)\b/i

      def initialize(options)
        options[:ignore_link] = true if options[:remove_links]

        super
      end

      def validate_each(record, attr_name, value)

        # Detect any contact methods in the value
        detected = detect_contacts_in value

        # Add errors for detected methods,  If there is a message, skip adding errors
        errors = add_errors_to_record(record, attr_name, detected, {skip: options[:message]})

        # A base mesage might be used
        if errors and options[:message]
          record.errors.add(:base, options[:message])
        end

        # Strip URLs from the actual saved value
        if options[:remove_links]
          record[attr_name] = value.gsub URL_REGEX, ''
        end
      end

      def detect_contacts_in value
        # Remove spaces (the most basic way to avoid these detections)
        globbed_value = value.gsub ' ', ''
        # Remove any characters not numbers or commas (commas are for $1,000 formatted numbers
        bullshit_free_phone = value.gsub /[^0-9,]|\n/i, ''

        # Look for matches
        detected = {
          twitter:  globbed_value.scan(TWITTER_REGEX),
          email:    value.scan(EMAIL_REGEX),
          phone:    globbed_value.scan(PHONE_REGEX).concat(
            bullshit_free_phone.scan(PHONE_REGEX)
          ).uniq,
          link: value.scan(URL_REGEX)
        }
      end

      # Returns true or fase, if there were any errors at all
      # ops[:skip] can be used to skip adding the actual errors to the record
      # If we just want the boolean return value
      def add_errors_to_record record, attr_name, detected, ops={}
        # Catchall for base
        errors = false

        # Search for 
        [:twitter, :email, :phone, :link].each do |type|

          # Were there any matches, or are we ignoring this type
          unless detected[type].empty? or options["ignore_#{type}".to_sym]
            errors = true
            next if ops[:skip] # If a base message is set, don't add attr errors
            
            record.errors.add(attr_name, "contains_#{type}".to_sym, options.merge(
              detected: detected[type].map{ |p|
                # If this is a phone it gets formatted, otherwise no 
                type == :phone && defined?(Rails) ? number_to_phone(p[0], area_code: true) : p[0]
              }.join(', ')
            )) 
          end

        end
        return errors
      end

      module HelperMethods
        def validates_with_cold_shouldr(*attr_names)
          validates_with ColdShoulderValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end