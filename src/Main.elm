port module Main exposing (conf, main)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Starter.ConfMain
import Starter.Flags
import Svg
import Svg.Attributes
import Url
import Url.Parser exposing ((</>))


conf : Starter.ConfMain.Conf
conf =
    { urls = urls
    , assetsToCache = []
    }



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


internalConf : { urlLabel : String }
internalConf =
    { urlLabel = "tangram" }



-- MODEL


type alias Model =
    { route : Route, flags : Flags }



-- FLAGS


type alias Flags =
    { starter : Starter.Flags.Flags
    , width : Int
    , height : Int
    , languages : List String
    , locationHref : String
    }



-- INIT


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        route =
            locationHrefToRoute flags.locationHref
    in
    ( { route = route, flags = flags }
    , updateHtmlMeta flags.starter route
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onUrlChange (locationHrefToRoute >> UrlChanged)
        , Browser.Events.onKeyDown (Json.Decode.map KeyDown Html.Events.keyCode)
        ]



-- ROUTE


type Route
    = RouteTop
    | RouteTangram Tangram


routeList : List Route
routeList =
    RouteTop :: List.map (\tangram -> RouteTangram tangram) tangramList


urls : List String
urls =
    List.map routeToAbsolutePath routeList


routeToTangram : Route -> Tangram
routeToTangram route =
    case route of
        RouteTop ->
            Heart

        RouteTangram tangram ->
            tangram


tangramParser : Url.Parser.Parser (Tangram -> a) a
tangramParser =
    Url.Parser.custom "TANGRAM" stringToTangram


routeToAbsolutePath : Route -> String
routeToAbsolutePath route =
    "/"
        ++ (String.join "/" <|
                case route of
                    RouteTop ->
                        []

                    RouteTangram tangram ->
                        [ internalConf.urlLabel, String.toLower <| tangramToString tangram ]
           )


urlToRoute : Url.Url -> Maybe Route
urlToRoute url =
    Url.Parser.parse routeParser url


locationHrefToRoute : String -> Route
locationHrefToRoute locationHref =
    locationHref
        |> Url.fromString
        |> Maybe.andThen urlToRoute
        |> Maybe.withDefault RouteTop


routeParser : Url.Parser.Parser (Route -> b) b
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map RouteTangram (Url.Parser.s internalConf.urlLabel </> tangramParser)
        , Url.Parser.map RouteTop Url.Parser.top
        ]



-- MESSAGES


type Msg
    = LinkClicked String
    | UrlChanged Route
    | KeyDown Int



-- UPDATE


updateHtmlMeta : Starter.Flags.Flags -> Route -> Cmd msg
updateHtmlMeta starterFlags route =
    let
        title =
            "a " ++ String.toUpper (tangramToString (routeToTangram route)) ++ " from " ++ starterFlags.nameLong

        url =
            starterFlags.homepage ++ routeToAbsolutePath route

        image =
            url ++ "/snapshot.jpg"
    in
    Cmd.batch
        [ changeMeta { type_ = "property", querySelector = "title", fieldName = "innerHTML", content = title }
        , changeMeta { type_ = "attribute", querySelector = "link[rel='canonical']", fieldName = "href", content = url }
        , changeMeta { type_ = "attribute", querySelector = "meta[name='twitter:title']", fieldName = "value", content = title }
        , changeMeta { type_ = "attribute", querySelector = "meta[property='og:image']", fieldName = "content", content = image }
        , changeMeta { type_ = "attribute", querySelector = "meta[name='twitter:image']", fieldName = "content", content = image }
        , changeMeta { type_ = "attribute", querySelector = "meta[property='og:url']", fieldName = "content", content = url }
        , changeMeta { type_ = "attribute", querySelector = "meta[name='twitter:url']", fieldName = "value", content = url }
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked path ->
            ( model, pushUrl path )

        UrlChanged route ->
            ( { model | route = route }
            , updateHtmlMeta model.flags.starter route
            )

        KeyDown key ->
            if key == 37 || key == 38 then
                ( model
                , model.route
                    |> routeToTangram
                    |> previousTangram
                    |> RouteTangram
                    |> routeToAbsolutePath
                    |> pushUrl
                )

            else if key == 39 || key == 40 then
                ( model
                , model.route
                    |> routeToTangram
                    |> nextTangram
                    |> RouteTangram
                    |> routeToAbsolutePath
                    |> pushUrl
                )

            else
                ( model, Cmd.none )



-- PORTS


port onUrlChange : (String -> msg) -> Sub msg


port pushUrl : String -> Cmd msg


port changeMeta :
    { querySelector : String
    , fieldName : String
    , content : String
    , type_ : String
    }
    -> Cmd msg



-- VIEW HELPERS


linkInternal :
    (String -> msg)
    -> List (Attribute msg)
    -> { label : Element msg, url : String }
    -> Element msg
linkInternal internalLinkClicked attrs args =
    let
        -- From https://github.com/elm/browser/blob/1.0.2/notes/navigation-in-elements.md
        preventDefault : msg -> Html.Attribute msg
        preventDefault msg =
            Html.Events.preventDefaultOn "click" (Json.Decode.succeed ( msg, True ))
    in
    link
        ((htmlAttribute <| preventDefault (internalLinkClicked args.url)) :: attrs)
        args


mouseOverEffect : List (Attr () msg)
mouseOverEffect =
    [ alpha 0.8
    , mouseOver [ alpha 1 ]
    , htmlAttribute <| Html.Attributes.style "transition" "0.3s"
    ]


linkAttrs : List (Attr () msg)
linkAttrs =
    mouseOverEffect
        ++ [ htmlAttribute <| Html.Attributes.style "text-decoration" "underline" ]



-- VIEW


view : Model -> Html.Html Msg
view model =
    let
        themeColor =
            Starter.Flags.flagsToThemeColorRgb model.flags.starter
    in
    Html.div
        [ Html.Attributes.id "elm" ]
        [ Html.node "style" [] [ Html.text css ]
        , Html.a [ Html.Attributes.class "skip-link", Html.Attributes.href "#main" ]
            [ Html.text "Skip to main" ]
        , layout
            [ Background.color <|
                rgb255
                    themeColor.red
                    themeColor.green
                    themeColor.blue
            , Font.color <| rgb 0.95 0.95 0.95
            , Font.family []
            , Font.size 20
            , centerY
            , htmlAttribute <| Html.Attributes.style "height" "100vh"
            ]
          <|
            column
                [ centerX
                , centerY
                , spacing 40
                , width (fill |> maximum 400)
                ]
                [ viewTangram model.route
                , viewMessage
                ]
        ]


viewTangram : Route -> Element Msg
viewTangram route =
    row
        [ centerX
        , spacing 0
        , width fill
        ]
        [ linkInternal LinkClicked
            ([ height fill
             , width <| px 48
             ]
                ++ mouseOverEffect
            )
            { label =
                el [ centerX ] <|
                    html <|
                        left
                            { id = "previous"
                            , title = "Previous"
                            , desc = "Go to the previous Tangram"
                            , width = 32
                            }
            , url = routeToAbsolutePath <| RouteTangram <| previousTangram <| routeToTangram route
            }
        , linkInternal LinkClicked
            [ htmlAttribute <| Html.Attributes.style "animation" "elmLogoSpin infinite 2.5s ease-in-out"
            , width fill
            ]
            { label =
                html <|
                    logo (tangramToData <| routeToTangram route)
                        { id = "tangram"
                        , title = "A " ++ tangramToString (routeToTangram route) ++ " made of Tangram pieces"
                        , desc = "Rotating Tangram"
                        , width = 250
                        }
            , url = routeToAbsolutePath <| RouteTangram <| nextTangram <| routeToTangram route
            }
        , linkInternal LinkClicked
            ([ width (fillPortion 1)
             , height fill
             , width <| px 48
             ]
                ++ mouseOverEffect
            )
            { label =
                el [ centerX ] <|
                    html <|
                        right
                            { id = "next"
                            , title = "Next"
                            , desc = "Go to the next Tangram"
                            , width = 32
                            }
            , url = routeToAbsolutePath <| RouteTangram <| nextTangram <| routeToTangram route
            }
        ]


viewMessage : Element msg
viewMessage =
    column
        [ spacing 14
        , centerX
        , paddingXY 20 0
        , htmlAttribute <| Html.Attributes.style "word-spacing" "5px"
        , htmlAttribute <| Html.Attributes.style "letter-spacing" "1px"
        ]
        [ paragraph [ Font.center ]
            [ text "Bootstrapped with "
            , newTabLink [ centerX ]
                { label = el linkAttrs <| text "elm-starter"
                , url = "https://github.com/lucamug/elm-starter"
                }
            , text "."
            ]
        , paragraph [ Font.center ]
            [ text "Edit "
            , el (Font.family [ Font.monospace ] :: mouseOverEffect) <| text "src/Main.elm"
            , text " and save to reload."
            ]
        , paragraph [ Font.center ]
            [ newTabLink [ centerX ]
                { label = el linkAttrs <| text "Learn Elm"
                , url = "https://elm-lang.org/"
                }
            , text "."
            ]
        ]



-- TANGRAM


type Tangram
    = ElmLogo
    | Heart
    | Camel
    | Cat
    | Bird
    | House
    | Person


tangramList : List Tangram
tangramList =
    [ Heart
    , Camel
    , Cat
    , Bird
    , House
    , Person
    , ElmLogo
    ]


stringToTangram : String -> Maybe Tangram
stringToTangram string =
    if String.toLower string == String.toLower (tangramToString ElmLogo) then
        Just ElmLogo

    else if String.toLower string == String.toLower (tangramToString Heart) then
        Just Heart

    else if String.toLower string == String.toLower (tangramToString Camel) then
        Just Camel

    else if String.toLower string == String.toLower (tangramToString Cat) then
        Just Cat

    else if String.toLower string == String.toLower (tangramToString Bird) then
        Just Bird

    else if String.toLower string == String.toLower (tangramToString House) then
        Just House

    else if String.toLower string == String.toLower (tangramToString Person) then
        Just Person

    else
        Nothing


tangramToData : Tangram -> TangramData
tangramToData tangram =
    case tangram of
        ElmLogo ->
            { p1 = ( 0, -210, 0 )
            , p2 = ( -210, 0, -90 )
            , p3 = ( 207, 207, -45 )
            , p4 = ( 150, 0, 0 )
            , p5 = ( -89, 239, 0 )
            , p6 = ( 0, 106, -180 )
            , p7 = ( 256, -150, -270 )
            }

        Heart ->
            { p1 = ( -160, 120, 0 )
            , p2 = ( 150, -90, -180 )
            , p3 = ( -270, -93, -45 )
            , p4 = ( -5, -305, 0 )
            , p5 = ( 231, 91, 0 )
            , p6 = ( 150, 224, 0 )
            , p7 = ( -106, -150, -90 )
            }

        Camel ->
            { p1 = ( -250, -256, -315 )
            , p2 = ( 100, -260, -270 )
            , p3 = ( -190, -30, 0 )
            , p4 = ( 40, 40, 0 )
            , p5 = ( 278, 40, -90 )
            , p6 = ( 262, 276, -90 )
            , p7 = ( 366, 380, -180 )
            }

        Cat ->
            { p1 = ( -40, -120, -90 )
            , p2 = ( 20, -420, -135 )
            , p3 = ( -226, -38, -270 )
            , p4 = ( -220, 276, 0 )
            , p5 = ( 350, -462, -315 )
            , p6 = ( -320, 428, -90 )
            , p7 = ( -120, 428, -270 )
            }

        Bird ->
            { p1 = ( -296, 166, -45 )
            , p2 = ( 0, 40, -225 )
            , p3 = ( 200, 136, -270 )
            , p4 = ( -42, -212, -45 )
            , p5 = ( -138, -424, -135 )
            , p6 = ( 139, -181, -315 )
            , p7 = ( 352, 214, -225 )
            }

        House ->
            { p1 = ( 0, -250, 0 )
            , p2 = ( 96, 54, 0 )
            , p3 = ( -218, -152, -315 )
            , p4 = ( -106, 266, -45 )
            , p5 = ( -212, 56, -315 )
            , p6 = ( 162, -104, -180 )
            , p7 = ( 264, -206, -270 )
            }

        Person ->
            { p1 = ( -88, -46, -135 )
            , p2 = ( 208, 86, -315 )
            , p3 = ( 120, -300, 0 )
            , p4 = ( 104, 352, -36 )
            , p5 = ( -140, -300, -315 )
            , p6 = ( -404, -380, -315 )
            , p7 = ( 328, -434, -180 )
            }


type alias TangramData =
    { p1 : ( Int, Int, Int )
    , p2 : ( Int, Int, Int )
    , p3 : ( Int, Int, Int )
    , p4 : ( Int, Int, Int )
    , p5 : ( Int, Int, Int )
    , p6 : ( Int, Int, Int )
    , p7 : ( Int, Int, Int )
    }


nextTangram : Tangram -> Tangram
nextTangram tangram =
    case tangram of
        ElmLogo ->
            Heart

        Heart ->
            Camel

        Camel ->
            Cat

        Cat ->
            Bird

        Bird ->
            House

        House ->
            Person

        Person ->
            ElmLogo


previousTangram : Tangram -> Tangram
previousTangram tangram =
    case tangram of
        ElmLogo ->
            Person

        Heart ->
            ElmLogo

        Camel ->
            Heart

        Cat ->
            Camel

        Bird ->
            Cat

        House ->
            Bird

        Person ->
            House


tangramToString : Tangram -> String
tangramToString tangram =
    case tangram of
        ElmLogo ->
            "ElmLogo"

        Heart ->
            "Heart"

        Camel ->
            "Camel"

        Cat ->
            "Cat"

        Bird ->
            "Bird"

        House ->
            "House"

        Person ->
            "Person"



-- SVG


wrapperWithViewbox :
    String
    -> { desc : String, id : String, title : String, width : Int }
    -> List (Svg.Svg msg)
    -> Html.Html msg
wrapperWithViewbox viewbox { id, title, desc, width } listSvg =
    Svg.svg
        [ Svg.Attributes.xmlSpace "http://www.w3.org/2000/svg"
        , Svg.Attributes.preserveAspectRatio "xMinYMin slice"
        , Svg.Attributes.viewBox viewbox
        , Svg.Attributes.width <| String.fromInt width ++ "px"
        , Html.Attributes.attribute "role" "img"
        , Html.Attributes.attribute "aria-labelledby" (id ++ "Title " ++ id ++ "Desc")
        ]
        ([ Svg.title [ Svg.Attributes.id (id ++ "Title") ] [ Svg.text title ]
         , Svg.desc [ Svg.Attributes.id (id ++ "Desc") ] [ Svg.text desc ]
         ]
            ++ listSvg
        )


left : { desc : String, id : String, title : String, width : Int } -> Html.Html msg
left args =
    wrapperWithViewbox
        "0 0 31.49 31.49"
        args
        [ Svg.path [ Svg.Attributes.fill "white", Svg.Attributes.d "M10.27 5a1.11 1.11 0 011.59 0c.43.44.43 1.15 0 1.58l-8.05 8.05h26.56a1.12 1.12 0 110 2.24H3.8l8.05 8.03c.43.44.43 1.16 0 1.58-.44.45-1.14.45-1.59 0L.32 16.53a1.12 1.12 0 010-1.57l9.95-9.95z" ] [] ]


right : { desc : String, id : String, title : String, width : Int } -> Html.Html msg
right args =
    wrapperWithViewbox
        "0 0 31.49 31.49"
        args
        [ Svg.path [ Svg.Attributes.fill "white", Svg.Attributes.d "M21.2 5a1.11 1.11 0 00-1.58 0 1.12 1.12 0 000 1.58l8.04 8.04H1.11c-.62 0-1.11.5-1.11 1.12 0 .62.5 1.12 1.11 1.12h26.55l-8.04 8.04a1.14 1.14 0 000 1.58c.44.45 1.16.45 1.58 0l9.96-9.95a1.1 1.1 0 000-1.57L21.2 5.01z" ] [] ]


logo :
    TangramData
    -> { desc : String, id : String, title : String, width : Int }
    -> Html.Html msg
logo data args =
    wrapperWithViewbox
        "-600 -600 1200 1200"
        args
        [ Svg.g
            [ Svg.Attributes.transform "scale(1 -1)"
            ]
            [ poly "-280,-90 0,190 280,-90" data.p1
            , poly "-280,-90 0,190 280,-90" data.p2
            , poly "-198,-66 0,132 198,-66" data.p3
            , poly "-130,0 0,-130 130,0 0,130" data.p4
            , poly "-191,61 69,61 191,-61 -69,-61" data.p5
            , poly "-130,-44 0,86  130,-44" data.p6
            , poly "-130,-44 0,86  130,-44" data.p7
            ]
        ]


poly : String -> ( Int, Int, Int ) -> Svg.Svg msg
poly points ( translateX, translateY, rotation ) =
    Svg.polygon
        [ Svg.Attributes.fill "currentColor"
        , Svg.Attributes.points points
        , Html.Attributes.style "transition" "1s"
        , Svg.Attributes.transform
            ("translate("
                ++ String.fromInt translateX
                ++ " "
                ++ String.fromInt translateY
                ++ ") rotate("
                ++ String.fromInt rotation
                ++ ")"
            )
        ]
        []



-- CSS


css : String
css =
    """.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000000;
  color: white;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}

@keyframes elmLogoSpin {
  0%, 100% {
    transform: rotate(15deg);
  }
  50% {
    transform: rotate(-15deg);
  }
}

"""
