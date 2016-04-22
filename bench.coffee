kmodel = require 'k-model'

# error catching, otherwise the app may crash if an uncaught error is thrown
kmodel.Model.INITS.push (model) ->
  model.root.on 'error', (err) -> console.log err

publicDir = __dirname + '/../../public'
store = null

createStore = (which) ->
  console.log "create store in #{which}"
  switch which
    when 'arango'
      url = 'http://localhost:8529/kantele-app'
      npm = 'k-livedb-arango'
      break
    when 'arango-sharding'
      url = 'http://localhost:8530/kantele-cluster'
      npm = 'k-livedb-arango'
      break
    when 'mongo'
      url = 'mongodb://localhost:27017/kantele-app'
      npm = 'k-livedb-mongo'
      break

  store = kmodel.createBackend
    db: require(npm)(url, safe: true)

db = process.argv[2] or 'arango'

if db not in ['mongo', 'arango', 'arango-sharding']
  console.log 'db should be:', ['mongo', 'arango', 'arango-sharding']
  process.exit()

createStore db
model = store.createModel()

t = t2 = 0
timer = 0
total = 0
count = 0
start = false
min = 999
max = 0
avg = 0

increment = ->
  t2 = Date.now() - t
  count++
  total += t2
  avg = (total / count)
  min = Math.min(min, t2)
  max = Math.max(max, t2)

stop = ->
  clearTimeout timer
  start = false

start = ->
  total = 0
  count = 0
  min = 999
  max = 0
  start = true
  setTimeout (=> @app.history.push '/'), 100

clear = ->
  items = model.query 'items', {}
  model.subscribe items, (err) ->
    items = items.get()
    console.log 'clear', db, items?.length
    if items
      for item in items
        model.root.del "items.#{item.id}"
    model.whenNothingPending (-> process.exit())

populate = ->
  console.log 'populate 100 in', db
  for num in [1..100]
    model.root.add 'items', {
      name: Math.random().toString(36).substring(15),
      data: Math.random().toString(36).substring(15)
    }
  model.whenNothingPending (-> process.exit())

go = ->
  t = Date.now()
  items = model.query 'items', {}
  model.subscribe items, (err) ->
    console.log(err) if err
    if err
      process.exit()
    else
      increment()
      console.log "got #{items?.get()?.length}\t Average: #{Math.round(avg)}\t Now: #{t2}\t Min: #{min}\t Max: #{max}"
      items.unsubscribe ->
        timer = setTimeout go, 100


switch process.argv[3]
  when 'populate' then populate()
  when 'clear' then clear()
  else go()

