require 'active_model/validations'

module ActiveModel
  module Validations
    def validate_each(record, attr_name, value)
      if value.blank?
        record.errors.add(attr_name, :contains_contact, options)
      end
    end

    module HelperMethods
      # Validates that the specified attributes do not contain contact information. 
      # Happens by default on save.
      #
      #   class Message < ActiveRecord::Base
      #     validates_no_contact_in :body
      #   end

      def validates_no_contact_in(*attr_names)
        validates_with PresenceValidator, _merge_attributes(attr_names)
      end
    end
  end
end