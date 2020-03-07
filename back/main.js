'use strict'

// JS is a steaming pile of intricate untyped dung

const destinationFolder = process.env["DIRTY_FILEBOX_DESTINATION"] || "/tmp"

const compression = require('compression')
const express = require('express')
const app = express()

const fs = require('fs')
const path = require('path')
const multiparty = require('multiparty')

app.use(require("morgan")("tiny"))
app.use(express.static('public'), compression())

app.put('/dump-multi'
    , function (httpRequest, httpResponse, next) {

        const form = new multiparty.Form()
        const customFields = { theOriginalName: '', nameStream: null }
        const file = {
            realname: null
            , tmp: path.join(destinationFolder, "file-" + Date.now())
            , ostream: null
        }

        file.ostream = fs.createWriteStream(
            file.tmp
            , { flags: "w", encoding: "base64" }
        )
        file.ostream.on('error', (err) => {
            console.log("Stream error:", err)
            if (err) throw err;
        })


        form.on("part", (part) => {
            // Assuming a base64 file in a text field.
            const { name } = part
            if (name === "theOriginalName") {
                customFields.nameStream = part
                customFields.nameStream.on('data', (chunk) => {
                    customFields.theOriginalName += chunk
                })
                customFields.nameStream.on('end', () => {
                    file.realname = path.join(destinationFolder, customFields.theOriginalName)
                })

            } else if (name === "theContents") {
                part.setEncoding('ascii').pipe(file.ostream)
                part.on('end', () => file.ostream.end())
            } else {
                console.log("No clue !", name)
                part.resume()
            }
        })


        form.on("error", function (err) {
            console.log(err)
            if (err) throw err;
        })

        form.on('close', function () {
            console.log('(multipart done)')

            file.ostream.on('finish', () => {

                console.log('Upload completed!')

                fs.rename(file.tmp, file.realname, (err) => {

                    if (err) throw err;
                    httpResponse.sendStatus(200)
                });
            })

        })

        form.parse(httpRequest)
    })

app.post('/dump'
    , function (req, res, next) {
        const form = new multiparty.Form()
        const files = []
        const renameFiles = (files) => {
            files.forEach(({ src, dest }) => {
                fs.renameSync(src, dest)
            })
            console.log('Done.')
            res.sendStatus(200)
        }


        form.on('file', (name, file) => {
            files.push({
                dest: path.join(destinationFolder, file.originalFilename)
                , src: file.path
            })
        })
        form.on('close', () => {
            renameFiles(files)
        })
        form.on('error', (err) => {
            console.log(err)
        })
        form.parse(req)
    })


app.listen(8000)
console.log("[i] Storing incoming files in ", destinationFolder)
