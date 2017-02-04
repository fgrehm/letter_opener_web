require_dependency "letter_opener_web/application_controller"

module LetterOpenerWeb
  class LettersController < ApplicationController
    before_action :check_style, :only => [:show]
    before_action :load_letter, :only => [:show, :attachment, :destroy]

    def index
      @letters = Letter.search
    end

    def show
      text = @letter.send("#{params[:style]}_text").
        gsub(/"plain\.html"/, "\"#{LetterOpenerWeb.railtie_routes_url_helpers.letter_path(:id => @letter.id, :style => 'plain')}\"").
        gsub(/"rich\.html"/, "\"#{LetterOpenerWeb.railtie_routes_url_helpers.letter_path(:id => @letter.id, :style => 'rich')}\"")

      render :html => text.html_safe
    end

    def attachment
      @letter = Letter.find(params[:id])
      filename = "#{params[:file]}.#{params[:format]}"

      if file = @letter.attachments[filename]
        send_file(file, :filename => filename, :disposition => 'inline')
      else
        render :plain => 'Attachment not found!', :status => 404
      end
    end

    def clear
      Letter.destroy_all
      redirect_to LetterOpenerWeb.railtie_routes_url_helpers.letters_path
    end

    def destroy
      @letter = Letter.find(params[:id])
      @letter.delete
      redirect_to LetterOpenerWeb.railtie_routes_url_helpers.letters_path
    end

    private

    def check_style
      params[:style] = 'rich' unless ['plain', 'rich'].include? params[:style]
    end

    def load_letter
      if params[:id]
        @letter = Letter.find(params[:id])
        head :not_found unless @letter.exists?
      end
    end
  end
end
