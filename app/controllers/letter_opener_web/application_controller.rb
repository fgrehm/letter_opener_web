# frozen_string_literal: true

module LetterOpenerWeb
  class ApplicationController < ActionController::Base
    before_action :enforce_basic_auth, if: -> { LetterOpenerWeb.config.basic_auth_enabled? }

    protect_from_forgery with: :exception, unless: -> { Rails.configuration.try(:api_only) }

    private

    def enforce_basic_auth
      authenticate_or_request_with_http_basic('Letter Opener Web') do |username, password|
        config = LetterOpenerWeb.config
        ActiveSupport::SecurityUtils.secure_compare(username, config.username.to_s) &
          ActiveSupport::SecurityUtils.secure_compare(password, config.password.to_s)
      end
    end
  end
end
