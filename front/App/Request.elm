module App.Request exposing (putFile)

import Http
    exposing
        ( Request
        , header
        , stringBody
        , expectStringResponse
        , request
        )
import Navigation exposing (Location)


putFile : Location -> String -> String -> Request ()
putFile { origin } fileName encodedBlob =
    request
        { method = "PUT"
        , headers = []

        {-
           , headers =
               [ header "content-type" "application/octet-stream"

               --            , header "transfer-encoding" "chunked"
               , header "content-encoding" "gzip"
               ]
        -}
        , url = Debug.log "REQUESTING:" <| origin ++ "/dump"
        , body = stringBody " multipart/form-data" encodedBlob
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
