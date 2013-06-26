var strftime = function(date) {
  var hour = date.getHours(),
      min  = date.getMinutes(),
      sec  = date.getSeconds();

  if (hour < 10) { hour = "0" + hour; }
  if ( min < 10) {  min = "0" +  min; }
  if ( sec < 10) {  sec = "0" +  sec; }

  return hour + ":" + min + ":" + sec;
};


var lastTimestamp = undefined;
var seenTimestamp = {};
var pollNewMsg = function(isWidget) {
  var isWidget = (isWidget == null) ? false : isWidget;
  var time = lastTimestamp || (new Date()).getTime() / 1000.0;
  $.ajax({
    url: "/comet/poll/" + channel + "/" + time + "/updates.json",
    type: "get",
    async: true,
    cache: false,
    timeout: 60000,

    success: function (data) {
      var msgs = JSON.parse(data);
      for (var i = 0; i < msgs.length; i++) {
        var msg = msgs[i];
	if (seenTimestamp[msg.time]) { continue; }
	seenTimestamp[msg.time] = true;
        var date = new Date(parseFloat(msg["time"]) * 1000);
        var linkedMsg = msg["msg"].replace(/(http[s]*:\/\/[^\s]+)/, '<a href="$1">$1</a>');
        var msgElement = $("<li>").addClass("new-arrival")
          .append($("<span class=\"time\">").text(strftime(date)))
          .append($("<span class=\"nick\">").text(msg["nick"]))
          .append($("<span class=\"msg wordwrap\">").html(linkedMsg));
        if (isWidget) {
          $(".logs").prepend(msgElement);
        }
        else {
          $(".logs").append(msgElement);
        }
      }

      // there's new message
      if (msgs.length > 0) {
        if (isWidget) {
          // widget layout
          $(document).scrollTop(0);
        }
        else {
          // desktop or mobile layout, there's a switch to turn off auto-scrolling
          if (window.can_scroll) {
            $(document).scrollTop($(document).height());
          }
        }

        // if we're in desktop version
        if (typeof Cocoa !== "undefined" && Cocoa !== null) {
          Cocoa.requestUserAttention();
          Cocoa.addUnreadCountToBadgeLabel(msgs.length);
        }
      }
lastTimestamp = (new Date()).getTime() / 1000.0;
try {
      lastTimestamp = msgs[msgs.length - 1]["time"];
} catch (e) {};

setTimeout(function(){
      pollNewMsg(isWidget);
}, 3000);
    },

    error: function() {
      pollNewMsg(isWidget);
    }
  });
}

var enableDatePicker = function() {
  $('#date-picker').on('change', function(event) {
    var targetDate = this.value;
    location.href = location.href.replace(/[^\/]+$/, targetDate);
  })
}
enableDatePicker();

$(".scroll_switch").click(function() {
  window.can_scroll = $(".scroll_switch").hasClass("scroll_switch_off");
  $(".scroll_switch").toggleClass("scroll_switch_off");
});

var pageScrollTop = function(position) {
  $("html, body").animate({
    scrollTop: position
  }, 1000);
};
