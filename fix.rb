fsm = FSM::Machine.new(:counter)
fsm.params.counter = 0

loop_state = FSM::State.new("loop")
i = 0

loop_state.in_loop do
  fsm.params.counter += 1
  print "fsm.params.counter += 1  =>  #{fsm.params.counter}\n"
end
loop_state.timing = 0.010
fsm.add(loop_state)

fsm.run "loop"
