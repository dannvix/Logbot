from    base:latest
run     echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu precise main" >> /etc/apt/sources.list
run     echo "deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main" >> /etc/apt/sources.list
run     apt-get update
run     apt-get install --force-yes -y ruby1.9.1 rubygems redis-server
add     .  /
run	gem install bundler
run     apt-get install --force-yes -y ruby1.9.1-dev
run 	bundle install
run     compass compile
run     cp logbot.rb.example logbot.rb
expose  6379
expose  :5000
env     LOGBOT_NICK logbot_
env     LOGBOT_SERVER irc.freenode.net
env     LOGBOT_CHANNELS #test56
cmd     ["sh", "-c", "/usr/bin/redis-server | foreman start"]
