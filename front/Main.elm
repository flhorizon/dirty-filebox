-- Main.elm


module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (src, title, class, id, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import Ports exposing (FilePortData, fileSelected, fileContentRead)


type Msg
    = FileSelected
    | FileEncoded FilePortData


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
    }


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { id = "ImageInputId"
      , submission = None
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected ->
            ( { model | submission = Encoding }
            , fileSelected model.id
            )

        FileEncoded data ->
            let
                newImage =
                    { contents = data.contents
                    , filename = data.filename
                    }
            in
                ( { model | submission = Uploading () }
                , Cmd.none
                )


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
