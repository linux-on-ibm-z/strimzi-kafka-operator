#!/usr/bin/env bash
cd $HOME
wget https://downloads.haskell.org/~cabal/cabal-install-2.0.0.1/cabal-install-2.0.0.1.tar.gz
tar -xvf cabal-install-2.0.0.1.tar.gz
cd cabal-install-2.0.0.1
./bootstrap.sh

export PATH=$HOME/.cabal/bin:$PATH
cabal --version
cabal update

cd $HOME
git clone https://github.com/koalaman/shellcheck.git
cd shellcheck/
git checkout v0.7.2
cabal install
cabal test
shellcheck --version
