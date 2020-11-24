module Starter.ServiceWorker exposing
    ( encoderCacheableUrls
    , precacheFiles
    , serviceWorker
    )

import Json.Encode
import Starter.Cache
import Starter.ConfMeta


encoderCacheableUrls : { a | revision : String, url : String } -> Json.Encode.Value
encoderCacheableUrls obj =
    Json.Encode.object
        [ ( "url", Json.Encode.string obj.url )
        , ( "revision", Json.Encode.string obj.revision )
        ]


precacheFiles :
    { assets : List ( String, String )
    , commit : String
    , relative : String
    , version : String
    }
    -> String
precacheFiles { relative, version, commit, assets } =
    Starter.Cache.stuffToCache relative version commit assets
        |> List.map (\( url, revision ) -> { url = url, revision = revision ++ "." ++ commit })
        |> Json.Encode.list encoderCacheableUrls
        |> Json.Encode.encode 4


serviceWorker :
    { assets : List ( String, String )
    , commit : String
    , relative : String
    , version : String
    }
    -> String
serviceWorker { relative, version, commit, assets } =
    "// "
        ++ Starter.ConfMeta.confMeta.messageDoNotEditDisclaimer
        ++ """
//
// This is implemented using Workbox
// https://developers.google.com/web/tools/workbox
//

importScripts('https://storage.googleapis.com/workbox-cdn/releases/5.1.2/workbox-sw.js');

const registerRoute = workbox.routing.registerRoute;
const NetworkFirst = workbox.strategies.NetworkFirst;
const CacheFirst = workbox.strategies.CacheFirst;
const StaleWhileRevalidate = workbox.strategies.StaleWhileRevalidate;
const ExpirationPlugin = workbox.expiration.ExpirationPlugin;
const precacheAndRoute = workbox.precaching.precacheAndRoute;

// https://developers.google.com/web/tools/workbox/guides/precache-files
precacheAndRoute( 
"""
        ++ precacheFiles
            { assets = assets
            , commit = commit
            , relative = relative
            , version = version
            }
        ++ """
);


registerRoute(
    ({url}) => url.pathname === ('/'),
    new NetworkFirst()
);

registerRoute(
    ({request}) => request.destination === 'script',
    new NetworkFirst()
);

registerRoute(
    // Cache style assets, i.e. CSS files.
    ({request}) => request.destination === 'style',
    // Use cache but update in the background.
    new StaleWhileRevalidate({
        // Use a custom cache name.
        cacheName: 'css-cache',
    })
);

// From https://developers.google.com/web/tools/workbox/guides/common-recipes
registerRoute(
  ({request}) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 60,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 Days
      }),
    ],
  })
);
"""
