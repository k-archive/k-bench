getMethod = (opData, op) ->
  if opData.create then return 'create'
  if opData.del then return 'del'
  if op?
    if op.od != undefined and op.oi then return 'change'
    if op.oi != undefined then return 'set'
    if op.od != undefined then return 'del'
    if op.oi is null then return 'del'
    if op.li != undefined and op.ld then return 'change'
    if op.li != undefined then return 'insert'
    if op.ld != undefined then return 'remove'
    if op.si != undefined then return 'string-ins'
    if op.sd != undefined then return 'string-del'
    if op.na != undefined then return 'increment'
  console.log 'could not find method'
  console.log 'opData', opData
  console.log 'op', op

module.exports = (shareClient) ->
  # Hold on to session object for later use. The HTTP req object is only
  # available in the connect event
  shareClient.use 'connect', (shareRequest, next) ->
    shareRequest.agent.connectSession = shareRequest.req.session
    next()

  shareClient.filter (collection, docName, docData, next) ->
    validateDocRead(
      this,
      collection,
      docName,
      docData.data,
      next
    )

  shareClient.use 'submit', (shareRequest, next) ->
    opData = shareRequest.opData
    opData.connectSession = shareRequest.agent.connectSession
    opData.collection = shareRequest.collection
    opData.docName = shareRequest.docName
    next()

  shareClient.preValidate = (opData, docData) ->

    # Validators is a list of functions to be called in the validate hook with
    # the mutated document data. Note that ShareJS mutates the document without
    # copying it first, so any values being compared against the original
    # document should be cached by value in the closure scope. They should NOT
    # be accessed from the document object in the validator
    opData.validators = []
    session = opData.connectSession

    # A ShareJS op is a list of mutations to be applied to a given document.
    # Most of the time, this will be a single mutation. If so, we only have
    # to check against that particular path
    d = docData.data || opData.op?[0]?.create?.data

    if !opData.op || opData.op.length is 1
      return preValidateWrite(
        session,
        opData.validators,
        getMethod opData, opData.op?[0]
        opData.op?[0],
        opData.collection,
        opData.docName,
        opData.op?[0].p || [],
        docData.data || opData.create?.data
      )

    # Otherwise, we need to check for an error for each unique path being
    # modified within the document
    pathMap = {}
    for component in opData.op
      path = component.p || []
      key = path.join '.'
      pathMap[key] =
        path: component.p
        method: getMethod opData, component
        op: component

    for key, obj of pathMap
      err = preValidateWrite(
        session,
        opData.validators,
        obj[method]
        op,
        opData.collection,
        opData.docName,
        obj[path],
        docData.data || op?.create?.data
      )
      return err if err

    return

  shareClient.validate = (opData, docData) ->
    return unless opData.validators.length
    doc = docData.data
    for fn in opData.validators
      err = fn doc, opData
      return err if err
    return

validateDocRead = (agent, collection, docId, doc, next) ->
  session = agent.connectSession
  userId = session?.userId

  unless session
    console.error 'Warning: Doc read access no session ', collection, docId
    return next '403: No session'

  unless userId
    console.error 'Warning: Doc read access no session.userId ', collection, docId, session
    return next '403: No session.userId'

  ## APP SPECIFIC ACCESS RULES HERE ##

  if collection in ['auths']
    unless docId is userId
      return next "403: Cannot read #{collection} who is not you.. (#{docId}, #{userId})"

  # Allow access to all documents within an account
  return next()

# This function must be synchronous for important performance reasons. Any data
# needed to check access control rules must be fetched and stored on the session
# because the write is submitted
preValidateWrite = (session, validators, method, opData, collection, docId, path, doc) ->

  userId = session?.userId
  admin = session?.admin
  loggedIn = session?.loggedIn
  fullPath = path.join('.');

  unless session
    console.error 'Warning: Write access no session', arguments...
    return '403: No session'

  unless userId
    console.error 'Warning: Write access no session.userId', arguments...
    return '403: No session.userId'

  unless docId
    console.error 'Warning: Write access no docId', arguments...
    return '403: No docId'

  # validators = opData.validators

  # Don't allow any user to modify a document in a different account
  unless doc
    console.error 'Error: No document snapshot or create data', arguments...
    return '403: No document snapshot or create data'

  # As a general pattern, if a user can typically edit a document type except
  # under certain conditions, a validator function must be used to ensure that
  # the condition is met after mutation. In such blacklisting cases, checking
  # the path is NOT sufficient, as the entire document or a parent path might
  # be edited instead.
  #
  # In contrast, if a user cannot typically edit a document type. It is OK
  # to whitelist specific modifications by path.

  if collection in ['auth_try']
    return

  if collection in ['auths']
    return "403: Cannot modify #{collection} who is not you" unless docId is userId
    return 

  # Ensure documents have a matching accountId after mutation
  if collection is 'auths'
    validators.push (mutatedDoc) ->
      return if !mutatedDoc or mutatedDoc.admin is doc.admin
      return '403: Cannot modify a document to have a different admin status'

  if collection is 'auths_public'
    return if fullPath in ['local.reset.token', 'local.reset.when', 'local.reg', 'local.reg.when', 'local.reg.token']
    return if method is 'create'
    return "403: Cannot modify auths_public"

  ## APP SPECIFIC ACCESS RULES HERE ##

  # disallow all other changes
  console.log 'access denied...', userId, method, collection, fullPath
  return "403: cannot modify #{collection}"

# Note that additional documents required to do read access control can be
# fetched from the ShareJS agent directly. It is much better to use ShareJS
# doc fetches instead of adding the overhead and potential for memory leaks
# from Racer models. Example:
checkSecret = (collection, docId, userId, cb) ->
  unless docId
    return cb '403: Cannot access document missing id reference'
  agent.fetch collection, docId, (err, doc) ->
    return cb err if err
    return cb() unless doc.data?.secretTo == userId
    cb '403: Cannot access secret document'

checkAdmin = (collection, docId, userId, cb) ->
  unless docId
    return cb '403: Cannot access document missing id reference'
  agent.fetch collection, docId, (err, doc) ->
    return cb err if err
    return cb() unless doc.data?.secretTo == userId
    cb '403: Cannot access secret document'

