require File.expand_path('../sponsorpay/configuration', __FILE__)
require File.expand_path('../sponsorpay/api', __FILE__)
require File.expand_path('../sponsorpay/error', __FILE__)

module SponsorPay

  extend Configuration

  def self.offers(uid, params={}, offer_types = '112')
    params.merge! uid: uid
    params.merge! offer_types: offer_types
    response = SponsorPay::API.new.send_request(:get, 'offers', params)
  end

  # list of non mandatory user params
  PARAMS = [
    :ip,
    :pub0,
    :page,
    :ps_time,
    :device
  ].freeze

end