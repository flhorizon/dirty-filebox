-- Main.elm


module Main exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (src, title, class, id, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import App.Ports exposing (FilePortData, fileSelected, fileContentRead)
import App.Request as Request
import Navigation exposing (Location)


type Msg
    = FileSelected
    | FileEncoded FilePortData
    | NoUrlChange
    | PostFileResult (Result Http.Error ())


type Submission
    = None
    | Uploading ()
    | Failure ()
    | Encoding


type alias Image =
    { contents : String
    , filename : String
    }


type alias Model =
    { id : String
    , submission : Submission
    , location : Location
    }


main : Program Never Model Msg
main =
    Navigation.program (always NoUrlChange)
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Location -> ( Model, Cmd Msg )
init location =
    ( { id = "FileInputId"
      , submission = None
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
                ( { model | submission = Encoding }
                , fileSelected model.id
                )

            FileEncoded data ->
                let
                    _ =
                        Debug.log "ENCODED!"
                            { contents = data.contents
                            , filename = data.filename
                            }
                in
                    ( { model | submission = Uploading () }
                    , Http.send PostFileResult <|
                        Request.putFile model.location data.filename data.contents
                    )

            NoUrlChange ->
                noop

            PostFileResult res ->
                let
                    _ =
                        Debug.log "RESULT:" res
                in
                    noop


view : Model -> Html Msg
view model =
    let
        viewInput =
            input
                [ type_ "file"
                , id model.id
                , on "change"
                    (Decode.succeed FileSelected)
                ]
                []
    in
        div [ class "imageWrapper" ]
            [ case model.submission of
                Encoding ->
                    text "Encoding..."

                None ->
                    viewInput

                _ ->
                    text "Uploading..."
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileEncoded
