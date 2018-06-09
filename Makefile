
.PHONY: all build-front server

all: build-front server

build-front:
	elm make front/Main.elm --warn --output public/Elm.js

server:
	(cd back && npm start)
