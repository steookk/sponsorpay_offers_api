class OffersController < ApplicationController
  def home 
    @fields = Offer.fields 
  end

  def index
    @offers = Offer.fetch_offers(params)
    respond_to do |format|
      format.js { render :index }
    end
  end
end
