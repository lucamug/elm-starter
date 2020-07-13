module Starter.ConfMeta exposing
    ( Conf
    , FileNames
    , conf
    )


type alias FileNames =
    { outputCompiledJs : String
    , indexHtml : String
    , manifestJson : String
    , redirects : String
    , robotsTxt : String
    , serviceWorker : String
    , sitemap : String
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
    }


type alias Conf =
    -- ports
    { portBuild : Int
    , portStatic : Int
    , portDev : Int

    --
    , versionElmStart : String

    --
    , indentation : Int

    -- notifications
    , doNotEditDisclaimer : String
    , enableJavascriptForBetterExperience : String
    , loadingMessage : String
    , youNeedToEnableJavascript : String

    -- file names
    , fileNames : FileNames
    }


conf : Conf
conf =
    -- ports
    { portStatic = 7000
    , portDev = 8000
    , portBuild = 9000

    --
    , versionElmStart = "0.0.12"

    --
    , indentation = 0

    -- notifications
    , youNeedToEnableJavascript = "You need to enable JavaScript to run this app."
    , enableJavascriptForBetterExperience = "Enable Javascript for a better experience."
    , loadingMessage = "L O A D I N G . . ."
    , doNotEditDisclaimer = "Generated file ** DO NOT EDIT DIRECTLY ** Edit Elm files instead"

    -- file names
    , fileNames = fileNames
    }
