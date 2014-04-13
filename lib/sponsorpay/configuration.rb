require 'faraday'

module SponsorPay

  module Configuration
    #mandatory for the app using this library, requested by sponsorpay 
    SETTINGS = [
      :appid,  
      :api_key,
      :locale,
      :os_version,
      :device_id,
      :ip
    ].freeze

    # ---
    OPTIONS = [
      :adapter,
      :format,
      :endpoint,
      :user_agent
    ].freeze 

    DEFAULT_ADAPTER = Faraday.default_adapter
    DEFAULT_FORMAT = :json  #only one supported at the moment
    DEFAULT_ENDPOINT = 'http://api.sponsorpay.com/feed/v1/'.freeze
    DEFAULT_USER_AGENT = "SponsorPay programming challange by Stefano Uliari".freeze
    # ---

    attr_accessor *SETTINGS
    attr_accessor *OPTIONS

    # Hashes for settings and options values
    def settings
      SETTINGS.inject({}) do |settings, key|
        settings.merge!(key => send(key))
      end
    end

    def options
      OPTIONS.inject({}) do |options, key|
        options.merge!(key => send(key))
      end
    end
    # ---

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.setup
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Reset configurations istance variables to default values
    def reset
      SETTINGS.each { |key| send("#{key}=", nil) }
      OPTIONS.each { |key| send("#{key}=", SponsorPay::Configuration.const_get("DEFAULT_#{key.upcase}"))}
    end
    alias setup reset

  end
end