God.watch do |w|
  w.name = "Logbot agent"
  w.start = "ruby /home/rails/logbot/logbot.rb"
  w.keepalive
end
