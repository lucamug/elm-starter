module Starter.FileNames exposing
    ( FileNames
    , fileNames
    )


type alias FileNames =
    { outputCompiledJs : String
    , outputCompiledJsProd : String
    , indexHtml : String
    , manifestJson : String
    , redirects : String
    , robotsTxt : String
    , serviceWorker : String
    , sitemap : String
    , snapshot : String
    }


fileNames : String -> String -> FileNames
fileNames version commit =
    { manifestJson = "/manifest.json"
    , redirects = "/_redirects"
    , robotsTxt = "/robots.txt"
    , outputCompiledJs = "/elm.js"
    , outputCompiledJsProd = "/elm-" ++ version ++ "-" ++ commit ++ ".min.js"
    , indexHtml = "/index.html"
    , serviceWorker = "/service-worker.js"
    , sitemap = "/sitemap.txt"
    , snapshot = "/snapshot.jpg"
    }
