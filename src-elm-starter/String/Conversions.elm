module String.Conversions exposing (fromValue)

import Json.Encode


{-| Convert a Json.Decode.Value to a JSON String.
-}
fromValue : Json.Encode.Value -> String
fromValue value =
    Json.Encode.encode 0 value
