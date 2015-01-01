mongo = require \mongoskin
db = exports = module.exports =
    mongo.db("mongodb://localhost:27017/mianbz", {native_parser:true});

db.bind \docs
