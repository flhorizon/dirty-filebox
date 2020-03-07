-- Main.elm


module Main exposing (..)

import App.Ports exposing (FilePortData, fileContentRead, fileSelected)
import App.Request as Request
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode


type Msg
    = FileSelected
    | FileEncoded FilePortData
    | NoUrlChange
    | SubmitFileResult (Result Http.Error ())
    | Transition Control


type Control
    = None
    | Uploading ()
    | Failure ()
    | Success
    | Encoding


type alias FileBundle =
    { contents : String
    , filename : String
    }


type alias Url =
    String


type alias Model =
    { id : String
    , control : Control
    , location : Url
    }


main =
    Browser.document
        { init = init
        , update = update
        , view = view >> List.singleton >> Document "dirty-filebox"
        , subscriptions = subscriptions
        }


init : Url -> ( Model, Cmd Msg )
init location =
    ( { id = "FileInputId"
      , control = None
      , location = location
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        noop =
            ( model, Cmd.none )
    in
    case msg of
        FileSelected ->
            ( { model | control = Encoding }
            , fileSelected model.id
            )

        FileEncoded data ->
            ( { model | control = Uploading () }
            , Request.putFile
                (Result.map (always ()) >> SubmitFileResult)
                model.location
                data.filename
                data.contents
            )

        NoUrlChange ->
            noop

        SubmitFileResult res ->
            let
                _ =
                    Debug.log "RESULT:" res
            in
            ( { model | control = Success }, Cmd.none )

        Transition t ->
            ( { model | control = t }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        viewInput =
            div []
                [ input
                    [ type_ "file"
                    , id model.id
                    , on "change"
                        (Decode.succeed FileSelected)
                    ]
                    []
                ]

        viewStatus status hasTransition =
            div [] <|
                p [] [ text status ]
                    :: (case hasTransition of
                            Just msg ->
                                [ button [ onClick msg ] [ text "Retry?" ] ]

                            _ ->
                                []
                       )
    in
    div [ class "imageWrapper" ]
        [ case model.control of
            Encoding ->
                viewStatus "Encoding..." Nothing

            None ->
                viewInput

            Uploading _ ->
                viewStatus "Uploading..." Nothing

            Failure _ ->
                viewStatus "Failure!" (Just (Transition None))

            Success ->
                viewStatus "Upload successful." (Just (Transition None))
        , div []
            [ Html.form [ action "/dump", method "post", enctype "multipart/form-data" ]
                [ label [ for "myFile" ] [ text "Alternate method" ]
                , input [ type_ "file", name "myFile" ] []
                , button [ type_ "submit" ] [ text "GO" ]
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileEncoded
