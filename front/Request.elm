module Request exposing (postFile)

import Http
    exposing
        ( Request(..)
        , header
        , stringPart
        )


postFile : String -> String -> Request
postFile fileName encodedBlobs =
    request
        { method = "POST"
        , headers =
            [ header "content-type" "application/octet-stream"
            , header "transfer-encoding" "chunked"
            , header "content-encoding" "gzip"
            ]
        , url = url
        , body = stringBody encodedBlob
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
