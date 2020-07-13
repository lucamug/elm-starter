module Index exposing (index)

import Html.String exposing (..)
import Html.String.Attributes exposing (..)
import Html.String.Extra exposing (..)
import Main
import Starter.ConfMeta
import Starter.Flags
import Starter.Icon
import Starter.SnippetCss
import Starter.SnippetHtml
import Starter.SnippetJavascript


index : Starter.Flags.Flags -> Html msg
index flags =
    html
        [ lang "en" ]
        [ head []
            ([]
                ++ [ title_ [] [ text Main.conf.title ]
                   , meta [ charset "utf-8" ] []
                   , meta [ name "author", content Main.conf.author ] []
                   , meta [ name "description", content Main.conf.description ] []
                   , meta [ name "viewport", content "width=device-width, initial-scale=1, shrink-to-fit=no" ] []
                   , meta [ httpEquiv "x-ua-compatible", content "ie=edge" ] []
                   , link [ rel "icon", href (Starter.Icon.iconFileName 64) ] []
                   , link [ rel "apple-touch-icon", href (Starter.Icon.iconFileName 152) ] []
                   , style_ []
                        [ text <| """
                            body 
                                { background-color: """ ++ Main.conf.themeColor ++ """
                                ; font-family: 'IBM Plex Sans', helvetica, sans-serif
                                ; margin: 0px;
                                }""" ]
                   , style_ []
                        [ text <|
                            Starter.SnippetCss.noJsAndLoadingNotifications
                                tag.notification
                        ]
                   ]
                ++ Starter.SnippetHtml.pwa
                ++ Starter.SnippetHtml.twitterCard
            )
        , body []
            ([]
                ++ [ noscript []
                        [ div
                            [ class tag.notification ]
                            [ text Starter.ConfMeta.conf.youNeedToEnableJavascript ]
                        ]
                   , div
                        [ id tag.loader
                        , class tag.notification
                        , style "display" "none"
                        ]
                        [ text "L O A D I N G . . ." ]
                   , div [ id "elm" ] []
                   , script []
                        [ textUnescaped <|
                            "document.getElementById('"
                                ++ tag.loader
                                ++ "').style.display = 'block';"
                        ]
                   , script [ src "/elm.js" ] []
                   , script []
                        [ textUnescaped <|
                            "document.getElementById('"
                                ++ tag.loader
                                ++ "').style.display = 'none';"
                        ]
                   ]
                ++ (if flags.env == "dev" then
                        [ script [ src "/assets-dev/elm-console-debug.js" ] []
                        , script [] [ textUnescaped "ElmConsoleDebug.register()" ]
                        ]

                    else
                        []
                   )
                ++ List.map
                    (\jsSnippet ->
                        script []
                            [ textUnescaped <| Starter.SnippetJavascript.selfInvoking jsSnippet ]
                    )
                    [ Starter.SnippetJavascript.signature
                    , Starter.SnippetJavascript.metaInfo
                        { gitBranch = flags.gitBranch
                        , gitCommit = flags.gitCommit
                        , env = flags.env
                        , version = flags.version
                        , versionElmStart = Starter.ConfMeta.conf.versionElmStart
                        }
                    , Starter.SnippetJavascript.appWorkAlsoWithoutJS Starter.ConfMeta.conf
                    , Main.conf.javascriptThatStartsElm
                    , Starter.SnippetJavascript.registerServiceWorker
                    ]
            )
        ]


prefix : String
prefix =
    "elm-starter-"


tag : { loader : String, notification : String }
tag =
    { notification = prefix ++ "notification"
    , loader = prefix ++ "loader"
    }
