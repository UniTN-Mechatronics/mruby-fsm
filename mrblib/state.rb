#*************************************************************************#
#                                                                         #
# state.rb - mruby gem provoding FSM                                      #
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

module FSM
  
  
  # Paradigm Class representing a state. Real states shall inherit from this 
  # one and override the following methods:
  # * {#action} (mandatory)
  # * {#inspect} (optional)
  class State
    # @!attribute [rw] testing
    #   If true, child classed don't raise on not implemented methods
    # @!attribute [rw] params
    #   The +Struct+ object containing all the {Machine} state parameters.
    # @!attribute [rw] name
    #   The name of the current State
    # @!attribute [rw] timing
    #   The timing for executing {#action} in seconds. Set to +nil+ for free run
    attr_accessor :testing, :params, :name, :timing
    
    # Initialization. Default value for {#testing} is false, so a 
    # +NotImplementedError+ is raised unless the child class correctly defines 
    # all the requested methods
    # @param [String] name The state name
    # @raise ArgumentError unless +state+ is a String
    def initialize(name)
      raise ArumentError unless name.kind_of? String
      @name = name
      @testing = false
      @params  = nil
      @timing  = 0
    end
    
    # Define actions to carry out while in current state. Implementation of 
    # this method shall explicitly set the {EPC::Machine#params}.current_state
    # to the name of the next invoked state.
    # @return [Object] To be defined yet
    # @raise NotImplementedError
    def action
      raise NotImplementedError unless @testing
      Metronome.sleep 0.1
      @params.update if @params.respond_to? :update
      print '.'
      @params.current_state = @name
    end
    
    # Action on state enter.
    # @return [String] Something to be printed
    def on_enter
      "> Entering #{@name} state."
    end
    
    # Give a state description.
    # @return [String] A description of the current state
    def inspect
      "\#<S.#{@name}: @params: #{@params.inspect}, @timing: #{@timing}>"
    end
    
  end
  
end