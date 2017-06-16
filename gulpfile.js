'use stick';

var args = require('yargs').argv;
var gulp = require('gulp');
var gulpMulDest = require('gulp-multi-dest');
var rename = require('gulp-rename');
var fs = require('fs');
var spawn = require('cross-spawn');
var jsonReader = require('jsonfile').readFileSync;

var ignoreDirectories = jsonReader('./package.json');

function getProductions() {
    var files = fs.readdirSync('./');

    var dests = [];
    files.forEach(function (file) {
        if (fs.lstatSync(file).isDirectory() && file[0] != '.' && -1 == ignoreDirectories.sync.ignore.indexOf(file)) {
            dests.push(file);
        }
    });

    return dests;
}

gulp.task('sync', function () {
    var type = args.f;
    switch (type) {
        case 'gulpfile':
            return gulp.src('./Templates/production-directory-example/gulpfile.js')
                .pipe(gulpMulDest(getProductions()));
        case 'ignore':
            return gulp.src('./Templates/production-directory-example/.gitignore')
                .pipe(gulpMulDest(getProductions()));
    }
});

gulp.task('init', function () {

    var dest = args.d;

    if (dest && fs.lstatSync(dest).isDirectory()) {
        return gulp.src('./Templates/production-directory-example/**/*')
            .pipe(gulp.dest(dest));
    }

    console.error('Not a valid directory');

    return false;
});