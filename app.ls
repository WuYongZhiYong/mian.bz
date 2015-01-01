require! koa
require! \./db
require! thunkify

app = exports = module.exports = koa!

app.use ->*
    reTld = /(\.mian\.bz|\.m\.bz)(:\d+)?$/i
    if not (m = @headers.host?.match(reTld)) or @url.match(/^\/favicon\.ico/i)
        return
    domain = @headers.host.replace(reTld, '') + '.mian.bz'

    findOne = thunkify db.docs~findOne
    doc = yield findOne { @path, domain }

    unless doc
        return

    @body = doc.html

app.listen 3000
