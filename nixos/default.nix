let
  maybeEnv = name: default:
    let value = builtins.getEnv name;
    in if value != "" then value else default;
in

{ configuration ? maybeEnv "NIXOS_CONFIG" <nixos-config>
, system ? builtins.currentSystem
, nixpkgsPath ? <nixpkgs>
}:

let
  nixosArgs = { inherit configuration system; };

  trustedPaths = [ /nix/store nixpkgsPath ]
    ++ (import (nixpkgsPath + "/nixos") nixosArgs).config.nix.trustedPaths;

  ensureTrustedPath = f: path:
    let pathStr = toString path;
    in if builtins.any (trustedPath: hasPrefix trustedPath pathStr) trustedPaths then f path
    else throw "file '${pathStr}' is outside one of the paths to which file access is allowed in pure evaluation mode";

  scope = import ../scope.nix // {
    hashFile = type: ensureTrustedPath (hashFile type);
    import = ensureTrustedPath pureImport;
    path = ensureTrustedPath path;
    pathExists = ensureTrustedPath pathExists;
    readDir = ensureTrustedPath readDir;
    readFile = ensureTrustedPath readFile;
  };

in scopedImport scope (nixpkgsPath + "/nixos") nixosArgs
