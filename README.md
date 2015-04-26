Logbot
======
Logbot is a simple IRC logger with realtime web-based viewer.


Screenshot
----------
![Logbot screnshot](https://raw.github.com/Dannvix/Logbot/master/screenshot.png)


How to Deploy
-------------
* Use Docker
    1. Install [Docker](https://www.docker.com/)
    2. Run `docker run -e LOGBOT_NICK=xxxx -e LOGBOT_CHANNELS=#x,#y,#z -e LOGBOT_SERVER=168.95.1.1 dannvix/logbot`
    3. Visit [http://localhost:5000](http://localhost:5000)

* Manual installation
    1. Ruby (1.9.3+) and Redis server must be installed
    2. Run `bundle install` to install required Ruby gems
    3. Run `compass compile` to compile Sass files
    4. Fire up your `redis-server`
    5. Specify target channels in `config/app.rb`
    6. Run `foreman start` to launch web server (WEBrick) and Logbot agent
    7. Visit [http://localhost:5000](http://localhost:5000).


FAQ
-----------------
* How to change default web listening port
	- *Edit "web:" command in Procfile*
* Is there mobile version of LogBot page?
	- *Yes, beside of RWD-ish design of normal page there is also ***widget*** view available. To view it use http://localhost:5000/***widget***/#channel instead of http://localhost:5000/***channel***/#channel/today.*
	- *Note: in widget view the newest messages are append on ***top*** of the page*
* Can LogBot log channels on multiple servers at the same time?
	- *Unfortunately not, you can log as many channels as you wish with single instance but only as long as all of them are on the same server. But you can always run second LogBot instance, just duplicate LogBot directory and ***change port in Procfile***.*

How to Contribute
-----------------
Just hack it and send me pull requests ;)


Resource
--------
* See [g0v/Logbot](https://github.com/g0v/Logbot) for many bugfixes and enhancements.


License
-------
Licensed under the [MIT license](http://opensource.org/licenses/mit-license.php).

Copyright (c) 2013 Shao-Chung Chen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
