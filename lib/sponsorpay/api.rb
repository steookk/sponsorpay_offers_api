require File.expand_path('../api/connection', __FILE__)
require File.expand_path('../api/request', __FILE__)

module SponsorPay
  # @private
  class API
    include Connection
    include Request

    # wrapper over the actual request
    # @private
    def send_request(method, path, params)
      params = complete params
      request(method, path, params)
    end


    private 

    def complete(params)
      settings = SponsorPay.settings
      raise SponsorPayError, "One or more mandatory settings are missing" if settings.values.include? nil 
      params.merge! settings
      params.merge!({:timestamp => Time.now.to_i})
    end

  end
end