require 'sponsorpay'  #/lib 

class Offer 

  #---FIELDS to be displayed to the user
  @fields_hash = {uid: true, pub0: false, page: false}
  
  def self.fields 
    keys ||= @fields_hash.keys
  end

  def self.mandatory?(field)
    @fields_hash[field]
  end

  #---
  def initialize(hashie)
    @offer_data = hashie
    self
  end

  #each Offer delegates to the hashie provided by the API (/lib)
  def method_missing(method, *args)
    return super unless @offer_data.respond_to?(method)
    @offer_data.send(method, *args)
  end

  attr_accessor :error_message

  #---
  #fetch Offers from SponsorPay and return an array of them.
  def self.fetch_offers(params={})
    if validate_presence params
      strip params
      begin
        fetched = SponsorPay.offers params[:uid], params.symbolize_keys
      rescue SponsorPay::SponsorPayError => e
        response = Offer.new(nil)
        response.error_message = e.message
      end
    else
      response = Offer.new(nil)
      response.error_message = 'One or more mandatory keys are missing'
    end
    response ||= fetched.offers.each_with_object([]) { |offer, ary| ary << Offer.new(offer) }
  end

  private 
  def self.validate_presence(params)
    params.delete_if { |key, value| !fields.include?(key.to_sym) || value.blank? }
    fields.each { |f| return false if mandatory?(f) && !params.include?(f) }
  end

  def self.strip(params)
    params.each_key { |key| params[key].strip! }
  end
end