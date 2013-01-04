LetterOpenerWeb::Engine.routes.draw do
  delete 'clear'        => 'letters#clear', as: :clear_letters
  get    '/'            => 'letters#index', as: :letters
  get    ':id(/:style)' => 'letters#show',  as: :letter
end
