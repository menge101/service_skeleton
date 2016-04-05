def method_missing(m, *_args, &_block)
  RACK_ENV == m.to_s.chop if m =~ /.*?\?/
end

def const_missing(name)
  raise "Undefined constant: #{name}" unless ENV.key?(name.to_s)
  ENV[name.to_s]
end
