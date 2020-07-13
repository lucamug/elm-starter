module Starter.ServiceWorker exposing
    ( encoderCacheableUrls
    , precacheFiles
    , serviceWorker
    )

import Json.Encode
import Starter.Cache
import Starter.ConfMeta


encoderCacheableUrls : { a | revision : Maybe Int, url : String } -> Json.Encode.Value
encoderCacheableUrls obj =
    Json.Encode.object
        [ ( "url", Json.Encode.string obj.url )
        , ( "revision"
          , case obj.revision of
                Just revision ->
                    Json.Encode.string (String.fromInt revision)

                Nothing ->
                    Json.Encode.null
          )
        ]


precacheFiles : String
precacheFiles =
    Starter.Cache.stuffToCache
        |> List.map (\url -> { url = url, revision = Just 1 })
        |> Json.Encode.list encoderCacheableUrls
        |> Json.Encode.encode 4


serviceWorker : String
serviceWorker =
    """/* """
        ++ Starter.ConfMeta.conf.messageDoNotEditDisclaimer
        ++ """ */

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
        ++ """
);

registerRoute(
    ({request}) => request.destination === 'script',
    new NetworkFirst()
);

registerRoute(
    // Cache style resources, i.e. CSS files.
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
