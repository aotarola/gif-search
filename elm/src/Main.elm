module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events exposing (on)
import Http
import Json.Decode as Decode exposing (Decoder)


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )
        )



---- MODEL ----


giphyToken : String
giphyToken =
    -- Token for dev purposes
    "Yc3lO0Z7bgW0DJWq4MtS42FGvcII6GIn"


type alias Gif =
    { src : String
    , description : String
    }


gifDecoder : Decoder Gif
gifDecoder =
    Decode.map2 Gif Decode.string (Decode.succeed "foobar")


responseDecoder : Decoder (List Gif)
responseDecoder =
    gifDecoder
        |> Decode.at [ "images", "downsized", "url" ]
        |> Decode.list
        |> Decode.at [ "data" ]


fetchGifs : String -> Cmd Msg
fetchGifs term =
    Http.get
        { url = "https://api.giphy.com/v1/gifs/search?limit=4&" ++ "api_key=" ++ giphyToken ++ "&q=" ++ term
        , expect = Http.expectJson GotGifs responseDecoder
        }


shouldFetchGifs : GifSearch -> Cmd Msg
shouldFetchGifs gifSearch =
    case gifSearch of
        GifSearch term ->
            fetchGifs term

        NoSearch ->
            Cmd.none


type GifSearch
    = GifSearch String
    | NoSearch


type Model
    = Model GifSearch (List Gif) (List String)


init : ( Model, Cmd Msg )
init =
    ( Model NoSearch [] [], fetchGifs "cat" )



---- UPDATE ----


type Msg
    = EnteredGifTerm String
    | GotGifs (Result Http.Error (List Gif))
    | ClickedHistory String
    | PressedEnterKey


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model gifSearch gifs history) =
    let
        model =
            Model gifSearch gifs history
    in
    case msg of
        EnteredGifTerm term ->
            ( Model (GifSearch term) gifs history, Cmd.none )

        PressedEnterKey ->
            ( model, shouldFetchGifs gifSearch )

        ClickedHistory term ->
            ( model, fetchGifs term )

        GotGifs (Ok newGifs) ->
            let
                updatedHistory =
                    case gifSearch of
                        GifSearch term ->
                            history
                                |> List.filter ((/=) term)
                                |> (++) [ term ]

                        NoSearch ->
                            history
            in
            ( Model gifSearch newGifs updatedHistory, Cmd.none )

        GotGifs (Err _) ->
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


hoverColor : Color
hoverColor =
    rgb255 248 249 250


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
view model =
    let
        currentText =
            case model of
                Model NoSearch _ _ ->
                    ""

                Model (GifSearch term) _ _ ->
                    term

        gifContent =
            case model of
                Model _ gifs _ ->
                    viewGifs gifs
    in
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
                , el [ paddingXY 0 20, width fill ] <| viewHistory model
                ]
            , column [ width fill, padding 20, height fill ]
                [ el [ width fill, paddingEach { dimensions | bottom = 30 } ] <|
                    Input.text [ Font.alignLeft, onEnter PressedEnterKey ]
                        { onChange = EnteredGifTerm
                        , text = currentText
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
                    gifContent
                ]
            ]


viewGifs : List Gif -> Element msg
viewGifs gifs =
    let
        wrapImage { src } =
            el [] <| image [] { src = src, description = "stubbed description" }
    in
    wrappedRow [] <| List.map wrapImage gifs


viewHistory : Model -> Element Msg
viewHistory (Model _ _ history) =
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
            el
                ([ width fill
                 , padding 15
                 , pointer
                 , onClick <|
                    ClickedHistory term
                 ]
                    ++ shouldUseBorder index
                )
            <|
                text term
    in
    history
        |> List.indexedMap viewUsedTerm
        |> column
            [ width fill
            , Background.color white
            , mouseOver [ Background.color hoverColor ]
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
