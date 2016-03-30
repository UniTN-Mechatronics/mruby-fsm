#*************************************************************************#
#                                                                         #
# machine.rb - mruby gem provoding FSM                                    #
# Copyright (C) 2015 Paolo Bosetti and Matteo Ragni,                      #
# paolo[dot]bosetti[at]unitn.it and matteo[dot]ragni[at]unitn.it          #
# Department of Industrial Engineering, University of Trento              #
#                                                                         #
# This library is free software.  You can redistribute it and/or          #
# modify it under the terms of the GNU GENERAL PUBLIC LICENSE 2.0.        #
#                                                                         #
# This library is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of          #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
# Artistic License 2.0 for more details.                                  #
#                                                                         #
# See the file LICENSE                                                    #
#                                                                         #
#*************************************************************************#

# General container for StateMachine status parameters. With respect to a 
# plain Struct, this forces the presence of a +:current_state+ key, used by
# the {FSM::Machine} for determining which state is currently active.
# 
# Custom methods (e.g. +update+) can be defined within it and called
# from within the {State} instances for updating extrinsic parameters
# (for example, those to be read from the net).
# @example Create a parameters structure:
#   Parameters = ParamsStruct.new(:level, :iso_file, :parsed) do
#     def update
#       self.level += 1
#     end
#   end
# @example Instantiate and use:
#   params = Parameters.new
#   params.level = 0
#   params.iso_file = "./iso/simple.i"
class ParamsStruct < Struct
  # Prepend +:current_state+ and +:error_info+ keys to the +args+ Array passed
  # on creation.
  # @param [<Symbol>] args A list of Symbols, one for each attribute to be 
  #        created
  def self.new(*args)
    super(:current_state, :error_info, *args)
  end
end

module FSM
  
  # Object representing a State Machine. It holds a list of {State}s and a list 
  # of rules for switching contests from state to state. It also holds a 
  # structure representing the state parameters
  # @example Creating a machine:
  #   Parameters = Struct.new(:attr1, :attr2, :attr3)
  #   pars = Parameters.new
  #   # set pars IVs
  #   m = Machine.new pars
  # 
  # @example Adding a new state:
  #   m.add StateStart.new('start') # StateStart is a child of FSM::State
  #   p m.states # => @states= {"start"=>#<S.start: @params: #<struct Parameters level=0>>}
  # 
  # @example Running a machine:
  #   m.run if m.check
  #
  # @todo Implement parallel operations
  # @todo implement a Graphviz visualization method
  class Machine
    # @!attribute [rw] params
    #   The {ParamsStruct} object containing all the {Machine} state parameters.
    #   @return [ParamsStruct]
    # @!attribute [rw] states
    #   A Hash containing the list of {State}s defined for the current 
    #   {Machine}. Keys are the names of states (as Strings)
    #   @return [Hash{String=>EPC::State}]
    attr_accessor :params, :states
    
    # Create a new Machine. Also, setup the trap for SIGINT, which
    # will set the +@shutdown+ iv to +true+, stopping the execution of
    # loop in {#run} after the forthcoming loop.
    # @param [ParamsStruct] args A Struct-like object containing the parameters.
    def initialize(*args)
      if args[0].respond_to? :current_state
        @params  = args[0]
      elsif args.kind_of? Array
        Parameters = ParamsStruct.new(*args)
        @params = Parameters.new
      else
        raise ArgumentError, "Need either an Array of Symbols or a ParamsStruct"
      end
      @shutdown             = false
      @params.current_state = nil
      Signal.trap(:INT) {puts "\n-- Shutting down..."; @shutdown = true}
      @states   = {}
    end
    
    # Add a state to the {#states} list, using the {State#name} as key and the
    # {State} itself as value.
    # @example Adding a new state:
    #   m.add StateStart.new('start') # StateStart is a child of EPC::State
    #   p m.states # => @states= {"start"=>#<S.start: @params: #<struct Parameters level=0>>}
    # @param [EPC::State] state The state instance
    # @raise ArgumentError unless +state+ is an EPC::State    
    def add(state)
      raise ArgumentError unless state.kind_of? FSM::State
      if state.timing > 0 then
        @metronome = Metronome::Operation.new(0.5)
      end
      state.params        = @params
      @states[state.name] = state
    end
    
    # Check the configuration for consistency.
    # @param [Boolean] say If true, puts warnings for each check
    # @return [Boolean] +true+ if we're ready to go
    def check(say=false)
      check   = true
      check &&= !@states.empty?
      warn "@states is empty" if !check and say
      check &&= !@states["start"].nil?
      warn "@states[\"start\"] is missing" if !check and say
      return check
    end
    
    # Start the execution. CTRL-C (SIGINT) shuts down the loop in a controlled 
    # manner.
    # If the current state has its {FSM::State.timing} variable set to something
    # larger than 0, the action execution will be controlled by a {Metronome}.
    # @param [Symbol] from_state The name of the initial machine state.
    def run(from_state = 'start')
      @params.current_state = from_state
      previous_state = ''
      begin # main loop
        if @params.current_state != previous_state then
          @states[@params.current_state].run_on_enter
        end
        previous_state = @params.current_state
        if @states[@params.current_state].timing > 0 then
          warn "State #{@params.current_state} is enabling metronome!"
          @metronome.step = @states[@params.current_state].timing
          @metronome.start do |i|
            previous_state = @params.current_state
            @states[@params.current_state].run_in_loop
            :stop if @params.current_state.nil? || (previous_state != @params.current_state) || @shutdown
          end
          while @metronome.active? do
            Metronome.pause
          end
          warn "State #{@params.current_state} is stopping metronome!"
        else
          @states[@params.current_state].run_in_loop
        end
        @states[previous_state].run_on_exit
        @shutdown = true unless @states[@params.current_state]
      end until @shutdown
      puts "-- Done shutdown."
    end
    
  end
  
end