'use strict';

var http = require('https');
var https = require('https')
  , port = process.argv[3] || 80 // 2 will be --harmony
  , sport = process.argv[4] || 443
  , fs = require('fs')
  , path = require('path')
  , options
  ;

var app = require('./');

require('ssl-root-cas')
  .inject()
  .addFile(path.join(__dirname, 'certs', 'server', 'mianbz-root-ca.crt.pem'))
  ;

options = {
  key: fs.readFileSync(path.join(__dirname, 'certs', 'server', 'mianbz-server.key.pem'))
// You don't need to specify `ca`, it's done by `ssl-root-cas`
//, ca: [ fs.readFileSync(path.join(__dirname, 'certs', 'server', 'my-root-ca.crt.pem'))]
, cert: fs.readFileSync(path.join(__dirname, 'certs', 'server', 'mianbz-server.crt.pem'))
};

var sserver = https.createServer(options, app.callback()).listen(sport, function () {
  port = sserver.address().port;
  console.log('Listening on https://127.0.0.1:' + port);
});

var server = http.createServer(app.callback()).listen(port, function () {
  port = server.address().port;
  console.log('Listening on http://127.0.0.1:' + port);
});
