const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = (env, options) => {
  const isProduction = options.mode === 'production';

  const config = {
    entry: './src/main.ts',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProduction ? 'js/[name].[contenthash].js' : 'js/[name].js',
      chunkFilename: isProduction ? 'js/[name].[contenthash].js' : 'js/[name].js',
    },
    resolve: {
      extensions: ['.ts', '.js'],
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
        {
          test: /\.scss$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            'sass-loader',
          ],
        },
      ],
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: './src/index.html',
        minify: isProduction
          ? {
              removeComments: true,
              collapseWhitespace: true,
              removeRedundantAttributes: true,
              useShortDoctype: true,
              removeEmptyAttributes: true,
              removeStyleLinkTypeAttributes: true,
              keepClosingSlash: true,
              minifyJS: true,
              minifyCSS: true,
              minifyURLs: true,
            }
          : false,
      }),
      new MiniCssExtractPlugin({
        filename: isProduction ? 'css/[name].[contenthash].css' : 'css/[name].css',
      }),
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify(options.mode),
      }),
      new CompressionPlugin({
        test: /\.(js|css)$/,
        algorithm: 'gzip',
        filename: '[path][base].gz',
        threshold: 8192,
        minRatio: 0.8,
      }),
      new ModuleFederationPlugin({
        name: 'yourAppName',
        library: { type: 'var', name: 'yourAppName' },
        filename: 'remoteEntry.js',
        exposes: {
          './YourComponent': './src/app/your-component/your-component.component.ts',
        },
        shared: {
          '@angular/core': { singleton: true, requiredVersion: '^12.0.0' },
          '@angular/common': { singleton: true, requiredVersion: '^12.0.0' },
          '@angular/router': { singleton: true, requiredVersion: '^12.0.0' },
        },
      }),
    ],
    optimization: {
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            output: {
              comments: false,
            },
          },
          extractComments: false,
        }),
        new OptimizeCSSAssetsPlugin({}),
      ],
    },
  };

  if (isProduction) {
    // Additional production-specific configurations if needed
    // config.plugins.push(new SomeProductionPlugin());
  } else {
    // Additional development-specific configurations if needed
    // config.plugins.push(new SomeDevelopmentPlugin());
  }

  return config;
};
