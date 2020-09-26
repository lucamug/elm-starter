module Starter.SnippetJavascript exposing
    ( appWorkAlsoWithoutJS
    , metaInfo
    , metaInfoData
    , portChangeMeta
    , portOnUrlChange
    , portPushUrl
    , registerServiceWorker
    , selfInvoking
    , signature
    )

import Json.Encode
import Starter.Flags


selfInvoking : String -> String
selfInvoking code =
    "( function () {\"use strict\";\n" ++ code ++ "\n})();"


metaInfo : Starter.Flags.Flags -> String
metaInfo flags =
    "window.ElmStarter = " ++ metaInfoData flags ++ ";"


metaInfoData : Starter.Flags.Flags -> String
metaInfoData flags =
    Json.Encode.encode 4 <|
        Starter.Flags.encoder flags


signature : String
signature =
    selfInvoking <| """
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


registerServiceWorker : String -> String
registerServiceWorker relative =
    selfInvoking <| """
// From https://developers.google.com/web/tools/workbox/guides/get-started
if (location.hostname === "localhost") {
    console.log("NOT loading the service worker in development");
} else {
    if ('serviceWorker' in navigator) {
        // Use the window load event to keep the page load performant
        window.addEventListener('load', function() {
            navigator.serviceWorker.register('""" ++ relative ++ """/service-worker.js').then(function(registration) {
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
        | messageEnableJavascriptForBetterExperience : String
        , messageYouNeedToEnableJavascript : String
    }
    -> String
appWorkAlsoWithoutJS args =
    """       
var noscriptElement = document.querySelector('noscript');
if (noscriptElement) {
    noscriptElement.innerHTML = noscriptElement.innerHTML.replace
        ( \"""" ++ args.messageYouNeedToEnableJavascript ++ """"
        , \"""" ++ args.messageEnableJavascriptForBetterExperience ++ """"
        );
} """


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
        window.scrollTo(0, 0);
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
        if (args.querySelector !== "") {
            var element = document.querySelector(args.querySelector);
            if (element) {
                if (args.type_ == "attribute") {
                    element.setAttribute(args.fieldName, args.content);
                } else if (args.type_ == "property" && element[args.fieldName]) {
                    element[args.fieldName] = args.content;
                }
            }
        }
    });
} """
