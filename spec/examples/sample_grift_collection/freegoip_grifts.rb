#this file contains grifts that call to freegoip

#a simple call that returns the callers IP and geographic info
def my_location
  freegeoip.get '/json/'
end

