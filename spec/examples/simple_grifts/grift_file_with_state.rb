flat_scoped_state = 1

def get_current_state
  flat_scoped_state
end

def increment_state
  flat_scoped_state += 1
end

def get_instance_var
  @instance_var ||= 100
end

def increment_instance_var
  @instance_var += 100
end
