{
  projectRootFile = "flake.nix";
  programs = {
    alejandra.enable = true; # nix
    ormolu.enable = true; # Haskell
    #rustfmt.enable = true; # rust
    #shellcheck.enable = true; # bash/shell
    #deadnix.enable = true; # find dead nix code
    #taplo.enable = true; # toml
    #yamlfmt.enable = true; # yaml
  };
  #settings = {
  # formatter.ormolu.includes = ["*.hs" "./config/xmonad/*"];
  # formatter.ormolu.includes = ["*.hs"  };
}
