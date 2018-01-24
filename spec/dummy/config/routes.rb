# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine => '/letter_opener'

  root to: 'home#index'
  post '/', to: 'home#create'
end
