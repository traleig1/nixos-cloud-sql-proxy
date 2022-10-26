{
  description = "Run the Google Cloud Platform cloud-sql-proxy as a service";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    {
      nixosModules.cloud-sql-proxy = import ./cloud-sql-proxy.nix;
    };
}
