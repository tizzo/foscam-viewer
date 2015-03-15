fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'
MjpegProxy = require('mjpeg-proxy').MjpegProxy
cam = require 'foscam'

cam.setup
  host: '192.168.1.6',
  port: 80,
  user: 'admin',
  pass: ''

config = {}
config.prefix = ''

app = express()

app.get config.prefix + '/cam.mjpg', new MjpegProxy('http://192.168.1.6/videostream.cgi?user=admin&pwd=').proxyRequest

app.get config.prefix, (req, res)->
  output = "
    <html>
      <head>
        <script>window.controlUrl = '" + config.prefix + "/control';</script>
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/zepto/1.1.4/zepto.js\"></script>
        <script src=\"" + config.prefix + "/script.js\"></script>
        <link rel=\"stylesheet\" href=\"//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css\">
        <style>
          a { color: black; }
          img {
            width: 80%;
          }
          #controls {
            -webkit-user-select: none;
            -webkit-touch-callout: none;
            -khtml-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
          }
          #ir-on {
            color: white;
            background: black;
            border-radius: 6px;
            padding: 0 0.2em
          }
        </style>
      </head>
      <body>
        <img src=\"" + config.prefix + "/cam.mjpg\" />
        <div id=\"controls\">
          <span id=\"arrows\">
            <a href=\"#\"><i id=\"right\" class=\"fa fa-4x fa-arrow-left\"></i></a>
            <a href=\"#\"><i id=\"up\" class=\"fa fa-4x fa-arrow-up\"></i></a>
            <a href=\"#\"><i id=\"down\" class=\"fa fa-4x fa-arrow-down\"></i></a>
            <a href=\"#\"><i id=\"left\" class=\"fa fa-4x fa-arrow-right\"></i></a>
          </span>
          <a href=\"#\"><i id=\"ir-off\" class=\"fa fa-4x fa-lightbulb-o\"></i></a>
          <a href=\"#\"><i id=\"ir-on\" class=\"fa fa-4x fa-lightbulb-o\"></i></a>
        </div>
        <div id=\"log\">
        </div>
      </body>
    </html>
  "
  #req.writeHead 200
  res.send output

app.post config.prefix + '/control', bodyParser.json(), (req, res)->
  acceptableAction = [
    'left',
    'stop left',
    'right',
    'stop right',
    'up',
    'stop up',
    'down',
    'stop down',
    'io output low',
    'io output high',
  ]

  if (!req.body.action || acceptableAction.indexOf(req.body.action) == -1)
    res.writeHead 401
    res.end 'Invalid request'

  cam.control.decoder req.body.action
  res.writeHead 201
  res.end()



app.get config.prefix + '/script.js', (req, res)->
  res.writeHead 200,
    'Content-Type': 'application/javascript'
  fs.createReadStream 'client.js'
    .pipe res

app.listen 3000

