module Starter.Flags exposing
    ( Dir
    , Env(..)
    , File
    , Flags
    , dir
    , dirEncoder
    , file
    , fileEncoder
    , flagsEncoder
    , flagsToThemeColor
    )

import Json.Encode


type Env
    = Dev
    | Prod


type alias Color =
    { red : String, green : String, blue : String }



-- FLAGS


type alias Flags =
    -- From package.jspn
    { name : String
    , nameLong : String
    , description : String
    , author : String
    , version : String
    , homepage : String
    , license : String
    , twitterSite : Maybe String
    , twitterAuthor : Maybe String
    , snapshotWidth : Maybe String
    , snapshotHeight : Maybe String
    , themeColor : Maybe Color

    -- From Git
    , commit : String
    , branch : String

    -- From starter.js
    , env : String
    , dirPw : String
    , dirBin : String
    , dirIgnoredByGit : String
    , dirTemp : String
    , fileElmWorker : String
    }


maybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
maybe encoder =
    Maybe.map encoder >> Maybe.withDefault Json.Encode.null


colorEncoder : Color -> Json.Encode.Value
colorEncoder color =
    Json.Encode.object
        [ ( "red", Json.Encode.string color.red )
        , ( "green", Json.Encode.string color.green )
        , ( "blue", Json.Encode.string color.blue )
        ]


flagsEncoder : Flags -> Json.Encode.Value
flagsEncoder flags =
    Json.Encode.object
        -- From package.json
        [ ( "name", Json.Encode.string flags.name )
        , ( "nameLong", Json.Encode.string flags.nameLong )
        , ( "description", Json.Encode.string flags.description )
        , ( "author", Json.Encode.string flags.author )
        , ( "version", Json.Encode.string flags.version )
        , ( "homepage", Json.Encode.string flags.homepage )
        , ( "license", Json.Encode.string flags.license )
        , ( "twitterSite", maybe Json.Encode.string flags.twitterSite )
        , ( "twitterAuthor", maybe Json.Encode.string flags.twitterAuthor )
        , ( "snapshotWidth", maybe Json.Encode.string flags.snapshotWidth )
        , ( "snapshotHeight", maybe Json.Encode.string flags.snapshotHeight )
        , ( "themeColor", maybe colorEncoder flags.themeColor )

        -- Git
        , ( "commit", Json.Encode.string flags.commit )
        , ( "branch", Json.Encode.string flags.branch )

        -- From starter.js
        , ( "env", Json.Encode.string flags.env )
        , ( "dirPw", Json.Encode.string flags.dirPw )
        , ( "dirBin", Json.Encode.string flags.dirBin )
        , ( "dirIgnoredByGit", Json.Encode.string flags.dirIgnoredByGit )
        , ( "dirTemp", Json.Encode.string flags.dirTemp )
        , ( "fileElmWorker", Json.Encode.string flags.fileElmWorker )
        ]


flagsToThemeColorRgb : Flags -> { blue : Int, green : Int, red : Int }
flagsToThemeColorRgb flags =
    case flags.themeColor of
        Just color ->
            { red = Maybe.withDefault 255 <| String.toInt color.red
            , green = Maybe.withDefault 255 <| String.toInt color.green
            , blue = Maybe.withDefault 255 <| String.toInt color.blue
            }

        Nothing ->
            { red = 255, green = 255, blue = 255 }


flagsToThemeColor : Flags -> String
flagsToThemeColor flags =
    let
        color =
            flagsToThemeColorRgb flags
    in
    "rgb(" ++ String.join "," (List.map String.fromInt [ color.red, color.green, color.blue ]) ++ ")"



-- DIR


type alias Dir =
    { bin : String
    , build : String
    , dev : String
    , devAssets : String
    , ignoredByGit : String
    , pw : String
    , src : String
    , temp : String
    , assets : String
    , assetsDev : String
    , elmStartSrc : String
    }


dir : Flags -> Dir
dir flags =
    { pw = flags.dirPw
    , bin = flags.dirBin
    , temp = flags.dirTemp
    , src = flags.dirPw ++ "/src"
    , elmStartSrc = flags.dirPw ++ "/src-elm-starter"

    -- Assets
    , assets = flags.dirPw ++ "/assets/prod"
    , assetsDev = flags.dirPw ++ "/assets/dev"

    -- Working dir
    , ignoredByGit = flags.dirIgnoredByGit
    , dev = flags.dirIgnoredByGit ++ "/dev"
    , devAssets = flags.dirIgnoredByGit ++ "/dev/assets-dev"
    , build = flags.dirIgnoredByGit ++ "/build"
    }


dirEncoder : Dir -> Json.Encode.Value
dirEncoder dir_ =
    Json.Encode.object
        [ ( "pw", Json.Encode.string dir_.pw )
        , ( "bin", Json.Encode.string dir_.bin )
        , ( "temp", Json.Encode.string dir_.temp )
        , ( "src", Json.Encode.string dir_.src )
        , ( "elmStartSrc", Json.Encode.string dir_.elmStartSrc )

        -- Assets
        , ( "assets", Json.Encode.string dir_.assets )
        , ( "assetsDev", Json.Encode.string dir_.assetsDev )

        -- Working dir
        , ( "ignoredByGit", Json.Encode.string dir_.ignoredByGit )
        , ( "dev", Json.Encode.string dir_.dev )
        , ( "devAssets", Json.Encode.string dir_.devAssets )
        , ( "build", Json.Encode.string dir_.build )
        ]



-- FILE


type alias File =
    { elmWorker : String
    , jsStarter : String
    , indexElm : String
    , mainElm : String
    }


file : Flags -> File
file flags =
    { elmWorker = flags.fileElmWorker
    , jsStarter = .elmStartSrc (dir flags) ++ "/starter.js"
    , indexElm = .src (dir flags) ++ "/Index.elm"
    , mainElm = .src (dir flags) ++ "/Main.elm"
    }


fileEncoder : File -> Json.Encode.Value
fileEncoder file_ =
    Json.Encode.object
        [ ( "elmWorker", Json.Encode.string file_.elmWorker )
        , ( "jsStarter", Json.Encode.string file_.jsStarter )
        , ( "indexElm", Json.Encode.string file_.indexElm )
        , ( "mainElm", Json.Encode.string file_.mainElm )
        ]
