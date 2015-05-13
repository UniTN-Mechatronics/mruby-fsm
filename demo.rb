include FSM
# STEP 1
# Create a new FSM with a list of names for state parameters:
m = Machine.new(:count, :par2)
# set values for parameters:
m.params.count = 0
m.params.par2 = "Test"

# STEP 2
# Create states, giving a name (String)
idle_state = State.new "Idle"
# define actions for on_enter, in_loop, and on_exit (using a DSL):
idle_state.in_loop do
  puts "In #{name}, iteration #{params.count}"
  params.count += 1
  if params.count > 10
    transition_to 'Stop'
  end
end
idle_state.on_exit { puts "Exiting #{self.name}"}
# If needed, define a timer for the state (in seconds):
idle_state.timing = 0.1
# finally add the state to the FSM instance:
m.add idle_state

# Repeat for other states:
stop_state = State.new "Stop"
stop_state.in_loop { transition_to nil }
m.add stop_state

# STEP 3
# set $debug to true for enabling warn(message)
# $debug = true
# run the FSM:
m.run "Idle"