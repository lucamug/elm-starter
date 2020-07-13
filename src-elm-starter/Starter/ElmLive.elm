module Starter.ElmLive exposing
    ( Compilation(..)
    , ElmLive
    , Reload(..)
    , Verbose(..)
    , elmLive
    , encoder
    )

import Json.Encode


type alias ElmLive =
    { dir : String
    , outputCompiledJs : String
    , indexHtml : String
    , port_ : Int
    , compilation : Compilation
    , verbose : Verbose
    , reload : Reload
    , elmFileToCompile : String
    , dirBin : String
    }


type Compilation
    = Optimize
    | Normal
    | Debug


type Reload
    = ReloadYes
    | ReloadNo


type Verbose
    = VerboseYes
    | VerboseNo


elmLive : ElmLive -> { command : String, parameters : List String }
elmLive args =
    { command = args.dirBin ++ "/elm-live"
    , parameters =
        [ args.elmFileToCompile
        , "--pushstate"
        , "--path-to-elm=" ++ args.dirBin ++ "/elm"
        , "--dir=" ++ args.dir
        , "--start-page=" ++ args.indexHtml
        , "--port=" ++ String.fromInt args.port_
        ]
            ++ (case args.verbose of
                    VerboseYes ->
                        [ "--verbose" ]

                    VerboseNo ->
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
