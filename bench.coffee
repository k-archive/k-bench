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
			url = 'http://root:@localhost:8529/kantele-app'
			npm = 'k-livedb-arango'
			break
		when 'arango-sharding'
			url = 'http://root:@localhost:8530/kantele-cluster'
			npm = 'k-livedb-arango'
			break
		when 'mongo'
			url = 'mongodb://localhost:27017/kantele-app'
			npm = 'k-livedb-mongo'
			break
		when 'mongo-sharding'
			url = 'mongodb://localhost:27011/somecl'
			npm = 'k-livedb-mongo'
			break

	store = kmodel.createBackend
		db: require(npm)(url, safe: true)

db = process.argv[2]

if db not in ['mongo', 'arango', 'arango-sharding', 'mongo-sharding']
	console.log ''
	console.log 'Usage:'
	console.log ''
	console.log 'node bench.js <db> [cmd]'
	console.log ''
	console.log 'db should be:', ['mongo', 'arango', 'arango-sharding', 'mongo-sharding']
	console.log 'cmd should be:', ['populate', 'clear']
	console.log ''
	process.exit()

createStore db
model = store.createModel()

class Timer
	t: 0
	t2: 0
	total: 0
	count: 0
	min: 999
	max: 0
	avg: 0

	start: ->
		@t = Date.now()

	increment: ->
		@t2 = Date.now() - @t
		@count++
		@total += @t2
		@avg = (@total / @count)
		@min = Math.min(@min, @t2)
		@max = Math.max(@max, @t2)

	end: (s, items) ->
		@increment()
		console.log "#{s} #{items?.get()?.length or 0}\t Average: #{Math.round(@avg)}\t Now: #{@t2}\t Min: #{@min}\t Max: #{@max}"

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
	t1.start()
	items = model.query 'items', {}
	model.subscribe items, (err) ->
		console.log(err) if err
		if err
			process.exit()
		else
			t1.end('Got', items)
			#t2.start()
			items.unsubscribe ->
				#t2.end('Unsub')
				setTimeout go, 100

t1 = new Timer()
t2 = new Timer()

switch process.argv[3]
	when 'populate' then populate()
	when 'clear' then clear()
	else go()

