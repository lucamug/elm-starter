module Starter.ConfMain exposing
    ( Conf
    , encoder
    )

import Html.String
import Json.Encode
import Starter.ConfMeta


type alias Conf =
    { urls : List String
    , assetsToCache : List String
    , twitterSite : String
    , twitterHandle : String
    , themeColor : String
    , snapshotFileName : String
    , snapshotWidth : Int
    , snapshotHeight : Int
    }


encoder : Conf -> Json.Encode.Value
encoder mainConf_ =
    Json.Encode.object
        [ ( "urls", Json.Encode.list Json.Encode.string mainConf_.urls )
        , ( "assetsToCache", Json.Encode.list Json.Encode.string mainConf_.assetsToCache )
        , ( "twitterSite", Json.Encode.string mainConf_.twitterSite )
        , ( "twitterHandle", Json.Encode.string mainConf_.twitterHandle )
        , ( "themeColor", Json.Encode.string mainConf_.themeColor )
        , ( "snapshotFileName", Json.Encode.string mainConf_.snapshotFileName )
        ]
