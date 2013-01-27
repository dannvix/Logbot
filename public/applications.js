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
        var date = new Date(parseFloat(msg["time"]) * 1000);
        var linkedMsg = msg["msg"].replace(/(http[s]*:\/\/[^\s]+)/, '<a href="$1">$1</a>');
        var msgElement = $("<li>").addClass("new-arrival")
          .append($("<span class=\"time\">").text(strftime(date)))
          .append($("<span class=\"nick\">").text(msg["nick"]))
          .append($("<span class=\"msg\">").html(linkedMsg));
        if (isWidget) {
          $(".logs").prepend(msgElement);
        }
        else {
          $(".logs").append(msgElement);
        }
      }

      if (!isWidget) {
        $(document).scrollTop($(document).height());
      }
      else {
        $(document).scrollTop(0);
      }

      lastTimestamp = msgs[msgs.length - 1]["time"];
      pollNewMsg(isWidget);
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
