'use strict';

global.Promise = require('bluebird');
var fs = require('fs');
var path = require('path');
var co = require('co');
var redis = require('redis');
var express = require('express');

Promise.promisifyAll(redis);

var db = redis.createClient();
db.select(7);
var app = express();

var template = {};
if (app.get('env') === 'development') {
    Object.defineProperty(template, 'main', {
        get: function () {
            return fs.readFileSync(path.join(__dirname, 'template.html'), 'utf-8');
        }
    });
} else {
    template.main = fs.readFileSync(path.join(__dirname, 'template.html'), 'utf-8');
}



function getDomain (req) {
    var reTld = /(\.mian\.bz|\.m\.bz)(:\d+)?$/i;
    var m;
    if ((m = (req.headers.host||'').match(reTld))) {
        return req.headers.host.replace(reTld, '') + '.mian.bz'
    }
    return;
}

function conext(g) {
    return function (req, res, next) {
        co.wrap(g)(req, res, next).catch(next);
    }
}

app.use('/__', express.static(__dirname));

app.get('/*', conext(function *(req, res, next) {
    var domain = getDomain(req);
    if (!domain) return next();
    var key = 'doc|' + domain + req.path;
    console.log(key);
    var doc = yield db.getAsync(key);
    console.log(doc);
    res.send(template.main.replace('{doc}', doc));
}));

app.listen(9000)
