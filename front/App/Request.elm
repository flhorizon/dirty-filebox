module App.Request exposing (putFile, putFileJSon)

import Http
    exposing
        ( Request
        , header
        , multipartBody
        , stringPart
        , jsonBody
        , expectStringResponse
        , request
        )
import Navigation exposing (Location)
import Json.Encode as Encode


encodeFields : String -> String -> Encode.Value
encodeFields fileName encodedBlob =
    Encode.object
        [ ( "theOriginalName", Encode.string fileName )
        , ( "theContents", Encode.string encodedBlob )
        ]


putFileJSon : Location -> String -> String -> Request ()
putFileJSon { origin } fileName encodedBlob =
    request
        { method = "PUT"
        , headers =
            [-- header "Content-Encoding" "gzip"
            ]
        , url = origin ++ "/dump"
        , body =
            jsonBody <| encodeFields fileName encodedBlob
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


putFile : Location -> String -> String -> Request ()
putFile { origin } fileName encodedBlob =
    request
        { method = "PUT"
        , headers =
            [ 
                -- header "Content-Encoding" "gzip"
            ]
        , url = origin ++ "/dump-multi"
        , body =
            multipartBody
                [ stringPart "theOriginalName" fileName
                , stringPart "theContents" encodedBlob
                ]
        , expect = expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }
