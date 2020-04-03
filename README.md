# A less restrictive pure Nix evaluation through the scoped import builtin

Very much a work in progress, but this project aims to support the same kind of restrictions as the `--pure-eval` flag does, without requiring all paths to be within the Nix store. Instead you can list the roots you deem safe yourself.
