'use stick';

var gulp = require('gulp');
var gulpMulDest = require('gulp-multi-dest');
var rename = require('gulp-rename');
var fs = require('fs');
var spawn = require('cross-spawn');

var ignoreDirectories = [
    'node_modules'
];

function getProductions() {
    var files = fs.readdirSync('./');

    var dests = [];
    files.forEach(function (file) {
        if (fs.lstatSync(file).isDirectory() && file[0] != '.' && -1 == ignoreDirectories.indexOf(file)) {
            dests.push(file);
        }
    });

    return dests;
}

gulp.task('sync', function () {
    return gulp.src('gulpfile-product-default.js')
        .pipe(rename('gulpfile.js'))
        .pipe(gulpMulDest(getProductions()));
});