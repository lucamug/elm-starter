module Starter.Conf exposing
    ( Conf
    , conf_
    )

import Html.String
import Html.String.Extra
import Index
import Json.Encode
import Main
import Starter.ConfMain
import Starter.ConfMeta
import Starter.ElmGo
import Starter.FileNames
import Starter.Flags
import Starter.Icon
import Starter.Manifest
import Starter.ServiceWorker


file : ( String, String ) -> Json.Encode.Value
file ( name, content_ ) =
    Json.Encode.object
        [ ( "name", Json.Encode.string name )
        , ( "content", Json.Encode.string content_ )
        ]


fileIndexHtml :
    String
    -> Int
    -> Html.String.Html msg
    -> String
fileIndexHtml messageDoNotEditDisclaimer indentation startingPage =
    Html.String.Extra.doctype
        ++ "\n"
        ++ "<!-- "
        ++ messageDoNotEditDisclaimer
        ++ " -->\n"
        ++ Html.String.toString indentation
            startingPage


type alias Conf msg =
    { dir : Starter.Flags.Dir
    , file : Starter.Flags.File
    , fileNames : Starter.FileNames.FileNames
    , fileIndexHtml : Html.String.Html msg
    , htmlToReinject : List (Html.String.Html msg)
    , iconsForManifest : List Int
    , portBuild : Int
    , portDev : Int
    , portStatic : Int
    , messageDoNotEditDisclaimer : String
    , flags : Starter.Flags.Flags
    }


conf_ : Starter.Flags.Flags -> Json.Encode.Value
conf_ flags =
    encoder
        { dir = Starter.Flags.dir flags
        , file = Starter.Flags.file flags
        , fileNames = Starter.FileNames.fileNames flags.version flags.commit
        , fileIndexHtml = Index.index flags
        , htmlToReinject = Index.htmlToReinject flags
        , iconsForManifest = Starter.Icon.iconsForManifest
        , portBuild = Starter.ConfMeta.confMeta.portBuild
        , portDev = Starter.ConfMeta.confMeta.portDev
        , portStatic = Starter.ConfMeta.confMeta.portStatic
        , messageDoNotEditDisclaimer = Starter.ConfMeta.confMeta.messageDoNotEditDisclaimer
        , flags = flags
        }


encoder : Conf msg -> Json.Encode.Value
encoder conf =
    let
        relative =
            .relative (Starter.Flags.dir conf.flags)

        fileNames =
            Starter.FileNames.fileNames conf.flags.version conf.flags.commit
    in
    Json.Encode.object
        [ ( "outputCompiledJs", Json.Encode.string fileNames.outputCompiledJs )
        , ( "outputCompiledJsProd", Json.Encode.string fileNames.outputCompiledJsProd )
        , ( "dir"
          , conf.dir
                |> Starter.Flags.dirEncoder
          )
        , ( "file"
          , conf.file
                |> Starter.Flags.fileEncoder
          )
        , ( "serverDev"
          , { elmFileToCompile = .mainElm (Starter.Flags.file conf.flags)
            , dir = .devRoot (Starter.Flags.dir conf.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir conf.flags) ++ conf.fileNames.outputCompiledJsProd
            , indexHtml = relative ++ conf.fileNames.indexHtml
            , relative = relative
            , port_ = conf.portDev
            , compilation = Starter.ElmGo.Debug
            , verbose = Starter.ElmGo.VerboseNo
            , pushstate = Starter.ElmGo.PushstateYes
            , reload = Starter.ElmGo.ReloadYes
            , hotReload = Starter.ElmGo.HotReloadYes
            , ssl = Starter.ElmGo.SslNo
            , dirBin = .bin (Starter.Flags.dir conf.flags)
            , certificatesFolder = conf.dir.elmStartSrc
            }
                |> Starter.ElmGo.elmGo
                |> Starter.ElmGo.encoder
          )
        , ( "serverStatic"
          , { elmFileToCompile = .mainElm (Starter.Flags.file conf.flags)
            , dir = .devRoot (Starter.Flags.dir conf.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir conf.flags) ++ conf.fileNames.outputCompiledJsProd
            , indexHtml = relative ++ conf.fileNames.indexHtml
            , relative = relative
            , port_ = conf.portStatic
            , compilation = Starter.ElmGo.Optimize
            , verbose = Starter.ElmGo.VerboseNo
            , pushstate = Starter.ElmGo.PushstateYes
            , reload = Starter.ElmGo.ReloadNo
            , hotReload = Starter.ElmGo.HotReloadNo
            , ssl = Starter.ElmGo.SslNo
            , dirBin = .bin (Starter.Flags.dir conf.flags)
            , certificatesFolder = conf.dir.elmStartSrc
            }
                |> Starter.ElmGo.elmGo
                |> Starter.ElmGo.encoder
          )
        , ( "serverBuild"
          , { elmFileToCompile = .mainElm (Starter.Flags.file conf.flags)
            , dir = .buildRoot (Starter.Flags.dir conf.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir conf.flags) ++ conf.fileNames.outputCompiledJsProd
            , indexHtml = conf.fileNames.indexHtml
            , relative = relative
            , port_ = conf.portBuild
            , compilation = Starter.ElmGo.Normal
            , verbose = Starter.ElmGo.VerboseNo
            , pushstate = Starter.ElmGo.PushstateNo
            , reload = Starter.ElmGo.ReloadNo
            , hotReload = Starter.ElmGo.HotReloadNo
            , ssl = Starter.ElmGo.SslNo
            , dirBin = .bin (Starter.Flags.dir conf.flags)
            , certificatesFolder = conf.dir.elmStartSrc
            }
                |> Starter.ElmGo.elmGo
                |> Starter.ElmGo.encoder
          )
        , ( "headless", Json.Encode.bool True )
        , ( "startingDomain"
          , Json.Encode.string
                ("http://localhost:" ++ String.fromInt conf.portStatic)
          )
        , ( "batchesSize", Json.Encode.int 4 )
        , ( "pagesName", Json.Encode.string "index.html" )
        , ( "snapshots", Json.Encode.bool True )
        , ( "snapshotsQuality", Json.Encode.int 80 )
        , ( "snapshotWidth", Json.Encode.int <| Maybe.withDefault 700 <| String.toInt <| Maybe.withDefault "" <| conf.flags.snapshotWidth )
        , ( "snapshotHeight", Json.Encode.int <| Maybe.withDefault 350 <| String.toInt <| Maybe.withDefault "" <| conf.flags.snapshotHeight )
        , ( "snapshotFileName", Json.Encode.string fileNames.snapshot )
        , ( "mainConf", Starter.ConfMain.encoder Main.conf )
        , ( "htmlToReinject"
          , conf.htmlToReinject
                |> List.map (\html -> Html.String.toString Starter.ConfMeta.confMeta.indentation html)
                |> String.join ""
                |> Json.Encode.string
          )
        , ( "flags", Starter.Flags.encoder conf.flags )
        , ( "files"
          , (Json.Encode.list <| file)
                --
                -- "/manifest.json"
                --
                [ ( conf.fileNames.manifestJson
                  , { iconSizes = conf.iconsForManifest
                    , themeColor = Starter.Flags.toThemeColor conf.flags
                    , name = conf.flags.name
                    , nameLong = conf.flags.nameLong
                    }
                        |> Starter.Manifest.manifest relative
                        |> Json.Encode.encode Starter.ConfMeta.confMeta.indentation
                  )

                -- "/_redirects"
                --
                -- Netlify Configuration File
                --
                -- , ( conf.fileNames.redirects
                --   , "/* /index.html 200"
                --   )
                -- "/service-worker.js"
                --
                , ( fileNames.serviceWorker
                  , let
                        -- Assets need to have different path
                        assets =
                            List.map
                                (\( path, hash ) ->
                                    ( String.replace conf.flags.dirAssets relative path, hash )
                                )
                                conf.flags.assets
                    in
                    Starter.ServiceWorker.serviceWorker
                        { assets = assets
                        , commit = conf.flags.commit
                        , relative = relative
                        , version = conf.flags.version
                        }
                  )

                -- "/index.html"
                --
                , ( fileNames.indexHtml
                  , fileIndexHtml conf.messageDoNotEditDisclaimer Starter.ConfMeta.confMeta.indentation conf.fileIndexHtml
                  )

                -- "/robots.txt"
                --
                -- https://www.robotstxt.org/robotstxt.html
                --
                , ( conf.fileNames.robotsTxt
                  , [ "User-agent: *"
                    , "Disallow:"
                    , "Sitemap: " ++ conf.flags.homepage ++ conf.fileNames.sitemap
                    ]
                        |> String.join "\n"
                  )

                -- "/sitemap.txt"
                --
                , ( conf.fileNames.sitemap
                  , String.join "\n" <| List.map (\url -> String.replace relative "" conf.flags.homepage ++ url) Main.conf.urls
                  )
                ]
          )
        ]
