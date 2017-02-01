# frozen_string_literal: true
module LetterOpenerWeb
  class ApplicationController < ActionController::Base
    before_action :authenticate!

    private

      def authenticate!
        return unless LetterOpenerWeb.configuration.authentication_enabled

        options = LetterOpenerWeb.configuration.authentication_options
        authenticate_or_request_with_http_basic do |user, pass|
          user == options[:user] && pass == options[:pass]
        end
      end
  end
end
