module Starter.ConfMeta exposing
    ( ConfMeta
    , confMeta
    )

import Starter.Version


type alias ConfMeta =
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

    -- tags
    , tagLoader : String
    , tagNotification : String
    }


confMeta : ConfMeta
confMeta =
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

    -- tags
    , tagLoader = prefix ++ "notification"
    , tagNotification = prefix ++ "loader"
    }


prefix : String
prefix =
    "elm-starter-"
