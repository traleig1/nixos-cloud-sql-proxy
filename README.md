### Google Cloud SQL Proxy NixOS Module

This flake provides a NixOS module, using the existing `cloud-sql-proxy` in nixpkgs, to allow for easily running the proxy as a systemd service.

If you've followed the instructions [here](https://nixos.wiki/wiki/Flakes#Using_nix_flakes_with_NixOS) to build your NixOS system with flakes, you should be able to include this flake, and add something like the following to your configuration:

```
services.cloud-sql-proxy = {
  enable = true;
  credentials = /home/me/credentials.json;
  instances = [ "myproject:myregion:myinstance?port=5432" ];
};
```
