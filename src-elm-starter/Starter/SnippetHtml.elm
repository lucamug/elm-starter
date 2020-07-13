module Starter.SnippetHtml exposing (..)

import Html.String exposing (..)
import Html.String.Attributes exposing (..)
import Html.String.Extra exposing (..)
import Main
import Starter.ConfMeta


extraHtml : List String -> List (Html msg)
extraHtml _ =
    []


{-| PWA stuff
-}
pwa : List (Html msg)
pwa =
    -- DNS preconnect and prefetch for
    -- https://storage.googleapis.com/workbox-cdn/releases/5.1.2/workbox-sw.js
    [ link [ rel "preconnect", href "https://storage.googleapis.com", crossorigin "true" ] []
    , link [ rel "dns-prefetch", href "https://storage.googleapis.com" ] []

    -- PWA
    , meta [ name "theme-color", content Main.conf.themeColor ] []
    , meta [ name "mobile-web-app-capable", content "yes" ] []
    , link [ rel "manifest", href Starter.ConfMeta.conf.fileNames.manifestJson ] []

    -- iOS
    , meta [ name "apple-mobile-web-app-capable", content "yes" ] []
    , meta [ name "apple-mobile-web-app-status-bar-style", content "black" ] []
    , meta [ name "apple-mobile-web-app-title", content "Test PWA" ] []
    ]


{-| Mix of Twitter and Open Graph tags to define a summary card

<https://developer.twitter.com/en/docs/tweets/optimize-with-cards/guides/getting-started>

-}
twitterCard : List (Html msg)
twitterCard =
    [ meta [ name "twitter:card", content "summary" ] []
    , meta [ name "twitter:site", content ("@" ++ Main.conf.twitterSite) ] []
    , meta [ name "twitter:creator", content ("@" ++ Main.conf.twitterHandle) ] []
    , meta [ property_ "og:url", content "" ] []
    , meta [ property_ "og:title", content Main.conf.title ] []
    , meta [ property_ "og:description", content Main.conf.description ] []
    , meta [ property_ "og:image", content "/snapshot.jpg" ] []
    ]
