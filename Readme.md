HAPI
=======
Hapi, pronounced "happy", makes it easy to work with JSON HTTP APIs

Features
--------
- Command line calls to API(s)
- Support for multiple environments (Dev, Staging, Production)
- Script calls to API(s)
- Simplify complex interactions within/across APIs into simple method calls
- Unified approach to handling request errors
- Craft clean API tests using the Grifter RSPec helper
- Convention over configuration approach to enxtending

Getting Started
---------------

.make a project directory
-------------------------
mkdir be_happy
cd be_happy
-------------------------

.setup hapi.yml
------------------
#all config files must have a services block
services_defaults:
  twitter:
    hostname: 'twitter.com'
------------------

.make the hapis directory
-----------------------
mkdir hapis
touch hapis/google_my_tweets.rb
-----------------------

.make a hapi file/method, in google_my_tweets.rb
-----------------------
def kanyes_tweets
  twitter.get "/statuses/timeline?twitter_id=kanyewest"
end
-----------------------

.and hapi away!
----------------
hapi tweets_for kanyewest
----------------

