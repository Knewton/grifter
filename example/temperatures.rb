temps = {}
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
  temps[city] = "#{celcius.to_s} C"
end

return temps.to_yaml
