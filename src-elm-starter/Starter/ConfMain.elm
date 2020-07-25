module Starter.ConfMain exposing
    ( Conf
    , encoder
    )

import Json.Encode


type alias Conf =
    { urls : List String
    , assetsToCache : List String
    }


encoder : Conf -> Json.Encode.Value
encoder mainConf_ =
    Json.Encode.object
        [ ( "urls", Json.Encode.list Json.Encode.string mainConf_.urls )
        , ( "assetsToCache", Json.Encode.list Json.Encode.string mainConf_.assetsToCache )
        ]
