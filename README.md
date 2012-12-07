tumblr-fu
=========
A lightweight wrapper for Tumblr API



```ruby
require 'tumblr'
client = Tumblr::Client.new(:consumer_key => 'key goes here', 
  :consumer_secret => 'api secret',
  :oauth_token => 'oauth access token',
  :oauth_token_secret => 'oauth_token_secret')

client.info('someblog.tumblr.com')
```

Specs comming soon...

