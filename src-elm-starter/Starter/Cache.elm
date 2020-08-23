module Starter.Cache exposing (stuffToCache)

import Main
import Starter.ConfMeta
import Starter.Icon


stuffToCache : String -> List String
stuffToCache relative =
    [ relative ++ Starter.ConfMeta.conf.fileNames.outputCompiledJs
    , relative ++ Starter.ConfMeta.conf.fileNames.manifestJson
    ]
        ++ List.map (\url -> url) Main.conf.urls
        ++ Main.conf.assetsToCache
        ++ List.map (\size -> Starter.Icon.iconFileName relative size) Starter.Icon.iconsToBeCached
        |> List.map (\url -> String.replace "//" "/" url)
