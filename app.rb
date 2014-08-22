# encoding: utf-8
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "json"
require "time"
require "date"
require "cgi"
require "sinatra/base"
require "sinatra/async"
require "redis"
require "compass"
require "eventmachine"

$redis = Redis.new(:thread_safe => true)

module IRC_Log
  class App < Sinatra::Base
    configure do
      set :protection, :except => :frame_options
    end

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
          # date in "%Y-%m-%d" format (e.g. 2013-01-01)
          @date = date
      end

      @channel = channel

      @msgs = $redis.lrange("irclog:channel:##{channel}:#{@date}", 0, -1)
      @msgs = @msgs.map {|msg|
        msg = JSON.parse(msg)
        msg["msg"] = CGI.escapeHTML(msg["msg"])
        if msg["msg"] =~ /^\u0001ACTION (.*)\u0001$/
          msg["msg"].gsub!(/^\u0001ACTION (.*)\u0001$/, "<span class=\"nick\">#{msg["nick"]}</span>&nbsp;\\1")
          msg["nick"] = "*"
        end
        msg
      }

      erb :channel
    end

    get "/widget/:channel" do |channel|
      @channel = channel
      today = Time.now.strftime("%Y-%m-%d")
      @msgs = $redis.lrange("irclog:channel:##{channel}:#{today}", -25, -1)
      @msgs = $redis.lrange("irclog:channel:##{channel}:#{today}", -25, -1)
      @msgs = @msgs.map {|msg|
        ret = JSON.parse(msg)
        ret["msg"] = CGI.escape(ret["msg"])
        ret
      }.reverse

      erb :widget
    end
  end
end


module Comet
  class App < Sinatra::Base
    register Sinatra::Async

    get %r{/poll/(.*)/([\d\.]+)/updates.json} do |channel, time|
      date = Time.at(time.to_f).strftime("%Y-%m-%d")
      msgs = $redis.lrange("irclog:channel:##{channel}:#{date}", -10, -1).map{|msg|
        ret = ::JSON.parse(msg)
        ret["msg"] = CGI.escapeHTML(ret["msg"])
        ret
      }
      if (not msgs.empty?) && msgs[-1]["time"] > time
        return msgs.select{|msg| msg["time"] > time }.to_json
      end

      EventMachine.run do
        n, timer = 0, EventMachine::PeriodicTimer.new(0.5) do
          msgs = $redis.lrange("irclog:channel:##{channel}:#{date}", -10, -1).map{|msg|
            ret = ::JSON.parse(msg)
            ret["msg"] = CGI.escapeHTML(ret["msg"])
            ret
          }
          if (not msgs.empty?) && msgs[-1]["time"] > time || n > 120
            timer.cancel
            return msgs.select{|msg| msg["time"] > time }.to_json
          end
          n += 1
        end
      end
    end
  end
end
