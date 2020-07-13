module Starter.SnippetJavascript exposing (..)

import Json.Encode


selfInvoking : String -> String
selfInvoking code =
    "( function () {\"use strict\";\n" ++ code ++ "\n})();"


metaInfo :
    { gitBranch : String
    , gitCommit : String
    , versionElmStart : String
    , env : String
    , version : String
    }
    -> String
metaInfo args =
    let
        metaInfoData =
            Json.Encode.encode 4 <|
                Json.Encode.object
                    [ ( "commit", Json.Encode.string args.gitCommit )
                    , ( "branch", Json.Encode.string args.gitBranch )
                    , ( "env", Json.Encode.string args.env )
                    , ( "version", Json.Encode.string args.version )
                    , ( "versionElmStart", Json.Encode.string args.versionElmStart )
                    ]
    in
    "window.ElmStarter = " ++ metaInfoData ++ ";"


signature : String
signature =
    """
var color =
    { default: "background: #eee; color: gray; font-family: monospace"
    , love: "background: red; color: #eee"
    , elm: "background: #77d7ef; color: #00479a"
    };
var emptyLine = " ".repeat(49);
var message = 
    [ ""
    , "%c"
    , emptyLine
    , "    m a d e   w i t h   %c ❤ %c   a n d   %c e l m %c    "
    , emptyLine
    , ""
    , ""
    ].join("\\n");
console.info
    ( message
    , color.default
    , color.love
    , color.default
    , color.elm
    , color.default
    );"""


registerServiceWorker : String
registerServiceWorker =
    """
// From https://developers.google.com/web/tools/workbox/guides/get-started
if (location.hostname === "localhost") {
    console.log("NOT loading the service worker in development");
} else {
    if ('serviceWorker' in navigator) {
        // Use the window load event to keep the page load performant
        window.addEventListener('load', function() {
            navigator.serviceWorker.register('/service-worker.js').then(function(registration) {
                // Registration was successful
            }, function(err) {
                // registration failed :(
            });
        });
    }    
}"""


{-| Changing "You need js..." to "Better to use js..." because
the app is working also wihtout js in production when
these pages are generated with Puppeteer
-}
appWorkAlsoWithoutJS :
    { a
        | enableJavascriptForBetterExperience : String
        , youNeedToEnableJavascript : String
    }
    -> String
appWorkAlsoWithoutJS args =
    """       
var noscriptElement = document.querySelector('noscript');
if (noscriptElement) {
    noscriptElement.innerHTML = noscriptElement.innerHTML.replace
        ( \"""" ++ args.youNeedToEnableJavascript ++ """"
        , \"""" ++ args.enableJavascriptForBetterExperience ++ """"
        );
} """


type ElmStarter
    = ElmStarterStandard
    | ElmStarterCustomized String


elmStarterToString : ElmStarter -> String
elmStarterToString elmStarter =
    case elmStarter of
        ElmStarterStandard ->
            String.join "\n"
                [ "var node = document.getElementById('elm');"
                , "var app = node ? Elm.Main.init( { node: node } ) : Elm.Main.init();"
                ]

        ElmStarterCustomized string ->
            string


portOnUrlChange : String
portOnUrlChange =
    """
// From https://github.com/elm/browser/blob/1.0.2/notes/navigation-in-elements.md
// Inform app of browser navigation (the BACK and FORWARD buttons)
if (ElmApp && ElmApp.ports && ElmApp.ports.onUrlChange) {
    window.addEventListener('popstate', function () {
        ElmApp.ports.onUrlChange.send(location.href);
    });
} """


portPushUrl : String
portPushUrl =
    """
// From https://github.com/elm/browser/blob/1.0.2/notes/navigation-in-elements.md
// Change the URL upon request, inform app of the change.
if (ElmApp && ElmApp.ports && ElmApp.ports.pushUrl) {
    ElmApp.ports.pushUrl.subscribe(function(url) {
        history.pushState({}, '', url);
        if (ElmApp && ElmApp.ports && ElmApp.ports.onUrlChange) {
            ElmApp.ports.onUrlChange.send(location.href);
        }
    });
} """


portChangeMeta : String
portChangeMeta =
    """
if (ElmApp && ElmApp.ports && ElmApp.ports.changeMeta) {
    ElmApp.ports.changeMeta.subscribe(function(args) {
        var element = document.querySelector(args.querySelector);
        if (element) {
            element[args.fieldName] = args.content;
        }
    });
} """
