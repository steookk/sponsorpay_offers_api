class OffersController < ApplicationController
  def home 
    @fields = Offer.fields 
  end

  def index
    @offers = Offer.fetch_offers(params)
  end
end
