# frozen_string_literal: true

LetterOpenerWeb::Engine.routes.draw do
  get  '/',                     to: 'letters#index',    as: :letters
  post 'clear',                 to: 'letters#clear',    as: :clear_letters
  get  ':id(/:style)',          to: 'letters#show',     as: :letter
  post ':id/delete',            to: 'letters#destroy',  as: :delete_letter
  get  ':id/attachments/:file', to: 'letters#attachment', constraints: { file: %r{[^/]+} }
end
