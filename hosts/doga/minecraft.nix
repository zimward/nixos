{
  nixpkgs.allowUnfreePackages = [ "minecraft-server" ];
  services.minecraft-server = {
    enable = true;
    dataDir = "/nix/persist/minecraft";
    eula = true;
    openFirewall = true;
    jvmOpts = "-Xmx4092M -XX:+UseG1GC";
    serverProperties = {
      difficulty = 3;
      gamemode = 1;
      motd = "NixOS Minecraft server!";
    };
  };
}
