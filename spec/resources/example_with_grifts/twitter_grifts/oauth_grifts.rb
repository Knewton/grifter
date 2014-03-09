require 'base64'

def twitter_keys
  unless @_twitter_keys
    key_file_path = File.join(File.dirname(__FILE__), 'oauth.yml')
    @_twitter_keys = YAML.load_file(key_file_path)
  end
  @_twitter_keys
end

def application_authenticate
  params = { 'grant_type' => 'client_credentials' }
  token = twitter_keys['consumer_key'] + ':' + twitter_keys['consumer_secret']
  encoded_token = Base64.strict_encode64(token)
  response = twitter.post_form '/oauth2/token', params,
   base_uri: '',
   additional_headers: {
     'Authorization' => "Basic " + encoded_token,
     'Accept' => '*/*',  # I think this is a bug that I have to set it to this:  https://dev.twitter.com/discussions/16348#comment-36465
   }
   twitter.headers['Authorization'] = "Bearer #{response['access_token']}"
   true
end

def twitter_grifter_authenticate
  application_authenticate
end
