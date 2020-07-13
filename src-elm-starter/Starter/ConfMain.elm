module Starter.ConfMain exposing
    ( Conf
    , encoder
    )

import Html.String
import Json.Encode
import Starter.ConfMeta


type alias Conf =
    { title : String
    , description : String
    , domain : String
    , urls : List String
    , assetsToCache : List String
    , twitterSite : String
    , twitterHandle : String
    , themeColor : String
    , author : String
    , snapshotFileName : String
    , snapshotWidth : Int
    , snapshotHeight : Int
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
        , ( "author", Json.Encode.string mainConf_.author )
        , ( "snapshotFileName", Json.Encode.string mainConf_.snapshotFileName )
        ]
