# This reverse engineers the --pure-eval flag to still allow specified root directories considered pure.
# See: https://github.com/NixOS/nix/commit/d4dcffd64349bb52ad5f1b184bee5cc7c2be73b4
let
  pureBuiltins =
    # The builtins currentTime, currentSystem and storePath throw an error.
    builtins // builtins.listToAttrs (map (name: {
      inherit name;
      value = throw "builtins.${name} is not allowed in pure evaluation mode";
    }) [
      "currentSystem"
      "currentTime"
      "storePath"
    ]) // {
      # The builtins fetchGit and fetchMercurial require a rev attribute.
      fetchGit = args@{ rev, ... }: builtins.fetchGit args;
      fetchMercurial = args@{ rev, ... }: builtins.fetchMercurial args;

      # The builtins fetchurl and fetchTarball require a sha256 attribute.
      fetchurl = args@{ sha256, ... }: builtins.fetchurl args;
      fetchTarball = args@{ sha256, ... }: builtins.fetchTarball args;

      getEnv = name: "";
    };

in {
  builtins = pureBuiltins;
  inherit (pureBuiltins) fetchTarball;

  # $NIX_PATH and -I are ignored.
  __nixPath = builtins.filter (x: x.prefix == "nix") __nixPath;
}
