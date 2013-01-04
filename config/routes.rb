LetterOpenerWeb::Engine.routes.draw do
  get '/'   => 'letters#index'
  get ':id(/:style)' => 'letters#show', as: :letter
end
