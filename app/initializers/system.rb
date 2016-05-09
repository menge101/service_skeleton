def method_missing(m, *_args, &_block)
  return (RACK_ENV == m.to_s.chop) if m =~ /.*?\?/
  super
end
