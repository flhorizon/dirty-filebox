'use strict'

const express = require('express')
const compression = require('compression')

const app = express()
const router = express.Router()

app.use(compression())

app.use(express.static('../public'))
