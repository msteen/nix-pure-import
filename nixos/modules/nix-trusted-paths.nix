{ lib, ... }:

with lib;

{
  options.nix = with types; {
    trustedPaths = mkOption {
      type = listOf (coercedTo path toString str);
      default = [];
      description = ''
        The paths to which file access is allowed in pure evaluation mode.
      '';
    };
  };
}
