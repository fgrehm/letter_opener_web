# frozen_string_literal: true

module LetterOpenerWeb
  # Lets letters use inline styles and images under the host's policy.
  module LetterInlineStyles
    extend ActiveSupport::Concern

    STYLE_DIRECTIVES = %w[style-src style-src-elem style-src-attr].freeze
    # 'unsafe-inline' is ignored next to these.
    UNSHAREABLE_SOURCE = /\A'(none'|nonce-|sha\d+-)/i
    # Rails' default when the app sets none.
    DEFAULT_NONCE_DIRECTIVES = %w[script-src style-src].freeze

    private

    def letter_inline_styles?
      LetterOpenerWeb.config.letter_inline_styles && content_security_policy?
    end

    def allow_letter_inline_styles
      policy = current_content_security_policy
      widen policy, 'style-src', fallback: 'default-src', add: ["'unsafe-inline'"]
      widen policy, 'style-src-elem', add: ["'unsafe-inline'"]
      widen policy, 'style-src-attr', add: ["'unsafe-inline'"]
      widen policy, 'img-src', fallback: 'default-src', add: ["'self'", 'https:', 'data:']
      request.content_security_policy = policy

      nonce_directives = request.content_security_policy_nonce_directives || DEFAULT_NONCE_DIRECTIVES
      request.content_security_policy_nonce_directives = nonce_directives - STYLE_DIRECTIVES
    end

    def widen(policy, directive, add:, fallback: nil)
      sources = policy.directives[directive] || policy.directives[fallback]
      return unless sources

      policy.public_send(directive.tr('-', '_'), *(sources.grep_v(UNSHAREABLE_SOURCE) | add))
    end
  end
end
