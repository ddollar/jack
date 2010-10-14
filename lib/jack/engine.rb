require "beanstalk-client"
require "jack"
require "json"

module Jack::Engine

  extend self

  DEFAULT_DELAY    = 0
  DEFAULT_PRIORITY = 65536
  DEFAULT_TTR      = 120

  class InvalidHandler < RuntimeError; end
  class InvalidURI < RuntimeError; end
  class InvalidJobName < RuntimeError; end

  def job(name, &handler)
    raise InvalidHandler unless block_given?
    job_handlers[compile(name)] = handler
  end

  def error(&handler)
    raise InvalidHandler unless block_given?
    @@error_handler = handler
  end

  def enqueue(name, args={}, options={})
    ttr = options[:ttr] || DEFAULT_TTR

    beanstalk.use name
    beanstalk.put [ name, args ].to_json, DEFAULT_PRIORITY, DEFAULT_DELAY, ttr
  end

  def run(queues=nil)
    queues ||= ['*']
    log "started: #{queues.join(" ")}"

    loop do
      available = beanstalk.list_tubes.values.flatten
      desired   = available.select { |q| match(job_handlers.keys, q) }
      watched   = beanstalk.list_tubes_watched.values.flatten

      (desired - watched).each do |watch|
        log "watching: #{watch}"
        beanstalk.watch(watch)
      end

      begin
        job = beanstalk.reserve(5)
      rescue Beanstalk::TimedOut
        next
      end

      name, args = JSON.parse(job.body)
      handler = match(job_handlers.keys, name)

      unless handler
      end

      if splat = handler.match(name)[1]
        args["splat"] = splat
      end

      begin
        job_handlers[handler].call(args)
        job.delete
      rescue SystemExit
        raise
      rescue => e
        log "error:#{e.message}"
        log "burying:#{job.id}"
        job.bury rescue nil
      end
    end
  end

private ######################################################################

  def beanstalk
    @@beanstalk ||= Beanstalk::Pool.new([ beanstalk_host_and_port ])
  end

  def beanstalk_url
    ENV["BEANSTALK_URL"] || "beanstalk://localhost/"
  end

  def beanstalk_host_and_port
    uri = URI.parse(beanstalk_url)
    raise(InvalidURI, beanstalk_url) if uri.scheme != "beanstalk"
    return "#{uri.host}:#{uri.port || 11300}"
  end

  def compile(name)
    raise InvalidJobName if name.gsub(/[^\*]/, "").length > 1
    ccc = Regexp.new("^#{name.gsub("*", "([a-z\.]+)")}$")
    puts "NAME:#{name} CCC:#{ccc.inspect}"
    ccc
  end

  def error_handler
    @@error_handler ||= lambda { default_error_handler }
  end

  def job_handlers
    @@job_handlers ||= {}
  end

  def log(message)
    puts "[%s] [jack:%s] %s" % [ Time.now, $$, message ]
  end

  def match(list, item)
    list.sort_by(&:to_s).reverse.detect { |regex| item =~ regex }
  end

end
