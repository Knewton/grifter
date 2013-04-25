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
