# frozen_string_literal: true

module LetterOpenerWeb
  # Interface that all Letter storage implementations must implement
  #
  # This module defines the contract for Letter storage backends.
  # Any storage implementation (file-based, S3, Redis, etc.) must provide
  # all the methods defined in this interface.
  module LetterInterface
    extend ActiveSupport::Concern

    included do
      # Ensure the implementing class defines required attributes
      attr_reader :id, :sent_at
    end

    class_methods do
      # Returns all letters sorted by sent_at (newest first)
      #
      # @return [Array<Letter>] Array of letter instances
      def search
        raise NotImplementedError, "#{self} must implement .search"
      end

      # Find a letter by its ID
      #
      # @param id [String] The letter identifier
      # @return [Letter] A letter instance
      def find(id)
        raise NotImplementedError, "#{self} must implement .find"
      end

      # Destroy all letters
      #
      # @return [void]
      def destroy_all
        raise NotImplementedError, "#{self} must implement .destroy_all"
      end
    end

    # Returns the email headers as a hash
    #
    # @return [Hash] Email headers (from, to, subject, etc.)
    def headers
      raise NotImplementedError, "#{self.class} must implement #headers"
    end

    # Returns the plain text version of the email
    #
    # @return [String] Plain text email content
    def plain_text
      raise NotImplementedError, "#{self.class} must implement #plain_text"
    end

    # Returns the HTML version of the email
    #
    # @return [String] HTML email content
    def rich_text
      raise NotImplementedError, "#{self.class} must implement #rich_text"
    end

    # Returns a hash of attachment filenames to their paths/URLs
    #
    # @return [Hash{String => String}] Mapping of filename to path/URL
    def attachments
      raise NotImplementedError, "#{self.class} must implement #attachments"
    end

    # Send the attachment to the controller
    #
    # @param controller [ActionController::Base] The controller instance
    # @param filename [String] The attachment filename
    # @return [void]
    def send_attachment(controller, filename)
      raise NotImplementedError, "#{self.class} must implement #send_attachment"
    end

    # Delete this letter
    #
    # @return [void]
    def delete
      raise NotImplementedError, "#{self.class} must implement #delete"
    end

    # Check if this letter is valid and accessible
    #
    # @return [Boolean]
    def valid?
      raise NotImplementedError, "#{self.class} must implement #valid?"
    end
  end
end
