{config, lib, pkgs, ...}: let
  inherit (builtins) toString length isNull;
  inherit (lib) mkEnableOption mkIf mkOption mdDoc;

  removeEmpty = builtins.filter (x: builtins.stringLength x > 0);
  sepWith = sep: list: builtins.concatStringsSep sep (removeEmpty list);

  desc = "Google Cloud SQL Proxy";
  cfg = config.services.cloud-sql-proxy;
in {
  options.services.cloud-sql-proxy = {
    enable = mkEnableOption desc;

    instances = mkOption {
      type = with lib.types; listOf str;
      default = [];
      example = [ "myproject:myregion:myinstance?port=5432" ];
      description = mdDoc ''
        A list of instance strings, as described here:
        https://cloud.google.com/sql/docs/mysql/connect-admin-proxy
      '';
    };

    credentials = mkOption {
      type = with lib.types; nullOr path;
      example = /etc/nixos/credentials.json;
    };

  };
  config = mkIf (cfg.enable && length cfg.instances > 0) {
    environment.systemPackages = [ pkgs.google-cloud-sql-proxy ];
    systemd.services.cloud-sql-proxy = {
      description = desc;
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after    = [ "network.target" ];
      restartIfChanged = true;
      serviceConfig = let 
        executable = "${pkgs.google-cloud-sql-proxy}/bin/cloud-sql-proxy";
        flags = [
          "--unix-socket /var/run/cloud-sql-proxy"
          (if isNull cfg.credentials then "" else "--credentials-file ${toString cfg.credentials}")
        ];
      in {
        Restart = "always";
        StandardOutput = "journal";
        ExecStart = sepWith " " [executable (sepWith " " cfg.instances) (sepWith " " flags)];
      };
    };
  };
}
