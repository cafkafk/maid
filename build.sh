#!/usr/bin/env sh
stack build --nix --compiler ghc-9.0.2
stack install --nix --compiler ghc-9.0.2
