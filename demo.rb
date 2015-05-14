include FSM
puts "RunTime scheduling" if Raspberry.set_priority 99
# STEP 1
# Create a new FSM with a list of names for state parameters:
m = Machine.new(:count, :clock, :dt)
# set values for parameters:
m.params.count = 0
m.params.clock = []
m.params.dt    = []

# STEP 2
# Create states, giving a name (String)
idle_state = State.new "Idle"
# define actions for on_enter, in_loop, and on_exit (using a DSL):
idle_state.on_enter { puts "> Entering #{self.name}"}
idle_state.in_loop do
  params.clock << Time.now.to_f - START
  params.dt << params.clock[-1] - (params.clock[-2] || 0)
  params.count += 1
  if params.count > 10
    transition_to 'Stop'
  end
end
idle_state.on_exit { puts "< Exiting #{self.name}"}
# If needed, define a timer for the state (in seconds):
idle_state.timing = 0.05
# finally add the state to the FSM instance:
m.add idle_state

# Repeat for other states:
stop_state = State.new "Stop"
stop_state.on_enter { puts "> Entering #{self.name}"}
stop_state.in_loop { stop_machine }
stop_state.on_exit { puts "< Exiting #{self.name}"}
m.add stop_state

# STEP 3
# set $debug to true for enabling warn(message)
# $debug = true
# run the FSM:
START = Time.now.to_f
m.run "Idle"

puts "Loop times:"
timings = m.params.dt
mean = timings.inject(0.0) {|s,v| s + v } / timings.count.to_f
var = timings.inject(0.0) {|s,v| s + (v - mean) ** 2 } / (timings.count.to_f - 1)
puts "Mean: #{mean} s, Standard Deviation: #{var ** 0.5} s"
Raspberry.set_priority 0