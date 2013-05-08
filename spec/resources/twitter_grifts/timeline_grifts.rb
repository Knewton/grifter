
def timeline_for screen_name
  response = twitter.get "/statuses/user_timeline.json?screen_name=#{screen_name}&count=100"
end

def status_list screen_name
  timeline = timeline_for screen_name
  timeline.map {|status| status['text']}
end
