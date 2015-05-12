
Parameters = ParamsStruct.new(:count, :par2)

class StateIdle < FSM::State
  def action
    puts "in #{@name}, #{@params.count}"
    @params.count += 1
    if @params.count > 10
      @params.current_state = 'Stop'
    end
  end
end

class StateStop < FSM::State
  def on_enter
    puts "Exiting"
  end
  def action
    @params.current_state = nil
  end
end




pars       = Parameters.new
pars.count = 0
pars.par2  = "test"
m          = FSM::Machine.new pars

idle_state = StateIdle.new "Idle"
idle_state.timing = 0.5
m.add idle_state

stop_state = StateStop.new "Stop"
m.add stop_state

p m

m.run "Idle"