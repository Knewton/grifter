Grifter
=======
Grifter makes it smooth to work with JSON HTTP APIs with confidence

Features
--------
- Command line calls to API(s)
- Support for multiple environments (Dev, Staging, Production)
- Script calls to API(s)
- Simplify complex interactions within/across APIs into simple method calls
- Unified approach to handling request errors
- Craft clean API tests using the included RSPec helper
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
         hostname: 'http://api.openweathermap.org'

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


== Copyright

Copyright (c) 2013 Robert Schultheis. See LICENSE.txt for
further details.
