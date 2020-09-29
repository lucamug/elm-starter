module Starter.SnippetHtml exposing
    ( messageEnableJavascriptForBetterExperience
    , messageLoading
    , messageLoadingOff
    , messageLoadingOn
    , messageYouNeedToEnableJavascript
    , messagesStyle
    , prettyConsoleFormatting
    , previewCards
    , pwa
    )

import Html.String exposing (..)
import Html.String.Attributes exposing (..)
import Html.String.Extra exposing (..)
import Starter.ConfMeta
import Starter.FileNames
import Starter.Flags
import Starter.SnippetCss


{-| PWA stuff
-}
pwa :
    { commit : String
    , relative : String
    , themeColor : String
    , version : String
    }
    -> List (Html msg)
pwa { relative, version, commit, themeColor } =
    -- DNS preconnect and prefetch for
    -- https://storage.googleapis.com/workbox-cdn/releases/5.1.2/workbox-sw.js
    [ link [ rel "preconnect", href "https://storage.googleapis.com", crossorigin "true" ] []
    , link [ rel "dns-prefetch", href "https://storage.googleapis.com" ] []

    -- PWA
    , meta [ name "theme-color", content themeColor ] []
    , meta [ name "mobile-web-app-capable", content "yes" ] []
    , link [ rel "manifest", href (relative ++ .manifestJson (Starter.FileNames.fileNames version commit)) ] []

    -- iOS
    , meta [ name "apple-mobile-web-app-capable", content "yes" ] []
    , meta [ name "apple-mobile-web-app-status-bar-style", content "black" ] []
    , meta [ name "apple-mobile-web-app-title", content "Test PWA" ] []
    ]


{-| Mix of Twitter and Open Graph tags to define a summary card

<https://developer.twitter.com/en/docs/tweets/optimize-with-cards/guides/getting-started>

-}
previewCards :
    { commit : String
    , flags : Starter.Flags.Flags
    , mainConf : b
    , version : String
    }
    -> List (Html msg)
previewCards args =
    --
    -- From https://medium.com/slack-developer-blog/everything-you-ever-wanted-to-know-about-unfurling-but-were-afraid-to-ask-or-how-to-make-your-e64b4bb9254
    --
    -- facebook open graph tags
    let
        relative =
            Starter.Flags.toRelative args.flags
    in
    []
        ++ [ meta [ property_ "og:type", content "website" ] []
           , meta [ property_ "og:url", content args.flags.homepage ] []
           , meta [ property_ "og:title", content args.flags.nameLong ] []
           , meta [ property_ "og:description", content args.flags.description ] []
           , meta [ property_ "og:image", content (relative ++ .snapshot (Starter.FileNames.fileNames args.version args.commit)) ] []

           -- twitter card tags additive with the og: tags
           , meta [ name "twitter:card", content "summary_large_image" ] []
           ]
        ++ (case args.flags.twitterSite of
                Just twitterSite ->
                    [ meta [ name "twitter:site", content ("@" ++ twitterSite) ] [] ]

                Nothing ->
                    []
           )
        ++ (case args.flags.twitterAuthor of
                Just twitterAuthor ->
                    [ meta [ name "twitter:site", content ("@" ++ twitterAuthor) ] [] ]

                Nothing ->
                    []
           )
        ++ [ meta [ name "twitter:domain", value args.flags.homepage ] []
           , meta [ name "twitter:title", value args.flags.nameLong ] []
           , meta [ name "twitter:description", value args.flags.description ] []
           , meta [ name "twitter:image", content (relative ++ .snapshot (Starter.FileNames.fileNames args.version args.commit)) ] []
           , meta [ name "twitter:url", value args.flags.homepage ] []

           -- , meta [ name "twitter:label1", value "Opens in Theaters" ] []
           -- , meta [ name "twitter:data1", value "December 1, 2015" ] []
           -- , meta [ name "twitter:label2", value "Or on demand" ] []
           -- , meta [ name "twitter:data2", value "at Hulu.com" ] []
           ]


prettyConsoleFormatting : String -> String -> List (Html msg)
prettyConsoleFormatting relative env =
    if env == "dev" then
        -- TODO - Add the right path here
        [ script [ src (relative ++ "/assets-dev/elm-console-debug.js") ] []
        , script [] [ textUnescaped "ElmConsoleDebug.register()" ]
        ]

    else
        []


messageYouNeedToEnableJavascript : List (Html msg)
messageYouNeedToEnableJavascript =
    [ noscript []
        [ div
            [ class Starter.ConfMeta.confMeta.tagNotification
            , style "top" "0"
            , style "height" "100vh"
            ]
            [ text Starter.ConfMeta.confMeta.messageYouNeedToEnableJavascript ]
        ]
    ]


messageEnableJavascriptForBetterExperience : List (Html msg)
messageEnableJavascriptForBetterExperience =
    [ noscript []
        [ div
            [ class Starter.ConfMeta.confMeta.tagNotification
            , style "bottom" "0"
            ]
            [ text Starter.ConfMeta.confMeta.messageEnableJavascriptForBetterExperience ]
        ]
    ]


messageLoading : List (Html msg)
messageLoading =
    [ div
        [ id Starter.ConfMeta.confMeta.tagLoader
        , class Starter.ConfMeta.confMeta.tagNotification
        , style "height" "100vh"
        , style "display" "none"
        ]
        [ text Starter.ConfMeta.confMeta.messageLoading ]
    ]


messageLoadingOn : List (Html msg)
messageLoadingOn =
    [ script []
        [ textUnescaped <|
            "document.getElementById('"
                ++ Starter.ConfMeta.confMeta.tagLoader
                ++ "').style.display = 'block';"
        ]
    ]


messageLoadingOff : List (Html msg)
messageLoadingOff =
    [ script []
        [ textUnescaped <|
            "document.getElementById('"
                ++ Starter.ConfMeta.confMeta.tagLoader
                ++ "').style.display = 'none';"
        ]
    ]


messagesStyle : List (Html msg)
messagesStyle =
    [ style_ []
        [ text <|
            Starter.SnippetCss.noJsAndLoadingNotifications
                Starter.ConfMeta.confMeta.tagNotification
        ]
    ]
