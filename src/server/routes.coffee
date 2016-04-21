module.exports = (expressApp) ->
	expressApp.all '*', (req, res, next) ->
		next '404: ' + req.url
