/* eslint-disable @typescript-eslint/no-require-imports */
module.exports = {

  plugins: [
    require('autoprefixer'),

    require('doiuse')({
      browsers: ['last 3 versions', 'not dead'],
      ignore: ['rem'], // an optional array of features to ignore
      ignoreFiles: ['**/normalize.css'] // an optional array of file globs to match against original source file path, to ignore

    })
  ],


};
