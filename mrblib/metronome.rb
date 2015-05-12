#!/usr/bin/env ruby
# untitled.rb

# Created by Paolo Bosetti on 2011-04-21.
# Copyright (c) 2011 University of Trento. All rights reserved.


# A module and a class ({Metronome::Operation}) for implementing a recurring 
# call as deterministic as possible.
#
# See {Metronome::Operation} for usage details. Module functions are FFI 
# wrappers and are not intended to be used directly.
# @author Paolo Bosetti
# @todo Are there better ways?
module Metronome  
    
  # Implements a recurring operation.
  # @example General usage. Note the +sleep+ call.
  #   op = Metronome::Operation.new(0.5)
  #   op.start(10) do |i|
  #     puts "Ping #{i}"
  #   end
  # 
  #   Signal.trap("SIGINT") do
  #     print "Stopping recurring process..."
  #     op.stop
  #     puts "done!"
  #   end
  # 
  #   sleep(0.2) while op.active?  # THIS IS IMPORTANT!!!
  #
  # @author Paolo Bosetti
  class Operation
    
    # @!attribute [rw] strict_timing
    #   If true, raise a {RealTimeError} when +TET+ >= +step+
    #   (default to +false+)
    attr_accessor :strict_timing
    
    # @!attribute [r] tet
    #   The Task Execution Time
    # @!attribute [r] step
    #   The time step in seconds
    attr_reader :step, :tet
    # Initializer
    # @param [Numeric] step the timestep in seconds
    def initialize(step)
      @step          = step
      @active        = false
      @lock          = false
      @strict_timing = false
      @tet           = 0
    end
    
    # Sets the time step (in seconds) and reschedule pending alarms.
    # @param [Numeric] secs Timestep in seconds
    def step=(secs)
      @step = secs
      self.schedule
    end
    
    # Updates scheduling of pending alarms. 
    # @note Usually, there's no need to call this, since {#step=} automatically 
    #       calls it after having set the +@step+ attribute.
    def schedule
      usecs = @step * 1E6
      Metronome::ualarm(usecs, usecs)
    end
    
    # Tells id the recurring operation is active or not.
    # @return [Boolean] the status of the recurring alarm operation
    def active?; @active; end
    
    # Starts a recurring operation, described by the passed block.
    # If the block returns the symbol :stop, the recurrin operation gets 
    # disabled.
    # @param [Fixnum,nil] n_iter the maximum number of iterations. 
    #   If nil it loops indefinitedly
    # @yieldparam [Fixnum] i the number of elapsed iterations
    # @yieldparam [Numeric] tet the Task Execution Time of previous step
    # @raise [ArgumentError] unless a block is given
    # @raise [RealTimeError] if TET exceeds @step
    def start(n_iter=nil)
      @active = true
      i = 0
      raise ArgumentError, "Need a block!" unless block_given?
      Signal.trap(:ALRM) do
        # If there is still a pending step, raises an error containing
        # information about the CURRENT step
        if @lock then
          if @strict_timing
            @lock = false
            raise RealTimeError.new({:tet => @tet, :step => @step, :i => i, :time => Time.now})
          end
        else
          start = Time.now
          @lock = true
          result = yield(i, @tet)
          i += 1
          self.stop if (n_iter and i >= n_iter)
          self.stop if (result.kind_of? Symbol and result == :stop)
          @tet = Time.now - start
          @lock = false
        end
      end
      self.schedule
    end
    
    # Stops the recurring process by resetting alarm and disabling management
    # of SIGALRM signal.
    def stop
      Metronome::ualarm(0, 0)
      Signal.trap(:ALRM, "DEFAULT")
      @active = false
      @lock = false
    end
  end
end

class RealTimeError < RuntimeError
  attr_reader :status
  def initialize(status)
    @status = status
  end
  def ratio
    (@status[:tet] / @status[:step]) * 100
  end
end



