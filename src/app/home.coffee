app = require './index'

t = 0
timer = 0
total = 0
count = 0
start = false
min = 999
max = 0

increment = ->
	t2 = Date.now() - t
	count++
	total += t2
	@model.set '_a.count', count
	@model.set '_a.avg', (total / count)
	min = Math.min(min, t2)
	max = Math.max(max, t2)
	@model.set '_a.min', min
	@model.set '_a.max', max

app.proto.stop = ->
	clearTimeout timer
	@model.del '_a.start'
	start = false

app.proto.start = ->
	@model.set '_a.avg', 0
	total = 0
	count = 0
	min = 999
	max = 0
	start = true
	@model.set '_a.start', true
	setTimeout (=> @app.history.push '/'), 100

app.proto.clear = ->
	items = @model.root.get '_page.items'
	if items
		for item in items
			@model.root.del "items.#{item.id}"

app.proto.populate = ->
	for num in [1..100]
		@model.root.add 'items', { name: Math.random().toString(36).substring(15), data: Math.random().toString(36).substring(15) }

app.get '/', (page, model, params, next) ->
	t = Date.now()
	items = model.query 'items', {}
	model.subscribe items, (err) =>
		model.ref '_page.items', items
		if start
			increment.call @
			timer = setTimeout (=> @app.history.push '/'), 200
		page.render 'home'

