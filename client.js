
var downKeys = {};

var keyMapping = {
  39: 'left',
  37: 'right',
  38: 'up',
  40: 'down',
}

var keyHandler = function(action, e) {
  var key = e.which;

  if (!keyMapping[key]) return;
  if (action == 'down' && downKeys[key]) return;
  console.log(action == 'down', downKeys[key], downKeys);

  if (action == 'down') {
    downKeys[key] = true;
  }
  else {
    delete downKeys[key];
  }

  var direction = keyMapping[key];

  //console.log('direction', direction, 'action', action);
  var command = (action == 'down') ? '' : 'stop ';
  //console.log('command', command);
  //*
  $.ajax({
    url: 'foscam/control',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({ action: command + direction }),
    success: function() { console.log(arguments) },
    failure: function() { console.log(arguments) },
  });
  //*/
}
$(document).keydown(keyHandler.bind(null, 'down'));
$(document).keyup(keyHandler.bind(null, 'up'));
