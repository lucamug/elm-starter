module Starter.Cache exposing (stuffToCache)

import Main
import Starter.ConfMeta
import Starter.Flags
import Starter.Icon


stuffToCache : List String
stuffToCache =
    [ Starter.ConfMeta.conf.fileNames.outputCompiledJs
    , Starter.ConfMeta.conf.fileNames.manifestJson
    ]
        ++ List.map (\url -> url) Main.conf.urls
        ++ Main.conf.assetsToCache
        ++ List.map (\size -> Starter.Icon.iconFileName size) Starter.Icon.iconsToBeCached
        |> List.map (\url -> String.replace "//" "/" url)
