require 'digest'

module SponsorPay
  # @private
  module Request

    private 

    def request(method, path, params)
      sorted_params_with_sign = sign_request params
      response = connection.send(method) { |request| request.url formatted_path(path), sorted_params_with_sign }
      raise SponsorPay::SponsorPayError, "HTTP #{response.status}: #{response.body.code}" if response.status.to_i != 200
      response.body
    end

    def sign_request(params)
      api_key = params[:api_key]; params.delete(:api_key)
      sorted_params = params.keys.sort!.each_with_object({}) { |key, hash| hash[key] = params[key] }
      string_params = sorted_params.keys.each_with_object("") { |key, string| string.concat "#{key}=#{params[key]}&" }
      string_params = string_params + "#{api_key}"
      sha1 = Digest::SHA1.new; sign = sha1.hexdigest string_params
      sorted_params[:hashkey] = sign
      sorted_params
    end

    def formatted_path(path)
      [path, SponsorPay.format].compact.join('.')
    end

  end
end
