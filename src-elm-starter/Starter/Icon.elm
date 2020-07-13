module Starter.Icon exposing
    ( iconFileName
    , iconsForManifest
    , iconsToBeCached
    )


iconsForManifest : List number
iconsForManifest =
    [ 128, 144, 152, 192, 256, 512 ]


iconsToBeCached : List number
iconsToBeCached =
    [ 16, 32, 64 ] ++ iconsForManifest


iconFileName : Int -> String
iconFileName size =
    let
        sizeString =
            String.fromInt size
    in
    "/icons/" ++ sizeString ++ ".png"
