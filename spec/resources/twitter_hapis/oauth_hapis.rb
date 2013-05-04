require 'base64'

def twitter_keys
  @_twitter_keys ||= YAML.load_file('example/twitter_hapis/oauth.yml')
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

def twitter_hapi_authenticate
  application_authenticate
end
