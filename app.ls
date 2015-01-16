require! path
require! fs
require! koa
require! marked
require! \./db
require! thunkify
kbl = require \koa-bunyan-logger
bodyParser = require \koa-bodyparser
favicon = require \koa-favicon
request = require \cc-superagent-promise

app = exports = module.exports = koa!

env = process.env.NODE_ENV || 'development'
unless env is 'development'
    app.use kbl!
    app.use kbl.requestIdContext!
    app.use kbl.requestLogger!

app.use (next) ->*
    reTailingSlash = /(.*)\/($|\?)/
    matched = @url.match(reTailingSlash)
    if matched and matched[1]
        @redirect @url.replace reTailingSlash, (all, path, tailing) ->
            path + tailing
    else
        yield next

findOneDoc = thunkify db.docs~findOne
updateDoc = thunkify db.docs~update

function getDomain (ctx)
    reTld = /(\.mian\.bz|\.m\.bz)(:\d+)?$/i
    if not (m = ctx.headers.host?.match(reTld))
        return
    return ctx.headers.host.replace(reTld, '') + '.mian.bz'

app.use favicon path.join __dirname, 'favicon.ico'
app.use(require('koa-static')(__dirname), defer: yes)
template = fs.readFileSync path.join(__dirname, 'template.html'), 'utf-8'

app.use (next) ->*
    unless @method is \GET and (domain = getDomain this)
        return yield next

    doc = yield findOneDoc { @path, domain }

    unless doc
        doc = {}
        doc.html = doc.content = ''

    @body = template.replace('{doc}', JSON.stringify(doc))

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
    doc = {} <<< oldDoc <<< {
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

#app.listen process.env.PORT || 3000
