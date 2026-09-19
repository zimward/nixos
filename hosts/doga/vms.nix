{
  inputs,
  pkgs,
  config,
  ...
}:
{
  config =
    let
      vmLib = import inputs.domUnix { inherit pkgs; };
      xenCfg = config.virtualisation.xen;
    in
    {
      # autostart ethercalc vm
      systemd.services.ethervm = {
        enable = true;
        path = [
          xenCfg.package
          xenCfg.qemu.package
        ];
        requires = [
          "proc-xen.mount"
          "xenstored.service"
          "network-online.target"
        ];
        after = [
          "proc-xen.mount"
          "xenstored.service"
          "xenconsoled.service"
          "xen-init-dom0.service"
          "network-online.target"
          "remote-fs.target"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig =
          let

            ethervmCfg = vmLib.mkXenConfig "ethervm";
            cfg = {
              cmdline = "init=/nix/store/dzllb0q2n7j253y2z10fmbqc4cn4jdwa-nixos-system-ethercalc-25.11pre-git/init console=hvc0";
              disk = [
                "format=raw,vdev=xvda,access=r,target=/nix/persist/ethervm/store.erofs"
                "format=qcow2,vdev=xvdb,access=rw,target=/nix/persist/ethervm/persist.qcow2"
              ];
              kernel = "/nix/persist/ethervm/bzImage";
              ramdisk = "/nix/persist/ethervm/initrd";
              maxmem = 1024;
              memory = 512;
              name = "ethercalc";
              serial = "pty";
              type = "pvh";
              vcpus = 1;
              vif = [ "mac=00:16:3e:23:eb:cc,bridge=virbr0" ];
              on_xend_start = "start";
              on_xend_stop = "shutdown";
              on_reboot = "restart";
            };
          in
          {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.xen}/bin/xl create ${ethervmCfg cfg}";
            ExecStop = "${pkgs.xen}/bin/xl shutdown -w ${cfg.name}";
          };
      };

      virtualisation.xen.domains.extraConfig = ''
        XENDOMAINS_RESTORE=false
      '';
    };
}
