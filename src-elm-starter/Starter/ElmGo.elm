module Starter.ElmGo exposing
    ( Compilation(..)
    , ElmLiveArgs
    , HotReload(..)
    , Pushstate(..)
    , Reload(..)
    , Ssl(..)
    , Verbose(..)
    , elmGo
    , encoder
    )

import Json.Encode


type alias ElmLiveArgs =
    { dir : String
    , outputCompiledJs : String
    , indexHtml : String
    , port_ : Int
    , compilation : Compilation
    , verbose : Verbose
    , pushstate : Pushstate
    , reload : Reload
    , hotReload : HotReload
    , ssl : Ssl
    , elmFileToCompile : String
    , dirBin : String
    , relative : String
    , certificatesFolder : String
    }


type Compilation
    = Optimize
    | Normal
    | Debug


type Reload
    = ReloadYes
    | ReloadNo


type HotReload
    = HotReloadYes
    | HotReloadNo


type Verbose
    = VerboseYes
    | VerboseNo


type Pushstate
    = PushstateYes
    | PushstateNo


type Ssl
    = SslYes
    | SslNo


elmGo : ElmLiveArgs -> { command : String, parameters : List String }
elmGo args =
    -- { command = args.dirBin ++ "/elm-go"
    { command = "node"
    , parameters =
        [ "node_modules/.bin/elm-go"

        -- [ "elm-go/bin/elm-go.js"
        , args.elmFileToCompile
        , "--path-to-elm=" ++ args.dirBin ++ "/elm"
        , "--dir=" ++ args.dir
        , "--start-page=" ++ args.indexHtml
        , "--port=" ++ String.fromInt args.port_
        ]
            ++ (case args.ssl of
                    SslYes ->
                        [ "--ssl"

                        -- , "--ssl-cert=" ++ args.certificatesFolder ++ "/localhost.crt"
                        -- , "--ssl-key=" ++ args.certificatesFolder ++ "/localhost.key"
                        ]

                    SslNo ->
                        []
               )
            ++ (case args.pushstate of
                    PushstateYes ->
                        [ "--pushstate" ]

                    PushstateNo ->
                        []
               )
            ++ (case args.verbose of
                    VerboseYes ->
                        [ "--verbose" ]

                    VerboseNo ->
                        []
               )
            ++ (case args.hotReload of
                    HotReloadYes ->
                        [ "--hot" ]

                    HotReloadNo ->
                        []
               )
            ++ (case args.reload of
                    ReloadYes ->
                        []

                    ReloadNo ->
                        [ "--no-reload" ]
               )
            ++ [ "--"
               , "--output=" ++ args.outputCompiledJs
               ]
            ++ (case args.compilation of
                    Optimize ->
                        [ "--optimize" ]

                    Normal ->
                        []

                    Debug ->
                        [ "--debug" ]
               )
    }


encoder : { command : String, parameters : List String } -> Json.Encode.Value
encoder args =
    Json.Encode.object
        [ ( "command", Json.Encode.string args.command )
        , ( "parameters", Json.Encode.list Json.Encode.string args.parameters )
        ]
