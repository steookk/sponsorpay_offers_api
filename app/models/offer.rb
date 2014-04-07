load 'sponsorpay.rb'  #/lib 

class Offer 

  #---FIELDS 
  @fields = {uid: true, pub0: false, page: false}
  
  def self.fields 
    @fields.keys
  end

  def self.mandatory?(field)
    @fields[field]
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
  def self.fetch_offers(params={})
    _fields = fields
    params.delete_if { |key, value| !_fields.include?(key.to_sym) || value.blank? }
    _fields.each { |f| return nil if mandatory?(f) && !params.include?(f) }
    params.each_key { |key| params[key].strip! }
    response = SponsorPay.offers(params.symbolize_keys)
    response.offers.each_with_object([]) { |offer, ary| ary << Offer.new(offer) }
  end

end