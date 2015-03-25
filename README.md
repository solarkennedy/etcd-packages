etcd-packages
=============

A makefile to download etcd and make a package out of it.

For debain & ubuntu based systems an init script and basic config is included in the deployed package.

For rpm based systems the created package is very basic.

## Requirements

The ever so handy [fpm](https://github.com/jordansissel/fpm)

## Usage

    make deb

or

    ITERATION=custom2 make deb

