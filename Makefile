
.PHONY: all configure build-front server

all: configure build-front server

configure:
	(cd back && npm install)

build-front:
	elm make front/Main.elm --output public/Elm.js

server:
	(cd back && npm start)
