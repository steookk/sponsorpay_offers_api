require 'digest'

module SponsorPay
  # @private
  module Request

    private 

    def request(method, path, params)
      params_with_sign = sign_request params
      response = connection.send(method) { |request| request.url formatted_path(path), params_with_sign }
      raise SponsorPay::SponsorPayError, "HTTP #{response.status}: #{response.body.code}" if response.status.to_i != 200
      response.body
    end

    def sign_request(params)
      api_key = params[:api_key]; params.delete(:api_key)
      string_params = params.keys.sort!.each_with_object("") { |key, string| string + "#{key}=#{params[key]}&" }
      string_params += "#{api_key}"
      sha1 = Digest::SHA1.new; sign = sha1.digest string_params
      params[:hashkey] = sign
      params
    end

    def formatted_path(path)
      [path, SponsorPay.format].compact.join('.')
    end

  end
end
