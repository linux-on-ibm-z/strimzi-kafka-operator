#!/usr/bin/env bash

export PATH=$HOME/.cabal/bin:$PATH
cabal --version
cabal update

git clone -b v0.7.2 https://github.com/koalaman/shellcheck.git && cd shellcheck
cabal install && cabal test
