require "surveygizmo/client/version"
require "oauth"

module Surveygizmo
  class Client

    def initialize(access_token, consumer, options)
      @consumer_key = consumer["key"]
      @consumer_sercret = consumer["secret"]
      @token = access_token["token"]
      @token_secret = access_token["secret"]
      @options = options
    end

    def prepare_access_token
      consumer = OAuth::Consumer.new(consumer_key, consumer_sercret, options)

      token_hash = { oauth_token: @token, oauth_token_secret: @token_secret }

      access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

      access_token
    end

    def access_token
      @access_token ||= prepare_access_token
    end
  end
end
