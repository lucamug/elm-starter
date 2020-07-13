module Starter.Flags exposing
    ( Dir
    , Env(..)
    , File
    , Flags
    , dir
    , dirEncoder
    , file
    , fileEncoder
    )

import Json.Encode


type Env
    = Dev
    | Prod


type alias Flags =
    { env : String
    , version : String
    , gitCommit : String
    , gitBranch : String

    --
    , dirPw : String
    , dirBin : String
    , dirIgnoredByGit : String
    , dirTemp : String
    , fileElmWorker : String
    }


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
