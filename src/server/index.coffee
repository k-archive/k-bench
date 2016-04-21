express = require 'express'
kclient = require 'k-client'
kclient.use(require('k-bundle'))
kmodel = require 'k-model'
racerhighway = require 'k-highway'
coffeeify = require 'coffeeify'
app = require '../app/index'
routes = require './routes'
errorMiddleware = require './error'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
compression = require 'compression'
expressSession = require 'express-session'
RedisStore = require('connect-redis')(expressSession)
expressApp = module.exports = express()
#multer = require 'multer'

# error catching, otherwise the app may crash if an uncaught error is thrown
kmodel.Model.INITS.push (model) ->
  model.root.on 'error', (err) -> console.log err

publicDir = __dirname + '/../../public'
store = null

###
store.shareClient.backend.addProjection "auths_public", "auths", 'json0',
  {
    id: true,
    timestamps: true,
    status: true,
    local: true
  }
###

createStore = (which, sharding) ->
  console.log "create store in #{which}"
  if which is 'arango'
    arangoUrl = if sharding then 'http://localhost:8530/kantele-cluster' else 'http://localhost:8529/kantele-app'
    store = kclient.createBackend
      db: require('k-livedb-arango')(arangoUrl)
  else if which is 'mongo'
    mongoUrl = process.env.MONGO_URL || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/kantele-app'
    store = kclient.createBackend
      db: require('k-livedb-mongo')(mongoUrl, safe: true)

createStore process.argv[2] or 'arango'

session = expressSession
  secret: process.env.SESSION_SECRET || 'session-secret-that-you-should-change'
  store: new RedisStore(host: process.env.REDIS_HOST || 'localhost', port: process.env.REDIS_PORT || 6379)
  resave: false
  saveUninitialized: false

racerhighwayHandlers = racerhighway store, session: session
module.exports.upgrade = racerhighwayHandlers.upgrade

store.on 'bundle', (browserify) ->
  # Add support for directly requiring coffeescript in browserify bundles
  browserify.transform coffeeify

expressApp
  # Gzip dynamically
  .use(compression({ threshold: 512 }))

  # Serve static files from the public directory
  .use(express.static publicDir)

  # Session middleware
  .use(cookieParser())
  .use(session)

  # websockets etc.
  .use(racerhighwayHandlers.middleware)

  # Add req.getModel() method
  .use(store.modelMiddleware())

  # Parse form data
  .use(bodyParser.urlencoded( extended: true ))

  # file uploads, enable if needed
  # .use(multer({ inMemory: true }))

  # Create an express middleware from the app's routes
  .use(app.router())

# access control
# enable when needed
# require('./access')(store.shareClient)

# server-side routes
routes expressApp

# finally, set the http error handler (404 etc)
expressApp.use(errorMiddleware)

app.writeScripts store, publicDir,
  extensions: [".coffee"]
  disableScriptMap: false
, (err) ->
  console.log err
  return
