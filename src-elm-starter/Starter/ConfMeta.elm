module Starter.ConfMeta exposing
    ( Conf
    , FileNames
    , conf
    )

import Starter.Version


type alias FileNames =
    { outputCompiledJs : String
    , indexHtml : String
    , manifestJson : String
    , redirects : String
    , robotsTxt : String
    , serviceWorker : String
    , sitemap : String
    , snapshot : String
    }


fileNames : FileNames
fileNames =
    { manifestJson = "/manifest.json"
    , redirects = "/_redirects"
    , robotsTxt = "/robots.txt"
    , outputCompiledJs = "/elm.js"
    , indexHtml = "/index.html"
    , serviceWorker = "/service-worker.js"
    , sitemap = "/sitemap.txt"
    , snapshot = "/snapshot.jpg"
    }


type alias Conf =
    -- ports
    { portBuild : Int
    , portStatic : Int
    , portDev : Int

    --
    , versionElmStarter : String

    --
    , indentation : Int

    -- notifications
    , messageDoNotEditDisclaimer : String
    , messageEnableJavascriptForBetterExperience : String
    , messageLoading : String
    , messageYouNeedToEnableJavascript : String

    -- file names
    , fileNames : FileNames

    -- tags
    , tagLoader : String
    , tagNotification : String
    }


conf : Conf
conf =
    -- ports
    { portStatic = 7000
    , portDev = 8000
    , portBuild = 9000

    --
    , versionElmStarter = Starter.Version.version

    --
    , indentation = 0

    -- messages
    , messageYouNeedToEnableJavascript = "You need to enable JavaScript to run this app."
    , messageEnableJavascriptForBetterExperience = "Enable Javascript for a better experience."
    , messageLoading = "L O A D I N G . . ."
    , messageDoNotEditDisclaimer = "Generated file ** DO NOT EDIT DIRECTLY ** Edit Elm files instead"

    -- file names
    , fileNames = fileNames

    -- tags
    , tagLoader = prefix ++ "notification"
    , tagNotification = prefix ++ "loader"
    }


prefix : String
prefix =
    "elm-starter-"
