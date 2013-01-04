Rails.application.routes.draw do
  get '/'   => 'letter_opener_web/letters#index'
  get ':id' => 'letter_opener_web/letters#new'
end
