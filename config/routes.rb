LetterOpenerWeb::Engine.routes.draw do
  get '/'   => 'letters#index'
  get ':id' => 'letters#new'
end
