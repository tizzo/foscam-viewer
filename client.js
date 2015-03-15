
var downKeys = {};

var keyMapping = {
  39: 'left',
  37: 'right',
  38: 'up',
  40: 'down',
}

var sendCommand = function(command) {
  $.ajax({
    // The app sets this as a global variable.
    url: window.controlUrl,
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({ action: command }),
  });
}

var keyHandler = function(action, e) {
  var key = e.which;

  if (!keyMapping[key]) return;
  if (action == 'down' && downKeys[key]) return;

  if (action == 'down') {
    downKeys[key] = true;
  }
  else {
    delete downKeys[key];
  }

  var direction = keyMapping[key];

  var command = (action == 'down') ? '' : 'stop ';
  command += direction;

  sendCommand(command);
  
}

$(document).keydown(keyHandler.bind(null, 'down'));
$(document).keyup(keyHandler.bind(null, 'up'));

Zepto(function($){

  var startHandler = function(e) {
    sendCommand($(this).attr('id'));
  };

  var stopHandler = function(e) {
    sendCommand('stop ' + $(this).attr('id'));
  };

  var $controls = $('div#controls');

  $('#ir-on').click(function() { sendCommand('io output high'); });
  $('#ir-off').click(function() { sendCommand('io output low'); });

  $('#arrows a i', $controls).each(function() {
    var element = document.getElementById($(this).attr('id'));
    // There may be a better way, but for now detect whether we are on mobile.
    if ('ontouchstart' in document.documentElement) {
      element.addEventListener('touchstart', startHandler);
      element.addEventListener('touchend', stopHandler);
    }
    else {
      element.addEventListener('mouseup', stopHandler);
      element.addEventListener('mousedown', startHandler);
    }
  });
});
