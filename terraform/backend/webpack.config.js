const path = require('path');
const nodeExternals = require('webpack-node-externals');
const webpack = require('webpack');

module.exports = {
  entry: './index.js', // Make sure your source file uses require/module.exports
  target: 'node18',     // Important for AWS Lambda
  mode: 'production',
  output: {
    filename: 'index.js',
    path: path.resolve(__dirname, 'dist'),
    libraryTarget: 'commonjs2'  // This is what Lambda wants
  },
  // externals: [
  //   nodeExternals({ allowlist: ['pg', 'pg-types', 'postgres-array', 'postgres-date'] })
  // ],
  resolve: {
    extensions: ['.js'],
  },
  plugins: [
    new webpack.IgnorePlugin({ resourceRegExp: /^pg-native$/ }),
    new webpack.IgnorePlugin({ resourceRegExp: /^pg-cloudflare$/ })
  ]
};
