#This file contains grifts that call Open Weather Map

# a simple call to open weather map that takes a string for the city
def weather_for city
  owm.get "/data/2.5/weather?q=#{URI.encode(city)}"
end
