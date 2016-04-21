app = require('../app')

module.exports = (err, req, res, next) ->
  if not err then return next()

  model = req.getModel()
  status = parseInt(err.status or err.message or err.toString())
  message = err.message or err.toString()
  page = app.createPage req, res, next
  model.set '_page.status', status
  model.set '_page.msg', err.message || err
  model.set '_page.url', req.url

  if status in [403, 404, 500]
    page.render "error:#{status}"
  else
    page.render "error"
