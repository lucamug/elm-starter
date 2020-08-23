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


iconFileName : String -> Int -> String
iconFileName relative size =
    let
        sizeString =
            String.fromInt size
    in
    relative ++ "/icons/" ++ sizeString ++ ".png"
