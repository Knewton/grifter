Grifter
=======
Do cool stuff with HTTP JSON APIs.  Designed for the real world of developing systems based on service-oriented-architecture.

What is Grifter?
----------------
Grifter is primarily designed to be used by software teams that build HTTP JSON services.
Grifter makes it easy to:
* Define "macro" methods that accomplish high level goals through service calls.
* Call services or macro methods from the command line, adhoc scripts, or programtically within any Ruby program.
* Test services using RSpec or other testing frameworks
* "Point" at different environments (eg. QA, Staging, Production)

Grifter relies heavily on the 'convention over configuration' approach.  For very little code, you
get a lot of functionality.

Grifter is based on [Faraday](https://github.com/lostisland/faraday), thus there is basic support for making requests concurrently, and for swapping out the HTTP "adapter".

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

### add method for checking weather to owm_grifts/weather.rb
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
        expected_items = ['temp', 'temp_min', 'temp_max', 'humidity', 'pressure']
        response['main'].keys.should include(*expected_items) 
      end
    end

Run it:

    gem install rspec
    rspec

And get back:

    1 example, 0 failures


Further Information
-------------------

Checkout out the [Wiki](https://github.com/Knewton/grifter/wiki) for info on configuration, authentication, and more.


Copyright
---------
Copyright (c) 2013 Knewton. See LICENSE.txt for further details.
