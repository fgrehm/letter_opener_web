Rails.application.routes.draw do
  delete 'clear'                 => 'letter_opener_web/letters#clear'
  delete ':id'                   => 'letter_opener_web/letters#destroy',   :as => :delete_letter
  get    '/'                     => 'letter_opener_web/letters#index',     :as => :letters
  get    ':id(/:style)'          => 'letter_opener_web/letters#show',      :as => :letter
  get    ':id/attachments/:file' => 'letter_opener_web/letters#attachment'
end
