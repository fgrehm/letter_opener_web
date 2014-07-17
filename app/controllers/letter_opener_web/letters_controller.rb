require_dependency "letter_opener_web/application_controller"

module LetterOpenerWeb
  class LettersController < ApplicationController
    before_filter :check_style, :only => [:show]
    before_filter :load_letter, :only => [:show, :attachment, :destroy]

    def index
      @letters = Letter.search
    end

    def show
      text = @letter.send("#{params[:style]}_text").
        gsub(/"plain\.html"/, "\"#{LetterOpenerWeb.railtie_routes_url_helpers.letter_path(:id => @letter.id, :style => 'plain')}\"").
        gsub(/"rich\.html"/, "\"#{LetterOpenerWeb.railtie_routes_url_helpers.letter_path(:id => @letter.id, :style => 'rich')}\"")
      render :text => text
    end

    def attachment
      @letter = Letter.find(params[:id])
      filename = "#{params[:file]}.#{params[:format]}"

      if file = @letter.attachments[filename]
        send_file(file, :filename => filename, :disposition => 'inline')
      else
        render :text => 'Attachment not found!', :status => 404
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
        render :nothing => true, :status => 404 unless @letter.exists?
      end
    end
  end
end
