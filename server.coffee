kclient = require "k-client"

run = (app) ->
  app = require(app) if typeof app is "string"

  listenCallback = (err) ->
    console.log "%d listening.", process.pid
    return

  createServer = ->
    require("http").createServer(app).listen(process.env.PORT or 3000, listenCallback).on('upgrade', app.upgrade)

  kclient.run createServer
  return

run __dirname + "/src/server"
