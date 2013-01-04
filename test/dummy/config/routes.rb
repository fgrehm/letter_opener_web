Rails.application.routes.draw do

  mount LetterOpenerWeb::Engine => "/letter_opener_web"
end
