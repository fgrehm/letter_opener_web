LetterOpenerWeb::Engine.routes.draw do
  delete 'clear'                 => 'letters#clear',    :as => :clear_letters
  delete ':id/delete'            => 'letters#destroy',  :as => :delete_letter
  get    '/'                     => 'letters#index',    :as => :letters
  get    ':id(/:style)'          => 'letters#show',     :as => :letter
  get    ':id/attachments/:file' => 'letters#attachment'
end
