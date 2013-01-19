require_dependency "letter_opener_web/application_controller"
require 'rexml/document'

module LetterOpenerWeb
  class LettersController < ApplicationController
    def index
      @letters = Letter.search
    end

    def show
      letter = Letter.find(params[:id])
      text   = letter.send("#{params[:style]}_text")
      render text: fix_links(letter.id, text)
    end

    def clear
      Letter.destroy_all
      redirect_to letters_path
    end

    private

    def fix_links(id, letter_contents)
      contents = letter_contents.
        gsub(/"plain\.html"/, "\"#{letter_path(id: id, style: 'plain')}\"").
        gsub(/"rich\.html"/, "\"#{letter_path(id: id, style: 'rich')}\"")

      contents.scan(/<a[^>]+>.+<\/a>/).each do |link|
        xml = REXML::Document.new(link).root
        unless xml.attributes['href'] =~ /#{Regexp.escape letter_path(id: id)}/
          xml.attributes['target'] = '_blank'
          contents.gsub!(link, xml.to_s)
        end
      end

      contents
    end
  end
end
