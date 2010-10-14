require "rubygems"
require "parka/specification"

Parka::Specification.new do |gem|
  gem.name     = "jack"
  gem.version  = Jack::VERSION
  gem.summary  = "Job queueing system on top of beanstalkd"
  gem.homepage = "http://github.com/ddollar/jack"

  gem.executables  = "jack"
end
