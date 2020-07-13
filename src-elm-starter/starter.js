#!/usr/local/bin/node
const debugMode = false;
const fs = require("fs");
const path = require('path');
const terser = require("terser");
const puppeteer = require('puppeteer');
const concurrently = require('concurrently');
const child_process = require("child_process");
const html_minifier = require('html-minifier');
const package = require(`${process.cwd()}/package.json`);
const fgGreen = "\x1b[32m";
const fgYellow = "\x1b[33m";
const fgBlue = "\x1b[34m"
const fgMagenta = "\x1b[35m";
const dim = "\x1b[2m";
const reset = "\x1b[0m";
const totsu = "凸";
const styleTitle = ` ${fgYellow}${totsu} %s${reset}\n`;
const styleSubtitle = `    ${dim}${fgYellow}%s${reset}`;
const styleDebug = `    ${fgMagenta}%s${reset}`;
const arg = process.argv[2] ? process.argv[2] : "";
const gitCommit = child_process.execSync('git rev-parse --short HEAD').toString().replace(/^\s+|\s+$/g, '');
const gitBranch = child_process.execSync('git rev-parse --abbrev-ref HEAD').toString().replace(/^\s+|\s+$/g, '');
const DEV = "dev";
const PROD = "prod";

//
//
// PARSING ARGUMENTS
//
//

if (arg === "boot") {
    console.log(styleTitle, `Bootstrapping...`);
    bootstrap(DEV);

} else if (arg === "" || arg === "start") {
    console.log(styleTitle, `Starting (${gitCommit}, ${gitBranch})...`);
    bootstrap(DEV, command_start);

} else if (arg === "generateDevFiles" ) {
    console.log(styleTitle, `Generating dev files...`);
    bootstrap(DEV, command_generateDevFiles);

} else if (arg === "build" ) {
    console.log(styleTitle, `Building...`);
    bootstrap(PROD, command_build);

} else if (arg === "buildExpectingTheServerRunning" ) {
    console.log(styleTitle, `Building (I expect a server running on port 7000)...`);
    bootstrap(PROD, command_buildExpectingTheServerRunning);

} else if (arg === "serverBuild" ) {
    console.log(styleTitle, `Starting server "build"...`);
    bootstrap(PROD, command_serverBuild);

} else if (arg === "serverDev" ) {
    console.log(styleTitle, `Starting server DEV...`);
    bootstrap(DEV, command_serverDev);

} else if (arg === "serverStatic" ) {
    console.log(styleTitle, `Starting server "static" for genoneration of static pages...`);
    bootstrap(PROD, command_serverStatic);

} else if (arg === "watchStartElm" ) {
    console.log(styleTitle, `Watching elm-starter Elm files...`);
    bootstrap(DEV, command_watchStartElm);

} else {
    console.log(styleTitle, `Invalid parameter: ${arg}`);
}

//
//
// BOOTSTRAP
//
//

function bootstrap (env, callback) {
    callback = callback || function(){};
    env = env === DEV ? DEV : PROD;
    const dirPw = process.cwd();
    const relDirIgnoredByGit = `elm-stuff/elm-starter-files`;
    const dir = 
        { pw:           `${dirPw}`
        , bin:          `${dirPw}/node_modules/.bin`
        , ignoredByGit: `${dirPw}/${relDirIgnoredByGit}`
        , temp:         `${dirPw}/${relDirIgnoredByGit}/temp`
        }
    const file =
        { elmWorker:    `${dirPw}/src-elm-starter/Worker.elm`
        }
    const fielNameOutput = `${dir.temp}/worker.js`;
    const command = `${dir.bin}/elm make ${file.elmWorker} --output=${fielNameOutput}`;
    child_process.exec(command, (error, out) => {
        if (error) throw error;
        // Temporary silencing Elm warnings
        const consoleWarn = console.warn;
        console.warn = function() {};
        const Elm = require(fielNameOutput);
        // Restoring warnings
        console.warn = consoleWarn;
        var app = Elm.Elm.Worker.init(
            { flags :
                { env: env
                , version : package.version
                , gitCommit: gitCommit
                , gitBranch: gitBranch
                // Dirs
                , dirPw : dir.pw
                , dirBin : dir.bin
                , dirIgnoredByGit : dir.ignoredByGit
                , dirTemp : dir.temp
                // Files
                , fileElmWorker : file.elmWorker
                }
            }
        );
        app.ports.dataFromElmToJavascript.subscribe(function(conf) {
            // Got the file back from Elm!
            consoleDebug(conf.dir);
            consoleDebug(conf.file);
            callback(conf);
        });
    });
}

//
//
// COMMANDS
//
//

function command_start (conf) {
    command_generateDevFiles(conf);
    startCommand(`${conf.dir.bin}/concurrently`,
        [ `node ${conf.file.jsStarter} serverDev`
        , `node ${conf.file.jsStarter} watchStartElm`
        , `--kill-others`
        ]
    );
}

function command_generateDevFiles (conf) {
    removeDir(conf.dir.dev, false);
    mkdir(conf.dir.dev);
    mkdir(conf.dir.devAssets);
    generateFiles(conf, conf.dir.dev);
    // We symlink all assets from `assets` folder to `dev` folder
    // so that in development, changes to the assets are immediately
    // reflected. During the build instead we phisically copy files.
    symlinkDir(conf.dir.assets, conf.dir.dev);
    symlinkDir(conf.dir.assetsDev, conf.dir.devAssets);
    // Touching Main.elm so that, in case there is a server running,
    // it will re-generate elm.js
    child_process.exec(`touch ${conf.file.mainElm}`, (error, out) => {});
}

function command_build (conf) {
    startCommand(`${conf.dir.bin}/concurrently`,
        [ `node ${conf.file.jsStarter} serverStatic`
        // Here we wait two seconds so that the server has time to
        // compile Elm code and start itself
        , `sleep 2 && node ${conf.file.jsStarter} buildExpectingTheServerRunning`
        , `--kill-others`
        , `--success=first`
        ]
    );
}

function command_buildExpectingTheServerRunning (conf) {
    removeDir(conf.dir.build, false);
    mkdir(conf.dir.build);
    generateFiles(conf, conf.dir.build);
    console.log(styleSubtitle, `Compiling Elm`);
    const command = `${conf.dir.bin}/elm make ${conf.file.mainElm} --output=${conf.dir.build}/elm.js --optimize`;
    child_process.exec(command, (error, out) => {
        if (error) throw error;
        // Going back to the original directory
        minifyJs(conf, `elm.js`);
        console.log(styleSubtitle, `Copying assets`);
        copyDir(conf.dir.assets, conf.dir.build);
        generateStaticPages(conf);
    });
}

function command_serverBuild (conf) {
    startCommand
        ( conf.serverBuild.command
        , conf.serverBuild.parameters
        );
}

function command_serverDev (conf) {
    startCommand
        ( conf.serverDev.command
        , conf.serverDev.parameters
        );
}

function command_serverStatic (conf) {
    command_generateDevFiles(conf);
    startCommand
        ( conf.serverStatic.command
        , conf.serverStatic.parameters
        );
}

function command_watchStartElm (conf) {
    // Watching the src file to check in eny of the Elm file is changing
    startCommand(`${conf.dir.bin}/chokidar`,
        [ conf.dir.elmStartSrc
        , conf.file.indexElm
        , `-c`
        , `node ${conf.file.jsStarter} generateDevFiles`
        ]
    );
}

//
//
// HELPERS
//
//

async function generateStaticPages (conf) {
    try {
        console.log(styleSubtitle, `Building ${conf.mainConf.urls.length} static pages for ${conf.mainConf.domain}`);
        const browser = await puppeteer.launch({ headless: conf.headless });
        const urlsInBatches = chunkArray(conf.mainConf.urls, conf.batchesSize);
        await urlsInBatches.reduce(async (previousBatch, currentBatch, index) => {
            await previousBatch;
            console.log(styleSubtitle, `Processing batch ${index + 1} of ${urlsInBatches.length}...`);
            const currentBatchPromises = currentBatch.map(url => processUrl(url, browser, conf))
            const result = await Promise.all(currentBatchPromises);
        }, Promise.resolve());
        await browser.close();
        console.log(styleTitle, `Done!`);
        console.log(styleSubtitle, `The build is ready in "/${conf.dir.build}". Run "npm run serverBuild" to test it.`);
    } catch (error) {
        console.error(error);
    }
};

async function processUrl (url, browser, conf) {
    const page = await browser.newPage();
    await page.setViewport({width: conf.snapshotWidth, height: conf.snapshotHeight});
    await page.goto(`${conf.startingDomain}${url}`, {waitUntil: 'networkidle0'});
    if ( !fs.existsSync( `${conf.dir.build}${url}` ) ) {
        mkdir( `${conf.dir.build}${url}` );
    }
    let html = await page.content();
    html = html.replace('</body>',`${conf.htmlToReinject}</body>`);
    console.log(styleSubtitle, `    * ${conf.startingDomain}${url}`);
    const minHtml = html_minifier.minify(html,
        { minifyCSS: true
        , minifyJS: true
        , removeComments: true
        }
    );
    fs.writeFileSync(`${conf.dir.build}${url}/${conf.pagesName}`, minHtml);
    if (conf.snapshots) {
        await page.screenshot(
            { path: `${conf.dir.build}${url}/${conf.snapshotFileName}`
            , quality: conf.snapshotsQuality
            }
        );
    }
    await page.close();
}

function minifyJs (conf, fileName) {
    runTerser(`${conf.dir.build}/${fileName}`);
}

function generateFiles(conf, dest) {
    conf.files.map (function(file) {
        fs.writeFileSync(`${dest}/${file.name}`, file.content);
    });
}

//
//
// UTILITIES
//
//

function consoleDebug (string) {
    if (debugMode) {
        console.log (styleDebug, string);
    }
}

function runHtmlMinifier (fileName) {
    const code = fs.readFileSync(fileName, 'utf8');
    const minCode = html_minifier.minify(code,
        { collapseWhitespace: true
        , minifyCSS: true
        , minifyJS: true
        , removeComments: true
        , removeEmptyAttributes : true
        , removeEmptyElements : true
        , removeAttributeQuotes : true
        , removeOptionalTags : true
        , removeRedundantAttributes : true
        , removeScriptTypeAttributes : true
        , collapseBooleanAttributes : true
        , useShortDoctype : true
        }
    );
    fs.writeFileSync(fileName, minCode);
}

function runTerser (fileName) {
    const code = fs.readFileSync(fileName, 'utf8');
    // TODO - Add special arguments to terser, to optimize pure functions
    const minCode = terser.minify(code);
    if (minCode.error) throw minCode.error;
    fs.writeFileSync(fileName, minCode.code);
}

function startCommand (cmd, parameters, callback) {
    callback = callback || function(){};
    const command = child_process.spawn(cmd, parameters);
    command.stdout.on('data', function (data) { process.stdout.write(data.toString()); });
    command.stderr.on('data', function (data) { process.stdout.write(data.toString()); });
    command.on('close', function(code) {
        return callback(code);
    });
}

function chunkArray(myArray, chunk_size){
    var results = [];
    while (myArray.length) {
        results.push(myArray.splice(0, chunk_size));
    }
    return results;
}

//
//
// DIRECTORY UTILITIES
//
//

function mkdir (path) {
    if (fs.existsSync(path)) {
        // path already exsists
    } else {
        try {
            fs.mkdirSync(path, { recursive: true })
        } catch(e) {
            // error creating dir
        }
    }
}

function symlinkDir (srcDir, dstDir) {
    if (!fs.existsSync(srcDir)) {
        // source directory doesn't exists
        return;
    }
    const list = fs.readdirSync(srcDir);
    var src, dst;
    list.forEach(function(file) {
        src = `${srcDir}/${file}`;
        dst = `${dstDir}/${file}`;
        var stat = fs.lstatSync(src);
        if ( stat && ( stat.isDirectory() || stat.isFile() ) && (file !== ".DS_Store") ) {
            fs.symlinkSync(src, dst);
        }
    });
}

function copyDir (srcDir, dstDir) {
    if (!fs.existsSync(srcDir)) {
        // source directory doesn't exists
        return;
    }
    const files = fs.readdirSync(srcDir);
    files.map( function (file) {
        const src = `${srcDir}/${file}`;
        const dst = `${dstDir}/${file}`;
        const stat = fs.lstatSync(src);
        if (stat && stat.isDirectory()) {
            mkdir(dst);
            copyDir(src, dst);
        } else if ( file !== ".DS_Store" ) {
            try {
                fs.writeFileSync(dst, fs.readFileSync(src));
            } catch(e) {
                console.log(e);
            }
        }
    });
}

function removeDir (srcDir, removeSelf) {
    if (!fs.existsSync(srcDir)) {
        // source directory doesn't exists
        return;
    }
    const files = fs.readdirSync(srcDir);
    files.map(function (file) {
            const src = `${srcDir}/${file}`;
            const stat = fs.lstatSync(src);
            if (stat && stat.isDirectory()) {
                // Calling recursively removeDir
                removeDir(src, true);
            } else {
                fs.unlinkSync(src);
            }
        }
    )
    if (removeSelf) {
        fs.rmdirSync(srcDir);
    }
};
