{config, lib, pkgs, ...}: let
  inherit (builtins) toString length isNull;
  inherit (lib) mkEnableOption mkIf mkOption mdDoc;

  removeEmpty = builtins.filter (x: builtins.stringLength x > 0);
  sepWith = sep: list: builtins.concatStringsSep sep (removeEmpty list);

  desc = "Google Cloud SQL Proxy";
  cfg = config.programs.cloud-sql-proxy;
in {
  options.programs.cloud-sql-proxy = {
    enable = mkEnableOption desc;

    instances = mkOption {
      type = with lib.types; listOf string;
      default = [];
      example = [ "myproject:myregion:myinstance=tcp:5432" ];
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
    environment.systemPackages = [ pkgs.cloud-sql-proxy ];
    systemd.services.cloud-sql-proxy = {
      description = desc;
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after    = [ "network.target" ];
      restartIfChanged = true;
      serviceConfig = {
        Restart = "always";
        StandardOutput = "journal";
        ExecStart = sepWith " " [
          "${pkgs.cloud-sql-proxy}/bin/cloud_sql_proxy"
          "-dir=/var/run/cloud-sql-proxy"
          "-instances=${sepWith "," cfg.instances}"
          (if isNull cfg.credentials then "" else "-credential_file=${toString cfg.credentials}")
        ];
      };
    };
  };
}
