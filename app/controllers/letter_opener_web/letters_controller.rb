require_dependency "letter_opener_web/application_controller"

module LetterOpenerWeb
  class LettersController < ApplicationController
    def index
      @letters = Letter.search
    end

    def show
      letter = Letter.find(params[:id])
      text   = letter.send("#{params[:style]}_text").
        gsub(/"plain\.html"/, "\"#{letter_opener_web.letter_path(:id => letter.id, :style => 'plain')}\"").
        gsub(/"rich\.html"/, "\"#{letter_opener_web.letter_path(:id => letter.id, :style => 'rich')}\"")
      render :text => text
    end

    def attachment
      letter   = Letter.find(params[:id])
      filename = "#{params[:file]}.#{params[:format]}"

      if file = letter.attachments[filename]
        send_file(file, :filename => filename, :disposition => 'inline')
      else
        render :text => 'Attachment not found!', :status => 404
      end
    end

    def clear
      Letter.destroy_all
      redirect_to letter_opener_web.letters_path
    end

    def destroy
      letter = Letter.find(params[:id])
      letter.delete
      redirect_to letter_opener_web.letters_path
    end
  end
end
