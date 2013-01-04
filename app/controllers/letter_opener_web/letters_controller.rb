require_dependency "letter_opener_web/application_controller"

module LetterOpenerWeb
  class LettersController < ApplicationController
    def index
      @letters = Letter.search
    end

    def show
    end
  end
end
