module Starter.Conf exposing (Conf, conf)

import Html.String
import Html.String.Extra
import Index
import Json.Encode
import Main
import Starter.Cache
import Starter.ConfMain
import Starter.ConfMeta
import Starter.ElmLive
import Starter.Flags
import Starter.Icon
import Starter.Manifest
import Starter.ServiceWorker
import Starter.SnippetHtml


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
fileIndexHtml doNotEditDisclaimer indentation startingPage =
    Html.String.Extra.doctype
        ++ "\n"
        ++ "<!-- "
        ++ doNotEditDisclaimer
        ++ " -->\n"
        ++ Html.String.toString indentation
            startingPage


type alias Conf msg =
    { dir : Starter.Flags.Dir
    , file : Starter.Flags.File
    , fileNames : Starter.ConfMeta.FileNames

    --
    , fileIndexHtml : Html.String.Html msg

    --
    , extraHtml : List (Html.String.Html msg)
    , iconsForManifest : List Int
    , portBuild : Int
    , portDev : Int
    , portStatic : Int
    , doNotEditDisclaimer : String

    --
    , flags : Starter.Flags.Flags
    }


conf : Starter.Flags.Flags -> Json.Encode.Value
conf flags =
    encoder
        -- TODO - finish to move this stuff inside the encoder
        { dir = Starter.Flags.dir flags
        , file = Starter.Flags.file flags
        , fileNames = Starter.ConfMeta.conf.fileNames

        --
        , fileIndexHtml = Index.index flags

        --
        , extraHtml = Starter.SnippetHtml.extraHtml Starter.Cache.stuffToCache
        , iconsForManifest = Starter.Icon.iconsForManifest
        , portBuild = Starter.ConfMeta.conf.portBuild
        , portDev = Starter.ConfMeta.conf.portDev
        , portStatic = Starter.ConfMeta.conf.portStatic
        , doNotEditDisclaimer = Starter.ConfMeta.conf.doNotEditDisclaimer

        --
        , flags = flags
        }


encoder : Conf msg -> Json.Encode.Value
encoder args =
    Json.Encode.object
        [ ( "dir"
          , args.dir
                |> Starter.Flags.dirEncoder
          )
        , ( "file"
          , args.file
                |> Starter.Flags.fileEncoder
          )
        , ( "serverDev"
          , { elmFileToCompile = .mainElm (Starter.Flags.file args.flags)
            , dir = .dev (Starter.Flags.dir args.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir args.flags) ++ args.fileNames.outputCompiledJs
            , indexHtml = args.fileNames.indexHtml
            , port_ = args.portDev
            , compilation = Starter.ElmLive.Debug
            , verbose = Starter.ElmLive.VerboseNo
            , reload = Starter.ElmLive.ReloadYes
            , dirBin = .bin (Starter.Flags.dir args.flags)
            }
                |> Starter.ElmLive.elmLive
                |> Starter.ElmLive.encoder
          )
        , ( "serverStatic"
          , { elmFileToCompile = .mainElm (Starter.Flags.file args.flags)
            , dir = .dev (Starter.Flags.dir args.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir args.flags) ++ args.fileNames.outputCompiledJs
            , indexHtml = args.fileNames.indexHtml
            , port_ = args.portStatic
            , compilation = Starter.ElmLive.Optimize
            , verbose = Starter.ElmLive.VerboseNo
            , reload = Starter.ElmLive.ReloadNo
            , dirBin = .bin (Starter.Flags.dir args.flags)
            }
                |> Starter.ElmLive.elmLive
                |> Starter.ElmLive.encoder
          )
        , ( "serverBuild"
          , { elmFileToCompile = .mainElm (Starter.Flags.file args.flags)
            , dir = .build (Starter.Flags.dir args.flags)
            , outputCompiledJs = .dev (Starter.Flags.dir args.flags) ++ args.fileNames.outputCompiledJs
            , indexHtml = args.fileNames.indexHtml
            , port_ = args.portBuild
            , compilation = Starter.ElmLive.Normal
            , verbose = Starter.ElmLive.VerboseNo
            , reload = Starter.ElmLive.ReloadNo
            , dirBin = .bin (Starter.Flags.dir args.flags)
            }
                |> Starter.ElmLive.elmLive
                |> Starter.ElmLive.encoder
          )
        , ( "headless", Json.Encode.bool True )
        , ( "startingDomain"
          , Json.Encode.string
                ("http://localhost:" ++ String.fromInt args.portStatic)
          )
        , ( "batchesSize", Json.Encode.int 4 )
        , ( "snapshots", Json.Encode.bool True )
        , ( "pagesName", Json.Encode.string "index.html" )
        , ( "snapshotsDir", Json.Encode.string "snapshot" )
        , ( "snapshotsName", Json.Encode.string "snapshot.jpg" )
        , ( "snapshotsWidth", Json.Encode.int 400 )
        , ( "snapshotsHeight", Json.Encode.int 400 )
        , ( "snapshotsQuality", Json.Encode.int 80 )
        , ( "mainConf", Starter.ConfMain.encoder Main.conf )
        , ( "extraHtml"
          , args.extraHtml
                |> List.map (\html -> Html.String.toString Starter.ConfMeta.conf.indentation html)
                |> String.join ""
                |> Json.Encode.string
          )
        , ( "files"
          , (Json.Encode.list <| file)
                --
                -- "/manifest.json"
                --
                [ ( args.fileNames.manifestJson
                  , { iconSizes = args.iconsForManifest
                    , themeColor = Main.conf.themeColor
                    , title = Main.conf.title
                    }
                        |> Starter.Manifest.manifest
                        |> Json.Encode.encode Starter.ConfMeta.conf.indentation
                  )

                -- "/_redirects"
                --
                -- Netlify Configuration File
                --
                , ( args.fileNames.redirects
                  , "/* /index.html 200"
                  )

                -- "/service-worker.js"
                --
                , ( args.fileNames.serviceWorker
                  , Starter.ServiceWorker.serviceWorker
                  )

                -- "/index.html"
                --
                , ( args.fileNames.indexHtml
                  , fileIndexHtml args.doNotEditDisclaimer Starter.ConfMeta.conf.indentation args.fileIndexHtml
                  )

                -- "/robots.txt"
                --
                -- https://www.robotstxt.org/robotstxt.html
                --
                , ( args.fileNames.robotsTxt
                  , [ "User-agent: *"
                    , "Disallow:"
                    , "Sitemap: " ++ Main.conf.domain ++ args.fileNames.sitemap
                    ]
                        |> String.join "\n"
                  )

                -- "/sitemap.txt"
                --
                , ( args.fileNames.sitemap
                  , String.join "\n" <| List.map (\url -> Main.conf.domain ++ url) Main.conf.urls
                  )
                ]
          )
        ]
