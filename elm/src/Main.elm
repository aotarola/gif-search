module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)



---- MODEL ----


giphyToken : String
giphyToken =
    "Yc3lO0Z7bgW0DJWq4MtS42FGvcII6GIn"


type History
    = List String
    | NoHistory


type GifSearch
    = GifSearch String
    | NoSearch


type Model
    = Model GifSearch History


init : ( Model, Cmd Msg )
init =
    ( Model NoSearch NoHistory, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
