{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.ovn;
  ovn = pkgs.ovn;
  ovs = pkgs.openvswitch;

  ovsdb = name: schema: port: {
    description = "OVN ${name} database";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ ovs ];
    preStart = ''
      [ -e /var/lib/ovn/${name}.db ] || \
        ovsdb-tool create /var/lib/ovn/${name}.db ${ovn}/share/ovn/${schema}
    '';
    serviceConfig = {
      StateDirectory = "ovn";
      RuntimeDirectory = "ovn";
      RuntimeDirectoryPreserve = true;
      ExecStart = "${ovs}/bin/ovsdb-server /var/lib/ovn/${name}.db"
        + " --remote=punix:/run/ovn/${name}.sock"
        + " --remote=ptcp:${toString port}:127.0.0.1"
        + " --unixctl=/run/ovn/${name}.ctl";
      Restart = "on-failure";
    };
  };
in
{
  options.modules.services.ovn = {
    enable = mkEnableOption "single-node OVN for Incus";
  };

  config = mkIf cfg.enable {
    virtualisation.vswitch.enable = true;

    environment.systemPackages = [ ovn ];

    # Incus shells out to ovs-vsctl and ovn-nbctl
    systemd.services.incus.path = [ ovn ovs ];

    systemd.services.ovn-nb-db = ovsdb "ovnnb_db" "ovn-nb.ovsschema" 6641;
    systemd.services.ovn-sb-db = ovsdb "ovnsb_db" "ovn-sb.ovsschema" 6642;

    systemd.services.ovn-northd = {
      description = "OVN northd";
      wantedBy = [ "multi-user.target" ];
      requires = [ "ovn-nb-db.service" "ovn-sb-db.service" ];
      after = [ "ovn-nb-db.service" "ovn-sb-db.service" ];
      serviceConfig = {
        ExecStart = "${ovn}/bin/ovn-northd"
          + " --ovnnb-db=unix:/run/ovn/ovnnb_db.sock"
          + " --ovnsb-db=unix:/run/ovn/ovnsb_db.sock";
        Restart = "on-failure";
      };
    };

    systemd.services.ovn-controller = {
      description = "OVN controller";
      wantedBy = [ "multi-user.target" ];
      requires = [ "ovs-vswitchd.service" "ovn-sb-db.service" ];
      after = [ "ovs-vswitchd.service" "ovn-sb-db.service" ];
      path = [ ovs ];
      # Compiled-in default is /usr/local/var/run/openvswitch
      environment.OVS_RUNDIR = "/run/openvswitch";
      preStart = ''
        ovs-vsctl set open_vswitch . \
          external-ids:system-id=${"$"}(cat /etc/machine-id) \
          external-ids:ovn-remote=tcp:127.0.0.1:6642 \
          external-ids:ovn-encap-type=geneve \
          external-ids:ovn-encap-ip=127.0.0.1
      '';
      serviceConfig = {
        ExecStart = "${ovn}/bin/ovn-controller unix:/run/openvswitch/db.sock";
        Restart = "on-failure";
      };
    };
  };
}
