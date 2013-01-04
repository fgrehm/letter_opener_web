Rails.application.routes.draw do
  get '/'   => 'letter_opener_web/letters#index'
  get ':id(/:style)' => 'letter_opener_web/letters#show', as: :letter
end
