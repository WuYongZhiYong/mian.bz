require! path
require! koa
require! marked
require! \./db
require! thunkify
L = require \lodash-node
bodyParser = require \koa-bodyparser
favicon = require \koa-favicon
request = require \cc-superagent-promise

app = exports = module.exports = koa!

findOneDoc = thunkify db.docs~findOne
updateDoc = thunkify db.docs~update

function getDomain (ctx)
    reTld = /(\.mian\.bz|\.m\.bz)(:\d+)?$/i
    if not (m = ctx.headers.host?.match(reTld))
        return
    return ctx.headers.host.replace(reTld, '') + '.mian.bz'

app.use favicon path.join __dirname, 'favicon.ico'
app.use(require('koa-static')(__dirname), defer: yes)

app.use (next) ->*
    unless @method is \GET and (domain = getDomain this)
        return yield next

    doc = yield findOneDoc { @path, domain }

    unless doc
        return

    @body = '<script src="/node_modules/superagent/superagent.js"></script>'
    @body += doc.html

app.use bodyParser!
app.use (next) ->*
    unless @method is \PUT and (domain = getDomain this) and
            @request.body?content?
        return yield next

    modified_at = Date.now!
    queryObj = { @path, domain }
    oldDoc = yield findOneDoc queryObj
    if oldDoc
        created_at = oldDoc.created_at
        queryObj._id = oldDoc._id
    else
        created_at = modified_at
    html = marked @request.body.content
    html.replace /<h1[^>]+>([^\n]+)<\/h1>/i, (all, title) ->
        title = title
    title ||= @path
    doc = L.assign {}, oldDoc, {
        @path
        domain
        title,
        content: @request.body.content,
        html,
        created_at,
        modified_at,
    }
    [updatedCount, doc] = yield updateDoc queryObj, doc, { upsert: yes }
    @body = { doc, success: yes }

app.listen 3000
