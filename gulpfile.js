'use stick';

var args = require('yargs').argv;
var gulp = require('gulp');
var gulpMulDest = require('gulp-multi-dest');
var rename = require('gulp-rename');
var fs = require('fs');
var execa = require('execa');
var jsonReader = require('jsonfile').readFileSync;
var jsonWriter = require('jsonfile').writeFileSync;
var prompt = require('prompt');
var path = require('path');
var mapStream = require('map-stream');
var clean = require('gulp-clean');
var spawn = require('cross-spawn');

var PACKAGE_CONFIG = jsonReader('./package.json');
var syncIgnore = PACKAGE_CONFIG.sync.ignore;
var previewIgnore = [].concat(syncIgnore, PACKAGE_CONFIG.preview.ignore);

function getProductions(rule) {
    var files = fs.readdirSync('./');

    var dests = [];
    files.forEach(function (file) {
        if (fs.lstatSync(file).isDirectory() && file[0] != '.' && -1 == rule.indexOf(file)) {
            dests.push(file);
        }
    });

    return dests;
}

function getSyncDir() {
    return getProductions(syncIgnore);
}

function getPreviewDir() {
    return getProductions(previewIgnore);
}

gulp.task('sync', function () {
    var type = args.f;
    var src = [];
    var files = {
        gulpfile: './Templates/production-directory-example/gulpfile.js.default',
        ignore: './Templates/production-directory-example/.gitignore.default'
    };

    if (type && files.hasOwnProperty(type)) {
        src.push(files[type]);
    } else {
        for (var type in files) {
            if (files.hasOwnProperty(type)) {
                src.push(files[type]);
            }
        }
    }

    return gulp.src(src)
        .pipe(rename(function (path) {
            path.extname = '';
        }))
        .pipe(gulpMulDest(getSyncDir()));
});

gulp.task('init', function (cb) {

    var dest = args.d;

    if (dest && fs.lstatSync(dest).isDirectory()) {
        return Promise.all([
            new Promise(function (resolve, reject) {
                gulp.src([
                    './Templates/production-directory-example/**/*',
                    '!./Templates/production-directory-example/**/.gitignore',
                    '!./Templates/production-directory-example/*.default'
                ])
                    .pipe(gulp.dest(dest))
                    .on('end', resolve);
            }),
            new Promise(function (resolve, reject) {
                gulp.src([
                    './Templates/production-directory-example/{.gitignore,gulpfile.js}.default'
                ])
                    .pipe(rename(function (path) {
                        path.extname = '';
                    }))
                    .pipe(gulp.dest(dest))
                    .on('end', resolve);
            }),
            new Promise(function (resolve, reject) {
                if (fs.existsSync(dest + '/package.json')) {
                    resolve();
                } else {
                    prompt.start();
                    prompt.get({
                        properties: {
                            name: {
                                message: 'Production name',
                                required: true
                            }
                        }
                    }, function (err, result) {
                        if (!err) {
                            var packageJsonContents = jsonReader('./Templates/production-directory-example/package.json.default');
                            if (result.name) {
                                packageJsonContents.description = result.name;
                            }
                            jsonWriter(dest + '/package.json', packageJsonContents, {spaces: '  '});

                            resolve();
                        } else {
                            reject();
                        }
                    });
                }
            })
        ]).then(function () {
            console.log('Installing ...');
            var npm = 'cnpm';
            try {
                execa.shellSync(npm + ' -v');
            } catch (e) {
                npm = 'npm';
            }
            execa.shellSync(['pushd ' + dest, npm + ' install', 'popd'].join(';'));
        });
    }

    console.error('Not a valid directory');
    return Promise.reject();
});

gulp.task('preview-clean', function () {
    return gulp.src('./docs', {read: false})
        .pipe(clean());
});

gulp.task('preview', ['preview-clean'], function () {

    return Promise.all(getPreviewDir().map(function (path) {
        return new Promise(function (resolve, reject) {
            gulp.src(path + '/release/*.{jpg,png,gif}')
                .pipe(gulp.dest('./docs/productions/' + path))
                .on('end', resolve);
        });
    })).then(function () {
        var previewSets = {};
        gulp.src('./docs/productions/*/*')
            .pipe(rename(function (p) {
                var _p = path.join('productions', p.dirname, p.basename + p.extname).split(path.sep).join('/');
                if (!previewSets.hasOwnProperty(p.dirname)) {
                    previewSets[p.dirname] = {
                        name: jsonReader(p.dirname + '/package.json').description,
                        head: null,
                        preview: []
                    };
                }
                if (p.basename == 'AD-Head') {
                    previewSets[p.dirname].head = _p;
                } else {
                    previewSets[p.dirname].preview.push(_p);
                }
            }))
            .pipe(mapStream(function (file, cb) {
                cb();
            }))
            .pipe(gulp.dest('./none'))
            .on('end', function () {
                jsonWriter('./docs/productions.json', previewSets, {spaces: '  '});
            });
    });
});

gulp.task('save', function (cb) {
    spawn.sync('git', ['add', '.'], {stdio: 'inherit'});
    spawn.sync('git', ['commit', '-m', 'update'], {stdio: 'inherit'});
    spawn.sync('git', ['push', 'origin', 'master:master'], {stdio: 'inherit'});
    cb();
});

gulp.task('build', ['build:js', 'build:css', 'build:static']);

gulp.task('build:js', function(){
    return Promise.relsove;
});

gulp.task('build:css', function(){
    return Promise.relsove;
});

gulp.task('build:static', function(){
    return Promise.relsove;
});