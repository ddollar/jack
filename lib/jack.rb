module Jack

  VERSION = "0.0.1"

  def self.enqueue(name, args={}, options={})
    require "jack/engine"
    Jack::Engine.enqueue(name, args, options)
  end

end
