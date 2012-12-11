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
      JSON.parse api_key_get(hostname, 'info')
    end

    def followers(hostname)
      response = @access_token.get("http://api.tumblr.com/v2/blog/#{hostname}/followers")
      JSON.parse(response.body)
    end

    def posts_page(hostname, opts = {})
      defaults = {:offset => 0, :limit => 20}
      opts = defaults.merge(opts)
      response = api_key_get(hostname, 'posts', opts)
      JSON.parse(response)
    end

    def post_pages(hostname, opts = {})
      page_limit = opts.delete(:number_of_pages).to_i
      limit = opts.delete(:per_page) || 20
      offset = 0
      result = posts_page(hostname, opts.merge(:offset => offset,
                                              :limit => limit))
      total = result['response']['total_posts']
      total_pages = (total.to_f / limit.to_f).ceil
      page_number = 1
      yield({:result => result,
            :offset => offset,
            :page_number => page_number,
            :per_page => limit})
      if total_pages > 1
        while(page_number <= total_pages) do
          break if page_limit > 0 && page_number == page_limit
          offset = (offset + limit)
          result = posts_page(hostname, opts.merge(:offset => offset,
                                              :limit => limit))
          yield({:result => result,
                :offset => offset,
                :page_number => page_number,
                :per_page => limit})
          page_number += 1
        end
      end
    end

    def api_key_get(hostname, path, params = {})
      params[:api_key] ||= @consumer_key
      query = URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
      uri = "http://api.tumblr.com/v2/blog/#{hostname}/#{path}?#{query}"
      open(uri).read
    end

  end
end
