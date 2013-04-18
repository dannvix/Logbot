require "json"
require "redis"

require "logger"
log = Logger.new(STDERR)
log.level = Logger::INFO

redis = Redis.new(:thread_safe => true)

channels = redis.smembers("irclog:channels")
log.info("channels: #{channels.join(", ")}")

channels.each do |channel|
  log.info("migration channel #{channel}")
  channel_key = "irclog:channel:#{channel}"

  messages = redis.lrange(channel_key, 0, -1)
  messages.each do |message|
    parsed_msg = JSON.parse(message)
    datestamp = Time.at(parsed_msg["time"].to_f).strftime("%Y-%m-%d")
    redis.rpush("#{channel_key}:#{datestamp}", message)
  end

  redis.del(channel_key)
  log.info("channel #{channel} migrated and deleted")
end

log.info("all channels migrated")