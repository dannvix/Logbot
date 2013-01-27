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
var pollNewMsg = function() {
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
        $(".logs").append($("<li>").addClass("new-arrival")
          .append($("<span class=\"time\">").text(strftime(date)))
          .append($("<span class=\"nick\">").text(msg["nick"]))
          .append($("<span class=\"msg\">").html(linkedMsg))
        );
      }

      $(document).scrollTop($(document).height());

      lastTimestamp = msgs[msgs.length - 1]["time"];
      pollNewMsg();
    },

    error: function() {
      pollNewMsg();
    }
  });
}

var enableDatePicker = function() {
  $('#date-picker').on('change', function(event) {
    var targetDate = this.value;
    location.href = location.href.replace(/[^\/]+$/, targetDate);
  })
}

pollNewMsg();
enableDatePicker();