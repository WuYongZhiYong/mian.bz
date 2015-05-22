'use strict';

global.Promise = require('bluebird');
var redis = require('redis');
var co = require('co');

Promise.promisifyAll(redis);

var db = redis.createClient();
db.select(7);
for (var k in db) console.log(k)

var data = require('fs').readFileSync(__dirname + '/legacy.data', 'utf8');
var lines = data.split('\n').filter(Boolean);
var line;
co(function *() {
    var line;
    while ((line = lines.shift())) {
        var obj = JSON.parse(line);
        console.log(obj);
        var key = 'doc|' +  obj.domain + obj.path;
        delete obj.domain;
        delete obj.path;
        var json = JSON.stringify(obj);
        yield db.setAsync(key, json);
        yield db.zaddAsync('doc|by|created_at', obj.created_at, key);
        yield db.zaddAsync('doc|by|modified_at', obj.modified_at, key);
    }
}).catch(function (err) {
    console.error(err.stack);
});
return;
function getDomain (req) {
    reTld = /(\.mian\.bz|\.m\.bz)(:\d+)?$/i;
    if ((m = (req.headers.host||'').match(reTld))) {
        return req.headers.host.replace(reTld, '') + '.mian.bz'
    }
    return;
}

app.get('/*', function (req, res, next) {
    var domain = getDomain(req);
    if (!domain) return next();
    var key = 'doc|' + domain + req.path;
});
