def method_missing(m, *_args, &_block)
  return (RACK_ENV == m.to_s.chop) if m =~ /.*?\?/
  super
end

def const_missing(name)
  return ENV[name.to_s] if ENV.key?(name.to_s)
  super
end
