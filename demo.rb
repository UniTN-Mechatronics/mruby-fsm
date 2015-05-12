
class StateIdle < FSM::State
  def action
    puts "in #{@name}, #{@params.count}"
    @params.count += 1
    if @params.count > 50
      @params.current_state = 'Stop'
    end
  rescue => e
    p e
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



m = FSM::Machine.new(:count, :par2)
m.params[:count] = 0
m.params[:par2] = "Test"

idle_state = StateIdle.new "Idle"
idle_state.timing = 0.1
m.add idle_state

stop_state = StateStop.new "Stop"
m.add stop_state

p m

m.run "Idle"