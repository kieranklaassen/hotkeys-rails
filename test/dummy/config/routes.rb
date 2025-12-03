Rails.application.routes.draw do
  root "pages#home"
  get "clicked", to: "pages#clicked"
  get "focused", to: "pages#focused"
end
