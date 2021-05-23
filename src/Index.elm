module Index exposing
    ( htmlToReinjectInBody
    , htmlToReinjectInHead
    , index
    )

import Html.String exposing (..)
import Html.String.Attributes exposing (..)
import Html.String.Extra exposing (..)
import Main
import Starter.FileNames
import Starter.Flags
import Starter.Icon
import Starter.SnippetHtml
import Starter.SnippetJavascript


index : Starter.Flags.Flags -> Html msg
index flags =
    let
        relative =
            Starter.Flags.toRelative flags

        fileNames =
            Starter.FileNames.fileNames flags.version flags.commit
    in
    html
        [ lang "en" ]
        [ head []
            ([]
                ++ [ meta [ charset "utf-8" ] []
                   , title_ [] [ text flags.nameLong ]
                   , meta [ name "author", content flags.author ] []
                   , meta [ name "description", content flags.description ] []
                   , meta [ name "viewport", content "width=device-width, initial-scale=1, shrink-to-fit=no" ] []
                   , meta [ httpEquiv "x-ua-compatible", content "ie=edge" ] []
                   , link [ rel "canonical", href flags.homepage ] []
                   , link [ rel "icon", href (Starter.Icon.iconFileName relative 64) ] []
                   , link [ rel "apple-touch-icon", href (Starter.Icon.iconFileName relative 152) ] []
                   , style_ []
                        [ text <| """
                            body 
                                { background-color: """ ++ Starter.Flags.toThemeColor flags ++ """
                                ; font-family: 'IBM Plex Sans', helvetica, sans-serif
                                ; margin: 0px;
                                }""" ]
                   ]
                ++ Starter.SnippetHtml.messagesStyle
                ++ Starter.SnippetHtml.pwa
                    { commit = flags.commit
                    , relative = relative
                    , themeColor = Starter.Flags.toThemeColor flags
                    , version = flags.version
                    }
                ++ Starter.SnippetHtml.previewCards
                    { commit = flags.commit
                    , flags = flags
                    , mainConf = Main.conf
                    , version = flags.version
                    }
            )
        , body []
            ([]
                -- Friendly message in case Javascript is disabled
                ++ (if flags.env == "dev" then
                        Starter.SnippetHtml.messageYouNeedToEnableJavascript

                    else
                        Starter.SnippetHtml.messageEnableJavascriptForBetterExperience
                   )
                -- "Loading..." message
                ++ Starter.SnippetHtml.messageLoading
                -- The DOM node that Elm will take over
                ++ [ div [ id "elm" ] [] ]
                -- Activating the "Loading..." message
                ++ Starter.SnippetHtml.messageLoadingOn
                -- Loading Elm code
                ++ [ script [ src (relative ++ fileNames.outputCompiledJsProd) ] [] ]
                -- Elm finished to load, de-activating the "Loading..." message
                ++ Starter.SnippetHtml.messageLoadingOff
                -- Loading utility for pretty console formatting
                ++ Starter.SnippetHtml.prettyConsoleFormatting relative flags.env
                -- Signature "Made with ❤ and Elm"
                ++ [ script [] [ textUnescaped Starter.SnippetJavascript.signature ] ]
                -- Initializing "window.ElmStarter"
                ++ [ script [] [ textUnescaped <| Starter.SnippetJavascript.metaInfo flags ] ]
                -- Let's start Elm!
                ++ [ Html.String.Extra.script []
                        [ Html.String.textUnescaped
                            ("""
                            var node = document.getElementById('elm');
                            window.ElmApp = Elm.Main.init(
                                { node: node
                                , flags:
                                    { starter : """
                                ++ Starter.SnippetJavascript.metaInfoData flags
                                ++ """ 
                                    , width: window.innerWidth
                                    , height: window.innerHeight
                                    , languages: window.navigator.userLanguages || window.navigator.languages || []
                                    , locationHref: location.href
                                    }
                                }
                            );"""
                                ++ Starter.SnippetJavascript.portOnUrlChange
                                ++ Starter.SnippetJavascript.portPushUrl
                                ++ Starter.SnippetJavascript.portChangeMeta
                            )
                        ]
                   ]
                -- Register the Service Worker, we are a PWA!
                ++ [ script [] [ textUnescaped (Starter.SnippetJavascript.registerServiceWorker relative) ] ]
            )
        ]


htmlToReinjectInHead : a -> List b
htmlToReinjectInHead _ =
    []


htmlToReinjectInBody : a -> List b
htmlToReinjectInBody _ =
    []
