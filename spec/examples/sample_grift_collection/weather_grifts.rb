#A cross service call that first gets your localtion, then gets weather at location
def my_weather
  location = my_location
  weather_for "#{location['city']}, #{location['region_code']}"
end

def kelvin_to_celcius kelvin
  (kelvin - 273.15).round
end

#A call that gets your weather report and filters it into a nice report on temperatures only
def my_temperature
  weather = my_weather
  temps = {
    'current' => kelvin_to_celcius(weather['main']['temp']),
    'low' => kelvin_to_celcius(weather['main']['temp_min']),
    'high' => kelvin_to_celcius(weather['main']['temp_max']),
  }
  "Temperatures today:\n#{temps.to_yaml}"
end

