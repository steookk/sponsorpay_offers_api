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
                    'Connection'      => 'Keep-Alive'}, 
                     #'Accept-Encoding' => 'gzip ...' # => automatically added by net::http
        :ssl => {:verify => false},
        :url => SponsorPay.endpoint,
      }
      Faraday::Connection.new(options) do |connection|
        connection.use FaradayMiddleware::Mashify
        connection.use Faraday::Response::ParseJson if SponsorPay.format.to_s.downcase == 'json'
        connection.adapter SponsorPay.adapter
      end
    end

  end
end
