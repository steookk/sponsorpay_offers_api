require 'sponsorpay'  #/lib 

class Offer 

  #---FIELDS 
  @fields_hash = {uid: true, pub0: false, page: false}
  
  def self.fields 
    @keys ||= @fields_hash.keys
  end

  def self.mandatory?(field)
    @fields_hash[field]
  end

  #---
  def initialize(hashie)
    @offer_data = hashie
    self
  end

  #accessors
  def method_missing(method, *args)
    return super unless @offer_data.respond_to?(method)
    @offer_data.send(method, *args)
  end

  #---
  #returns an array of Offer
  def self.fetch_offers(params={})
    validate params
    strip params
    response = SponsorPay.offers params['uid'], params.symbolize_keys
    response.offers.each_with_object([]) { |offer, ary| ary << Offer.new(offer) }
  end

  private 
  def self.validate
    params.delete_if { |key, value| !fields.include?(key.to_sym) || value.blank? }
    fields.each { |f| return nil if mandatory?(f) && !params.include?(f) }
  end

  def self.strip
    params.each_key { |key| params[key].strip! }
  end
end