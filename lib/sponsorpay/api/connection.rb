require 'faraday'  #provare a toglierlo!

module SponsorPay
  # @private
  module Connection

    private
    # returns a new connection object.
    def connection
      options = {
        :headers => {'Accept'         => "application/#{SponsorPay.format}; charset=utf-8", 
                    'User-Agent'      => SponsorPay.user_agent, 
                    'Accept-Encoding' => 'gzip',
                    'Connection'      => 'Keep-Alive'},
        :ssl => {:verify => false},
        :url => SponsorPay.endpoint,
      }
      Faraday::Connection.new(options) do |connection|
        connection.use Faraday::Request::UrlEncoded
        connection.use FaradayMiddleware::Mashify
        connection.use Faraday::Response::ParseJson if SponsorPay.format.to_s.downcase == 'json'
        connection.adapter(SponsorPay.adapter)
      end
    end

  end
end
