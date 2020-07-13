module Starter.Manifest exposing
    ( Manifest
    , manifest
    )

import Json.Encode
import Starter.Icon


manifestIcon : Int -> Json.Encode.Value
manifestIcon size =
    let
        sizeString =
            String.fromInt size
    in
    Json.Encode.object
        [ ( "src", Json.Encode.string (Starter.Icon.iconFileName size) )
        , ( "sizes", Json.Encode.string (sizeString ++ "x" ++ sizeString) )
        , ( "type", Json.Encode.string "image/png" )
        , ( "purpose", Json.Encode.string "any maskable" )
        ]


type alias Manifest =
    { iconSizes : List Int
    , themeColor : String
    , title : String
    }


manifest : Manifest -> Json.Encode.Value
manifest args =
    -- https://developer.mozilla.org/en-US/docs/Web/Manifest
    Json.Encode.object
        [ ( "name", Json.Encode.string args.title )
        , ( "short_name", Json.Encode.string args.title )
        , ( "start_url", Json.Encode.string "/" )
        , ( "display", Json.Encode.string "standalone" )
        , ( "background_color", Json.Encode.string args.themeColor )
        , ( "theme_color", Json.Encode.string args.themeColor )
        , ( "icons", Json.Encode.list manifestIcon args.iconSizes )

        -- TODO - add https://developer.mozilla.org/en-US/docs/Web/Manifest/screenshots
        ]
