# require 'damerau-levenshtein'

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

      NUMBER_WORDS = {one: 1, two: 2, three: 3, 
                      four: 4, five: 5, six: 6, seven: 7, 
                      eight: 9, nine: 9, zero: 0, oh: 0}

      def initialize(options)
        options[:ignore_link] = true if options[:remove_links]
        super
      end

      def validate_each(record, attr_name, value)

        # Detect any contact methods in the value
        detected = detect_contacts_in value, options

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

      def detect_contacts_in value, options

        num_words_value = value
        num_words_value = convert_numbers_at_words_in(value) unless options[:ignore_number_words]

        # Remove spaces (the most basic way to avoid these detections)
        globbed_value = num_words_value.gsub ' ', ''
        # Remove any characters not numbers or commas (commas are for $1,000 formatted numbers
        bullshit_free_phone = num_words_value.gsub /[^0-9,]|\n/i, ''

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

      # Uses damerau-levenshtein to turn "one, two, three..." into "1, 2, 3..."
      def convert_numbers_at_words_in value
        converted = String.new(value)
        NUMBER_WORDS.each_with_index do |word|
          converted.gsub!(word[0].to_s, word[1].to_s)
        end
        converted
      end

      module HelperMethods
        def validates_with_cold_shouldr(*attr_names)
          validates_with ColdShoulderValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end