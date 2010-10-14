# worker

job "alpha.one" do |args|
  log "in alpha.one"
  log args.inspect
end

job "alpha.two" do |args|
  log "in alpha.two"
  log args.inspect
end

job "bravo.*" do |args|
  log "in bravo.*"
  log args.inspect
end

job "delta.*" do |args|
  log "in delta.*"
  raise "foo"
end
