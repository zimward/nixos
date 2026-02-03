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
    };
    whitelist = {
      user1 = "050ad88c-78da-4c2a-8b30-f6ca9f45c129";
      user2 = "527daba0-faa2-4256-8dcb-8a7f803f8e87";
      user3 = "510f1ed3-3103-41a6-af5a-65c06577fed7";
    };
  };
  systemd.services.minecraft-server.serviceConfig.NetworkNamespacePath = "/run/netns/wg";
}
