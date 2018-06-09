'use strict'

const { Transform } = require('stream')

const destinationFolder = process.env["DIRTY_FILEBOX_DESTINATION"] || "/tmp"


class Base64Transform extends Transform {
	constructor(options) {
		super(options);
	}
	_transform(chunk, encoding, cb) {
		cb(null, Buffer.from(chunk, 'base64'));
	}

}

const multer  = require('multer')
const storage = multer.diskStorage({
	destination: function (req, file, cb) {
		cb(null, destinationFolder)
	},
	filename: function (req, file, cb) {
		cb(null, file.originalName + '-' + Date.now())
	}
})
const upload = multer({ storage: storage });


const compression = require('compression');
const express = require('express');
const app = express();


app.use(express.static('public'), compression())

app.put('/dump'
		, require('decompress').create()
		, function(req, res, next) {
			req.pipe(new Base64Transform())
            next()
		}
		, upload.single('givenFile')
        , function (req, res, next) {
			console.log(`[+] PUT ${req.file.originalName}`);
			next();
		})



app.listen(8000)
console.log("[i] Storing incoming files in ", destinationFolder)
