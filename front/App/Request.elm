module App.Request exposing (putFile)

import Http
    exposing
        ( Request
        , header
        , stringBody
        , expectStringResponse
        , request
        )


putFile : String -> String -> String -> Request ()
putFile host fileName encodedBlob =
    request
        { method = "PUT"
        , headers =
            [ header "content-type" "application/octet-stream"
            , header "transfer-encoding" "chunked"
            , header "content-encoding" "gzip"
            ]
        , url = host
        , body = stringBody " multipart/form-data" encodedBlob
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
