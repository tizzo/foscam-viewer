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

app = express()

app.get '/', (req, res)->
  res.writeHead 301,
    'Location': "/foscam"
  res.end()

app.get '/foscam/cam1.jpg', new MjpegProxy('http://192.168.1.6/videostream.cgi?user=admin&pwd=').proxyRequest

app.get '/foscam', (req, res)->
  output = "
    <html>
      <head>
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/zepto/1.1.4/zepto.js\"></script>
        <script src=\"/foscam/script.js\"></script>
      </head>
      <body>
        <img src=\"/foscam/cam1.jpg\" />
      </body>
    </html>
  "
  #req.writeHead 200
  res.send output

app.post '/foscam/control', bodyParser.json(), (req, res)->
  acceptableAction = [
    'left',
    'stop left',
    'right',
    'stop right',
    'up',
    'stop up',
    'down',
    'stop down',
  ]

  if (!req.body.action || acceptableAction.indexOf(req.body.action) == -1)
    res.writeHead 401
    res.end 'Invalid request'

  cam.control.decoder req.body.action
  res.writeHead 201
  res.end()



app.get '/foscam/script.js', (req, res)->
  res.writeHead 200,
    'Content-Type': 'application/javascript'
  fs.createReadStream 'client.js'
    .pipe res

app.listen 3000

