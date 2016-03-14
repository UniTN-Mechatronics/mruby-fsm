MRuby::Gem::Specification.new('mruby-fsm') do |spec|
  spec.license = 'GPL 2.0'
  spec.author  = 'Paolo Bosetti, University of Trento'
  spec.summary = 'Finite State Machine library'
  spec.version = 0.1
  spec.description = spec.summary
  spec.homepage = "https://github.com/UniTN-Mechatronics/mruby-fsm"
  spec.add_dependency 'mruby-signal'
end
