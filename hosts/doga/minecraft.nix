{
  nixpkgs.allowUnfreePackages = [ "minecraft-server" ];
  services.minecraft-server = {
    enable = true;
    dataDir = "/nix/persist/minecraft";
    eula = true;
    openFirewall = true;
    jvmOpts = "-Xmx4092M -XX:+UseG1GC";
    declarative = true;
    serverProperties = {
      difficulty = 3;
      gamemode = 0;
      motd = "NixOS Minecraft server!";
      white-list = true;
    };
    whitelist = {
      user1 = "050ad88c-78da-4c2a-8b30-f6ca9f45c129";
      user2 = "527daba0-faa2-4256-8dcb-8a7f803f8e87";
      user3 = "510f1ed3-3103-41a6-af5a-65c06577fed7";
    };
  };
  containers = {
    niriot = {
      autoStart = true;
      ephemeral = true;
      bindMounts = {
        "/minecraft-niri" = {
          hostPath = "/nix/persist/minecraft-niri";
          isReadOnly = false;
        };
      };

      config =
        { modulesPath, lib, ... }:
        {
          imports = [ "${modulesPath}/profiles/minimal.nix" ];
          config = {
            nixpkgs.config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "minecraft-server"
              ];
            services.minecraft-server = {
              enable = true;
              dataDir = "/minecraft-niri";
              eula = true;
              openFirewall = true;
              jvmOpts = "-Xmx4092M -XX:+UseG1GC";
              declarative = true;
              serverProperties = {
                server-port = 25566;
                difficulty = 3;
                gamemode = 0;
                motd = "NixOS Minecraft server for niri-offtopic";
              };
            };
            networking.firewall.enable = false;
            system.stateVersion = "26.05";
          };
        };
    };
  };
  networking.firewall.allowedTCPPorts = [ 25566 ];
  networking.firewall.allowedUDPPorts = [ 25566 ];
}
