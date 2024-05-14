# frozen_string_literal: true

unless Rails.respond_to?(:autoloaders) && Rails.autoloaders.zeitwerk_enabled?
  require_dependency 'letter_opener_web/application_controller'
end

module LetterOpenerWeb
  class LettersController < ApplicationController
    before_action :check_style, only: :show
    before_action :load_letter, only: %i[show attachment destroy]

    def index
      @letters = letter_model.search
    end

    def show
      text = @letter.send("#{params[:style]}_text")
                    .gsub('"plain.html"', "\"#{routes.letter_path(id: @letter.id, style: 'plain')}\"")
                    .gsub('"rich.html"', "\"#{routes.letter_path(id: @letter.id, style: 'rich')}\"")

      render html: text.html_safe
    end

    def attachment
      filename = params[:file]
      file     = @letter.attachments[filename]

      return render plain: 'Attachment not found!', status: 404 unless file.present?
      return redirect_to(file, allow_other_host: true) if LetterOpenerWeb.config.letters_location == :s3

      send_file(file, filename: filename, disposition: 'inline')
    end

    def clear
      letter_model.destroy_all
      redirect_to routes.letters_path
    end

    def destroy
      @letter.delete
      respond_to do |format|
        format.html { redirect_to routes.letters_path }
        format.js { render js: "window.location='#{routes.letters_path}'" }
      end
    end

    private

    def check_style
      params[:style] = 'rich' unless %w[plain rich].include?(params[:style])
    end

    def load_letter
      @letter = letter_model.find(params[:id])

      head :not_found unless @letter.valid?
    end

    def routes
      LetterOpenerWeb.railtie_routes_url_helpers
    end

    private

    def letter_model
      LetterOpenerWeb.config.letters_location == :s3 ? LetterOpenerWeb::AwsLetter : LetterOpenerWeb::Letter
    end
  end
end
