Grifter
=======
Grifter makes it smooth to work with JSON HTTP APIs with confidence

Intro
--------
Grifter allows creating a DSL for working with any HTTP JSON RESTy API.
You can GET, POST and otherwise interact with any set of APIs through
high level methods you define, allowing your code to ignore all the
details around the mechanics of connecting to the API, executing the
request, and turning JSON into native ruby objects.

Using grifter gets you for free:
- a cmd line interface for your json http apis
- a ruby scripting language for interacting with your json http apis
- An object you can use in any kind of ruby program for easily sending
  API requests
- An RSpec Helper that makes testing Rest APIs painless

Grifter relies heavily on the 'convention over configuration' approach,
which means for less code, you get more.


Features
--------
- Work with multiple APIs
- Work with multiple deployment environments (Staging, Production, etc.)
- Script calls to API(s)
- Command line calls to API(s)
- Craft clean API tests using the included RSPec helper
- Unified approach to handling request errors
- Convention over configuration approach to defining the API interface

Getting Started
---------------
Lets demo how this works using a simple example of an API that requires no
authentication.

The OpenWeatherMap is a good candidate for a simple API
which is accessible without needing any authentication key:
[http://api.openweathermap.org/]


### make a project directory

    mkdir weather
    cd weather

### setup grifter.yml

     services:
       owm:
         hostname: api.openweathermap.org

### make the grifts directory, and a grift file

    mkdir owm_grifts
    touch owm_grifts/weather_grifts.rb

### add method for checking weather to owm/weather.rb
    def weather_for city
      owm.get "/data/2.5/weather?q=#{URI.encode(city)}"
    end

### Call it from the cmd line:
    $ grift weather_for 'Pleasantville, NY'

And that returns something like this:
    {"coord"=>{"lon"=>-73.79169, "lat"=>41.13436}, "sys"=>{"country"=>"United States of America", "sunrise"=>1366883974, "sunset"=>1366933583}, "weather"=>[{"id"=>501, "main"=>"Rain", "description"=>"moderate rain", "icon"=>"10d"}], "base"=>"global stations", "main"=>{"temp"=>290.46, "humidity"=>26, "pressure"=>1020, "temp_min"=>289.15, "temp_max"=>292.59}, "wind"=>{"speed"=>2.06, "gust"=>4.11, "deg"=>265}, "rain"=>{"1h"=>2.32}, "clouds"=>{"all"=>0}, "dt"=>1366926419, "id"=>5131757, "name"=>"Pleasantville", "cod"=>200}

Use the -v command line option and see the full request/response logged to StdOut

### Script it
Make a file called temperatures.rb with this in it:

    [
      'New York, NY',
      'Toronto, Canada',
      'Paris, France',
      'Tokyo, Japan',
      'Sydney, Australia',
    ].each do |city|
      weather = weather_for city
      kelvin = weather['main']['temp']
      celcius = (kelvin - 273.15).round
      puts "#{city}: #{celcius} celcius"
    end

And then run the grift script like so:

    grift -f temperatures.rb

And get this nice output:

    I: [04/25/13 17:59:22][grifter] - Running data script 'temperatures.rb'
    New York, NY: 18 celcius
    Toronto, Canada: 7 celcius
    Paris, France: 18 celcius
    Tokyo, Japan: 16 celcius
    Sydney, Australia: 14 celcius

### Test it
Using the included helper module, testing an api becomes easy.  Lets setup a simple RSpec example.  Step one is create the spec folder:

    mkdir spec

Setup spec/spec_helper.rb with contents like:

    require 'grifter/helpers'

    RSpec.configure do |config|
      config.include Grifter::Helpers
    end

Setup spec/weather_spec.rb with contents like:

    require 'spec_helper'
    describe "getting weather reports" do
      it "should know the weather for New York City" do
        response = weather_for 'New York, NY'
        response['main'].keys.should =~ ['temp', 'temp_min', 'temp_max', 'humidity', 'pressure']
      end
    end

Run it:

    gem install rspec
    rspec

And get back:

    1 example, 0 failures


Copyright
---------
Copyright (c) 2013 Knewton. See LICENSE.txt for
further details.
