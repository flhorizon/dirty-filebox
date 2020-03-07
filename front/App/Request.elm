module App.Request exposing (putFile, putFileJSon)

import Http
    exposing
        ( Error
        , expectString
        , header
        , jsonBody
        , multipartBody
        , request
        , stringPart
        )
import Json.Encode as Encode


encodeFields : String -> String -> Encode.Value
encodeFields fileName encodedBlob =
    Encode.object
        [ ( "theOriginalName", Encode.string fileName )
        , ( "theContents", Encode.string encodedBlob )
        ]


putFileJSon : (Result Error String -> msg) -> String -> String -> String -> Cmd msg
putFileJSon toMsg origin fileName encodedBlob =
    request
        { method = "PUT"
        , headers =
            [-- header "Content-Encoding" "gzip"
            ]
        , url = origin ++ "/dump"
        , body =
            jsonBody <| encodeFields fileName encodedBlob
        , expect = expectString toMsg
        , timeout = Nothing
        , tracker = Nothing
        }


putFile : (Result Error String -> msg) -> String -> String -> String -> Cmd msg
putFile toMsg origin fileName encodedBlob =
    request
        { method = "PUT"
        , headers =
            [-- header "Content-Encoding" "gzip"
            ]
        , url = origin ++ "/dump-multi"
        , body =
            multipartBody
                [ stringPart "theOriginalName" fileName
                , stringPart "theContents" encodedBlob
                ]
        , expect = expectString toMsg
        , timeout = Nothing
        , tracker = Nothing
        }
