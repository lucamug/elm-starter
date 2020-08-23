module Starter.Manifest exposing
    ( Manifest
    , manifest
    )

import Json.Encode
import Starter.Icon


manifestIcon : String -> Int -> Json.Encode.Value
manifestIcon relative size =
    let
        sizeString =
            String.fromInt size
    in
    Json.Encode.object
        [ ( "src", Json.Encode.string (Starter.Icon.iconFileName relative size) )
        , ( "sizes", Json.Encode.string (sizeString ++ "x" ++ sizeString) )
        , ( "type", Json.Encode.string "image/png" )
        , ( "purpose", Json.Encode.string "any maskable" )
        ]


type alias Manifest =
    { iconSizes : List Int
    , themeColor : String
    , name : String
    , nameLong : String
    }


manifest : String -> Manifest -> Json.Encode.Value
manifest relative args =
    -- https://developer.mozilla.org/en-US/docs/Web/Manifest
    Json.Encode.object
        [ ( "short_name", Json.Encode.string args.name )
        , ( "name", Json.Encode.string args.nameLong )
        , ( "start_url", Json.Encode.string (relative ++ "/") )
        , ( "display", Json.Encode.string "standalone" )
        , ( "background_color", Json.Encode.string args.themeColor )
        , ( "theme_color", Json.Encode.string args.themeColor )
        , ( "icons", Json.Encode.list (manifestIcon relative) args.iconSizes )

        -- TODO - add https://developer.mozilla.org/en-US/docs/Web/Manifest/screenshots
        ]
