require "json"
require "cinch"
require "redis"
require "configuration"

Kernel.load "config/app.rb"
config = Configuration.load "app"

if ENV['LOGBOT_CHANNELS']
	channels = ENV['LOGBOT_CHANNELS'].split /[\s,]+/	
else 
	channels = config.channels
end

server = (ENV['LOGBOT_SERVER'] || config.server)
nick = (ENV['LOGBOT_NICK'] || config.nick)

redis = Redis.new(:thread_safe => true)

channels.each do |chan|
  redis.sadd("irclog:channels", "#{chan}")
end

bot = Cinch::Bot.new do
  configure do |conf|
    conf.server = server
    conf.nick = nick
    conf.channels = channels
  end

  on :message do |msg|
    if not msg.channel.nil?
      date = msg.time.strftime("%Y-%m-%d")
      key = "irclog:channel:#{msg.channel.name}:#{date}"
      redis.rpush(key, {
        :time => "#{msg.time.strftime("%s.%L")}",
        :nick => "#{msg.user.nick}",
        :msg  => "#{msg.message}"
      }.to_json)
    end
  end
end
bot.start
