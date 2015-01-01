require! koa

app = exports = module.exports = koa!

app.use ->*
    reTld = /(.*)(\.mian\.bz|\.m\.bz)(:\d+)?$/i
    if not (m = @headers.host?.match(reTld)) or @url.match(/^\/favicon\.ico/i)
        return
    domain = m[1]
    @body = domain

app.listen 3000
