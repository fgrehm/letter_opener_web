# frozen_string_literal: true

require_dependency 'letter_opener_web/application_controller'

module LetterOpenerWeb
  class LettersController < ApplicationController
    before_action :check_style, only: [:show]
    before_action :load_letter, only: %i[show attachment destroy]

    def index
      @letters = Letter.search
    end

    def show
      text = @letter.send("#{params[:style]}_text")
                    .gsub(/"plain\.html"/, "\"#{routes.letter_path(id: @letter.id, style: 'plain')}\"")
                    .gsub(/"rich\.html"/, "\"#{routes.letter_path(id: @letter.id, style: 'rich')}\"")

      render html: text.html_safe
    end

    def attachment
      filename = "#{params[:file]}.#{params[:format]}"
      file     = @letter.attachments[filename]

      return render plain: 'Attachment not found!', status: 404 unless file.present?
      send_file(file, filename: filename, disposition: 'inline')
    end

    def clear
      Letter.destroy_all
      redirect_to routes.letters_path
    end

    def destroy
      @letter.delete
      redirect_to routes.letters_path
    end

    private

    def check_style
      params[:style] = 'rich' unless %w[plain rich].include?(params[:style])
    end

    def load_letter
      @letter = Letter.find(params[:id])
      head :not_found unless @letter.exists?
    end

    def routes
      LetterOpenerWeb.railtie_routes_url_helpers
    end
  end
end
