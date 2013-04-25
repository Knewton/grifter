def weather_for city
  owm.get "/data/2.5/weather?q=#{URI.encode(city)}"
end
