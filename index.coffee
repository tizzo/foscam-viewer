#! /usr/bin/env coffee
fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'
MjpegProxy = require('mjpeg-proxy').MjpegProxy
yaml = require 'js-yaml'
cam = require 'foscam'

configPath = process.argv[2] || __dirname + '/default-config.yaml'
config = yaml.safeLoad fs.readFileSync configPath

cam.setup
  host: config.camera.host
  port: config.camera.port
  user: config.camera.user
  pass: config.camera.pass

app = express()

baseUrl = "#{config.camera.protocol}://#{config.camera.host}"
mjpegUrl = "#{baseUrl}/videostream.cgi?user=#{config.camera.user}&pwd=#{config.camera.pass}"
app.get config.pathPrefix + '/cam.mjpg', new MjpegProxy(mjpegUrl).proxyRequest

app.get config.pathPrefix, (req, res)->
  output = "
    <html>
      <head>
        <script>window.controlUrl = '" + config.pathPrefix + "/control';</script>
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/zepto/1.1.4/zepto.js\"></script>
        <script src=\"" + config.pathPrefix + "/script.js\"></script>
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
        <img src=\"" + config.pathPrefix + "/cam.mjpg\" />
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

app.post config.pathPrefix + '/control', bodyParser.json(), (req, res)->
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



app.get config.pathPrefix + '/script.js', (req, res)->
  res.writeHead 200,
    'Content-Type': 'application/javascript'
  fs.createReadStream 'client.js'
    .pipe res

app.listen config.port, ->
  console.log "Now listening on #{config.port}"

