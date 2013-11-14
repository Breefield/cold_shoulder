require 'active_model'
require 'active_model/validations'

require 'action_view'
require 'action_view/helpers'

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
        detected = {
          twitter:  globbed_value.scan(twitter_regex),
          email:    value.scan(email_regex),
          phone:    globbed_value.scan(formatted_phone_regex).concat(
            bullshit_free_phone.scan(formatted_phone_regex)
          ).uniq
        }

        # Catchall for base
        errors = false

        [:twitter, :email, :phone].each do |type|

          unless detected[type].empty? or options["ignore_#{type}".to_sym]
            errors = true
            next if options[:message]
            
            record.errors.add(attr_name, "contains_#{type}".to_sym, options.merge(
              detected: detected[type].map{ |p| 
                type == :phone && defined?(Rails) ? number_to_phone(p[0], area_code: true) : p[0]
              }.join(', ')
            )) 
          end

        end

        # A base mesage might be used
        if errors and options[:message]
          record.errors.add(:base, options[:message])
        end

      end

      module HelperMethods
        def validates_with_cold_shouldr(*attr_names)
          validates_with ColdShoulderValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end