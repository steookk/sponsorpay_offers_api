SponsorpayOfferApi::Application.routes.draw do
  root :to => "offers#home" 
  resources :offers, only: :index
end
