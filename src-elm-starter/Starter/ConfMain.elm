module Starter.ConfMain exposing
    ( Conf
    , encoder
    )

import Json.Encode


type alias Conf =
    { title : String
    , description : String
    , domain : String
    , urls : List String
    , assetsToCache : List String
    , twitterSite : String
    , twitterHandle : String
    , themeColor : String
    , javascriptThatStartsElm : String
    , extraHtml : String
    , author : String
    }


encoder : Conf -> Json.Encode.Value
encoder mainConf_ =
    Json.Encode.object
        [ ( "title", Json.Encode.string mainConf_.title )
        , ( "description", Json.Encode.string mainConf_.description )
        , ( "domain", Json.Encode.string mainConf_.domain )
        , ( "urls", Json.Encode.list Json.Encode.string mainConf_.urls )
        , ( "assetsToCache", Json.Encode.list Json.Encode.string mainConf_.assetsToCache )
        , ( "twitterSite", Json.Encode.string mainConf_.twitterSite )
        , ( "twitterHandle", Json.Encode.string mainConf_.twitterHandle )
        , ( "themeColor", Json.Encode.string mainConf_.themeColor )
        , ( "javascriptThatStartsElm", Json.Encode.string mainConf_.javascriptThatStartsElm )
        , ( "extraHtml", Json.Encode.string mainConf_.extraHtml )
        , ( "author", Json.Encode.string mainConf_.author )
        ]
