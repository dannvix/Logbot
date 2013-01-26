# encoding: utf-8
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "json"
require "time"
require "sinatra/base"
require "sinatra/async"
require "redis"
require "compass"
require "eventmachine"

@@redis = Redis.new(:thread_safe => true)

module IRC_Log
  class App < Sinatra::Base
    get "/" do
      redirect "/channel/g0v.tw/today"
    end

    get "/channel/:channel" do |channel|
      redirect "/channel/#{channel}/today"
    end

    get "/channel/:channel/:date" do |channel, date|
      case date
        when "today"
          @date = Time.now.strftime("%F")
        when "yesterday"
          @date = (Time.now - 86400).strftime("%F")
        else
          @date = date
      end

      # @channels = @@redis.smembers("irclog:channels")
      @channel = channel

      @msgs = @@redis.lrange("irclog:channel:##{channel}", 0, -1)
      @msgs = @msgs.map {|msg| JSON.parse(msg) }
      @msgs = @msgs.select {|msg| d = Time.at(msg["time"].to_f) - Time.parse(@date); d >= 0 && d <= 86400 }

      haml :channel
    end
  end
end


module Comet
  class App < Sinatra::Base
    register Sinatra::Async

    get "/poll/:channel/:time/updates.json" do |channel, time|
      msgs = @@redis.lrange("irclog:channel:##{channel}", -10, -1).map{|msg| ::JSON.parse(msg) }
      if msgs[-1]["time"] > time
        msgs.select{|msg| msg["time"] > time }.to_json
      end
      
      EventMachine.run do
        n, timer = 0, EventMachine::PeriodicTimer.new(0.5) do
          msgs = @@redis.lrange("irclog:channel:##{channel}", -10, -1).map{|msg| ::JSON.parse(msg) }
          if msgs[-1]["time"] > time || n > 120
            timer.cancel
            return msgs.select{|msg| msg["time"] > time }.to_json
          end
          n += 1
        end
      end
    end
  end
end
