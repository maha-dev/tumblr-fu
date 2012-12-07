require 'oauth'
require 'open-uri'
require 'json'

module Tumblr
  class Client
    def initialize(opts = {})
      @consumer_key = opts.delete(:consumer_key)
      consumer_secret = opts.delete(:consumer_secret)
      oauth_token = opts.delete(:oauth_token)
      oauth_token_secret = opts.delete(:oauth_token_secret)
      @consumer = OAuth::Consumer.new(@consumer_key, consumer_secret,
                                     {:site => "http://www.tumblr.com/"})
      token_hash = {:oauth_token => oauth_token,
        :oauth_token_secret => oauth_token_secret}
      @access_token = OAuth::AccessToken.from_hash(@consumer, token_hash)
    end

    def info(hostname)
      JSON.parse open("http://api.tumblr.com/v2/blog/#{hostname}/info?api_key=#{@consumer_key}").read
    end

    def followers(hostname)
      response = @access_token.get("http://api.tumblr.com/v2/blog/#{hostname}/followers")
      JSON.parse(response.body)
    end

    private

  end
end
