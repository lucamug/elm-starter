# elm-starter

`elm-starter` is an experimental Elm-based Elm bootstrapper that can also be plugged into already existing Elm applications. 

Example of the installed version, with and without Javascript enabled:

![elm-starter](assets/dev/elm-starter.gif)


### Demos

These are three simple examples of websites built with `elm-starter`:

* https://elm-starter.guupa.com/ ([Code](https://github.com/lucamug/elm-starter))
* https://elm-todomvc.guupa.com/ ([Code](https://github.com/lucamug/elm-todomvc))
* https://elm-spa-example.guupa.com/ ([Code](https://github.com/lucamug/elm-spa-example))

![elm-starter](assets/dev/collection.png)













# Characteristics

* Generate a PWA (Progressive Web Application)
* Most of the logic is written in Elm, including the code to generate all necessary files:
    * `index.html` (generated from [`Index.elm`](https://github.com/lucamug/elm-start-private/blob/master/src/Index.elm) using [`zwilias/elm-html-string`](https://package.elm-lang.org/packages/zwilias/elm-html-string/latest/))
    * [`sitemap.txt`](https://elm-starter.guupa.com/sitemap.txt)
    * [`manifest.json`](https://elm-starter.guupa.com/manifest.json)
    * [`service-worker.js`](https://elm-starter.guupa.com/service-worker.js)
    * [`robots.txt`](https://elm-starter.guupa.com/robots.txt)
* Pages are pre-rendered during the build together with their snapshots, using [`puppeteer`](https://github.com/puppeteer/puppeteer)
* The app can work without Javascript(\*)
* SEO
* Preview cards (Facebook, Twitter, etc.) work as expected
* Works offline
* Installable both on desktop and on mobile
* High score with Lighthouse
* Friendly notifications: "Loading...", "Must enable Javascript...", "Better enable Javascript..."
* Potentially compatible with all Elm libraries (elm-ui, elm-spa, etc.)
* Hopefully relatively simple to use and maintain
* Works with Netlify, Surge, etc.

Lighthouse report:

![elm-starter](assets/dev/lighthouse.png)










# How to bootstrap a new project

`elm-starter` is not published in npm yet and it doesn't have a specific command to bootstrap a project, so the way it works now is cloning this repo.

The steps are:

```
$ git clone https://github.com/lucamug/elm-starter
$ mv elm-starter my-new-project
$ cd my-new-project
$ rm -rf .git
$ npm install
```
Done! At this point, these are the available commands:

### `$ npm start`

Runs the app in the development mode.
Open [http://localhost:8000](http://localhost:8000) to view it in the browser.

Edit `src/Main.elm` and save to reload the browser.

Also edit `src/Index.elm` and `package.json` for further customization.

### `$ npm run build`

Builds the app for production to the `elm-stuff/elm-starter-files/build` folder.

### `$ npm run serverBuild`

Launches a server in the `build` folder.

Open [http://localhost:9000](http://localhost:9000) to view it in the browser.












# How to use `elm-starter` in existing Elm application

Let's suppose your existing project is in `my-elm-app`

* Clone `elm-starter` with<br> 
    `$ git clone https://github.com/lucamug/elm-starter.git`
* Copy the folder [`elm-starter/src-elm-starter/`](https://github.com/lucamug/elm-starter/tree/master/src-elm-starter) to `my-elm-app/src-elm-starter/`
* Copy the file [`elm-starter/src/Index.elm`](https://github.com/lucamug/elm-starter/blob/master/src/Index.elm) to `my-elm-app/src/Index.elm`
* Copy the function `conf` from [`elm-starter/src/Main.elm`](https://github.com/lucamug/elm-starter/blob/master/src/Main.elm#L33) to `my-elm-app/src/Main.elm` (remember also to expose it)
* If you don't have `package.json` in your project, add one with `$ npm init`
* Be sure that you have these values in `package.json` as they will be used all over the places:

    ```
    "name": "app-name",
    "nameLong": "app-name - This can contain spaces",
    "description": "App description",
    "author": "Your name",
    "version": "1.0.0",
    "homepage": "https://your-app.com",
    "license": "BSD-3-Clause",
    ```

* Add `node` dependencies with these commands 
    
    ```
    $ npm install --save-dev chokidar-cli
    $ npm install --save-dev concurrently
    $ npm install --save-dev elm
    $ npm install --save-dev elm-live
    $ npm install --save-dev html-minifier
    $ npm install --save-dev puppeteer
    $ npm install --save-dev terser
    ```
    
* Add `src-elm-starter` as an extra `source-directory` in `elm.json`, the same as in `elm-starter/elm.json`
* Add these commands to `package.json` (or run them directly)
    ```
      "scripts": {
        "start":       "node ./src-elm-starter/starter.js start",
        "build":       "node ./src-elm-starter/starter.js build",
        "serverBuild": "node ./src-elm-starter/starter.js serverBuild"
      },
    ```
Done!









# Netlify

When setting up the app with Netlify, input these in the deploy configuration:

* Build command: `npm run build` (or `node ./src-elm-starter/starter.js start`)
* Publish directory: `elm-stuff/elm-starter-files/build`









# (\*) Applications working without Javascript

Working without Javascript depends on the application. The `elm-starter` example works completely fine also without Javascript, the only missing thing is the smooth transition between pages.

The `elm-todomvc` example requires Javascript. Note that in this example, compared to Evan's original TodoMVC, I slightly changed the CSS to improve the a11y (mainly lack of contrast and fonts too small).

The `elm-spa-example` partially works without Javascript. You can browse across pages but the counters are not working.

`elm-starter` and `elm-todomvc` use `Browser.element`, while `elm-spa-example` use `Browser.application`.

The setup for these two cases is a bit different. `Browser.application` requires to use `htmlToReinject` (see `Index.elm`) because Elm is wiping out all the content in the body. Also the node where Elm attach itself needs to be removed (see `node.remove()` ).

The working folder of `elm-starter` is `elm-stuff/elm-starter-files`. These files are automatically generated and should not be edited directly, unless during some debugging process.









# Advanced stuff

## Disabling pre-rendering

Is possible to disable pre-rendering just passing an empty list to `Main.conf.urls`. In this case the app will work as "Full CSR" (Full Client-side Rendering)

## How to customize your project.

The main two places where you can change stuff are:

* `src/Index.elm`
* `src/Main.elm` (`conf` function)

`elm-starter` is opinionated about many things. If you want more freedom, you can change stuff in

* `src-elm-starter/**/*.elm`

The reason `Main.conf` is inside `Main.elm` is so that it can exchange data. For example:

* `title`: `Main.conf` -> `Main`
* `urls`: `Main.conf` <- `Main`
    
Moreover `Main.conf` is used by `src-elm-starter` to generate all the static files.

## elm-console-debug.js for nice console output

Support https://github.com/kraklin/elm-debug-transformer out of the box for nice `Debug.log` messages in the console.

## Changing meta-tags

For better SEO, you should update meta-tags using the predefined port `changeMeta` that you can use this way:

```
Cmd.batch
    [ changeMeta { querySelector = "title", fieldName = "innerHTML", content = title }
    , changeMeta { querySelector = "meta[property='og:title']", fieldName = "content", content = title }
    , changeMeta { querySelector = "meta[name='twitter:title']", fieldName = "value", content = title }
    , changeMeta { querySelector = "meta[property='og:image']", fieldName = "content", content = image }
    , changeMeta { querySelector = "meta[name='twitter:image']", fieldName = "content", content = image }
    , changeMeta { querySelector = "meta[property='og:url']", fieldName = "content", content = url }
    , changeMeta { querySelector = "meta[name='twitter:url']", fieldName = "value", content = url }
    ]
```

You can validate Twitter preview cards at https://cards-dev.twitter.com/validator

![elm-starter](assets/dev/twitter-card.jpg)

## Configuration

You can verify the configuration in real-time using elm reactor:
```
$ node_modules/.bin/elm reactor
```
and check the page

http://localhost:8000/src-elm-starter/Application.elm

## Globally available objects

There are three global objects available

### `ElmStarter`

`ElmStarter` contain metadata about the app:
```
{ commit: "abf04f3"   // coming from git
, branch: "master"    // coming from git 
, env: "dev"          // can be "dev" or "prod"
, version: "0.0.5"    // coming from package.json
}
```

This data is also available in Elm through Flags.

### `ElmApp`

`ElmApp` is another global object that contains the handle of the Elm app.

### `Elm`

This is the object exposed by the compiler used to initialize the application.






















# Limitations

* Javascript and CSS to generate the initial `index.html` are actually strings :-(
* `src-elm-starter/starter.js`, the core of `elm-starter`, is ~330 lines of Javascript. I wish it could be smaller
* If your Elm code relies on data only available at runtime, such as window size or dark mode, prerendering is probably not the right approach. In this case you may consider [disabling pre-rendering](#disabling-pre-rendering) and use other alternatives, such as [Netlify prerendering](https://docs.netlify.com/site-deploys/post-processing/prerendering/#set-up-prerendering)

Note

* The smooth rotational transition in the demo only works in Chrome. I realized it too late, but you get the picture








# Non-goals

Things that `elm-starter` is not expected to do 

* Doesn't generate Elm code automatically, like Route-parser, for example
* Doesn't do SSR (Server Side Render) but just pre-render during the build
* Doesn't change the Javascript coming out from the Elm compiler
* Doesn't create a web site based on static files containing Markdown
* There is no "[hydration](https://developers.google.com/web/updates/2019/02/rendering-on-the-web)", unless Elm does some magic that I am not aware of. 

You can find several of these characteristics in some of the [similar projects](#similar-projects).

Using as reference the table at the bottom of the article [Rendering on the Web](https://developers.google.com/web/updates/2019/02/rendering-on-the-web), `elm-starter` can support you in these rendering approach

* Static SSR
* CSR with Prerendering
* Full CSR

It cannot help you with

* Server Rendering
* SSR with (re)hydration




 
 
 
# Similar projects

These are other projects that can be used to bootstrap an Elm application or to generate a static site:

* [elm-pages](https://package.elm-lang.org/packages/dillonkearns/elm-pages/latest/)
* [elmstatic](https://github.com/alexkorban/elmstatic)
* [elm-spa](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/)
* [create-elm-app](https://github.com/halfzebra/create-elm-app)
* [spades](https://github.com/rogeriochaves/spades)


