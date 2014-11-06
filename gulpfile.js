var coffee = require('coffee-script/register');
var gulp = require('gulp');
var mocha = require('gulp-mocha');
var error = require('./gulp-error');

var paths = {
	scripts: [ 'src/*.coffee' ],
	tests: [ 'test/spec/*.spec.js', 'test/spec/*.spec.coffee' ],
};

gulp.task('test', function () {
	return gulp.src(paths.tests, {read: false})
		.pipe(mocha({reporter: 'xunit', compilers: 'coffee:coffee-script'}))
		// .on('error', function(err) {
		// 	error.catchError(this, err);
		// });
});

gulp.task('test:dev', function () {
	return gulp.src(paths.tests, {read: false})
		.pipe(mocha({reporter: 'nyan', compilers: 'coffee:coffee-script'}))
});

// Rerun the task when a file changes
gulp.task('watch', [ ], function(stream) {
	gulp.watch(paths.scripts.concat(paths.tests), [ 'test:dev' ]);
});

gulp.on('stop', function(obj) {
	if (error.hasErrors()) {
		error.getErrors();
	}
});
