module Starter.Cache exposing (stuffToCache)

import Main
import Starter.ConfMeta
import Starter.FileNames
import Starter.Icon


stuffToCache : String -> String -> String -> List ( String, String ) -> List ( String, String )
stuffToCache relative version commit assets =
    let
        fileNames =
            Starter.FileNames.fileNames version commit
    in
    []
        -- Production elm.js
        ++ [ ( relative ++ fileNames.outputCompiledJsProd, version ) ]
        -- manifest.json
        ++ [ ( relative ++ fileNames.manifestJson, version ) ]
        -- Static pages coming from src/Main.elm
        ++ List.map (\url -> ( url, version )) Main.conf.urls
        -- Extra stuff coming from src/Main.elm
        ++ List.map (\url -> ( url, version )) Main.conf.assetsToCache
        ++ assets
        |> List.map (\( url, hash ) -> ( String.replace "//" "/" url, hash ))
