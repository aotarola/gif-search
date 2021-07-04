module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)



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
    | EnteredGifTerm String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


dimensions : { bottom : number, left : number, right : number, top : number }
dimensions =
    { bottom = 0, left = 0, right = 0, top = 0 }


sideBarPadding : Attribute msg
sideBarPadding =
    paddingXY 20 20


sideBarBackground : Attr decorative msg
sideBarBackground =
    Background.color <| rgb255 33 37 41


white : Color
white =
    rgb255 255 255 255


black : Color
black =
    rgb255 0 0 0


gray : Color
gray =
    rgb255 108 117 125


ligthGray : Color
ligthGray =
    rgb255 211 211 211


view : Model -> Html Msg
view _ =
    layout [] <|
        row [ width fill, height fill ]
            [ column [ padding 10, height fill, sideBarBackground, Font.color white ]
                [ el [ Font.bold, Font.size 24, sideBarPadding ] <| text "Buscador de Gifs"
                , el
                    [ Border.widthEach
                        { dimensions
                            | top = 1
                            , bottom = 1
                        }
                    , Border.color gray
                    , sideBarPadding
                    ]
                  <|
                    text "Historial de Búsqueda"
                , el [ paddingXY 0 20, width fill ] <| viewHistory
                ]
            , column [ width fill, padding 20, height fill ]
                [ el [ width fill, paddingEach { dimensions | bottom = 30 } ] <|
                    Input.text [ Font.alignLeft ]
                        { onChange = EnteredGifTerm
                        , text = ""
                        , placeholder = Just <| Input.placeholder [] (text "Buscar Gifs")
                        , label = Input.labelAbove [ alignLeft ] (text "Buscar:")
                        }
                , el
                    [ width fill
                    , paddingXY 0 10
                    , Border.widthEach
                        { dimensions
                            | top = 1
                        }
                    , Border.color ligthGray
                    ]
                  <|
                    viewGifs
                ]
            ]


gifs : List String
gifs =
    [ "https://media0.giphy.com/media/3o7abAHdYvZdBNnGZq/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    , "https://media0.giphy.com/media/xTiTnf9SCIVk8HIvE4/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    , "https://media4.giphy.com/media/3o7527pa7qs9kCG78A/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    , "https://media3.giphy.com/media/RQSuZfuylVNAY/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    , "https://media3.giphy.com/media/Pn1gZzAY38kbm/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    , "https://media4.giphy.com/media/mCRJDo24UvJMA/giphy.gif?cid=a2e719177gdjaeyocymzar83t2ohn2f58wghec0uf010ax6r&rid=giphy.gif&ct=g"
    ]


viewGifs : Element msg
viewGifs =
    let
        wrapImage src =
            el [] <| image [] { src = src, description = "stubbed description" }
    in
    wrappedRow [] <| List.map wrapImage gifs


viewHistory : Element msg
viewHistory =
    let
        shouldUseBorder index =
            case index of
                0 ->
                    []

                _ ->
                    [ Border.widthEach { dimensions | top = 1 }
                    , Border.color ligthGray
                    ]

        viewUsedTerm index term =
            el ([ width fill, padding 15 ] ++ shouldUseBorder index) <| text term
    in
    [ "Dog", "Cat" ]
        |> List.indexedMap viewUsedTerm
        |> column
            [ width fill
            , Background.color white
            , Font.color black
            , Font.alignLeft
            , Border.rounded 10
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
