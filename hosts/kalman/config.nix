{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filter-chain-siberia.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = {
    device.class = "desktop";
    #gets wiped due to tmpfs
    mainUser.hashedPassword = "$6$qMlVwZLXPsEw1yMa$DveNYjYb8FO.bJXuNbZIr..Iylt4SXsG3s4Njp2sMVokhEAr0E66WsMm.uNPUXsuW/ankujT19cL6vaesmaN9.";

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/nix/persist/system/var/lib/sbctl/";
    };

    environment.persistence."/nix/persist/system" = {
      directories = [
        "/var/lib/sbctl"
        "/root/.ssh"
        "/var/lib/private"
      ];
    };

    networking.hostName = "kalman";
    ethernet.share.device = "enp39s0";
    ethernet.share.addr = [ "192.168.9.1/24" ];

    virtualisation.libvirtd = {
      enable = true;
      #user mode networking
      allowedBridges = [ "virbr0" ];
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
    users.users."zimward".extraGroups = [
      "libvirtd"
      "dialout"
    ];

    #usb controller bootloaders
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{product}=="USBasp", ATTR{idProduct}=="05dc", ATTRS{idVendor}=="16c0", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="4348", ATTRS{idProduct}=="55e0", GROUP="dialout"
    '';
    hardware.opentabletdriver.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    # since no services are supposed to run on this machine a firewall would only wase memory
    networking.firewall.enable = false;

    graphical.niri.enable = true;
    programs.niri.package =
      (config.graphical.niri.wrapper.apply {
        settings = {
          binds = {
            "Mod+Y".spawn = [
              #can't use the wrapped package as that is a infrec
              (lib.getExe pkgs.niri)
              "msg"
              "output"
              "DP-3"
              "transform"
              "90"
            ];
            "Mod+Shift+Y".spawn = [
              (lib.getExe pkgs.niri)
              "msg"
              "output"
              "DP-3"
              "transform"
              "normal"
            ];

          };

          workspaces = {
            "com" = {
              open-on-output = "DP-3";
            };
            "games" = {
              open-on-output = "DP-3";
            };
            "browser-l" = {
              open-on-output = "DP-3";
            };
            "browser-r" = {
              open-on-output = "DP-1";
            };
          };

          window-rules = [
            {
              matches = [
                { app-id = "thunderbird"; }
              ];
              open-on-workspace = "com";
            }
            {
              matches = [
                { app-id = "steam"; }
                { app-id = "org.prismlauncher.PrismLauncher"; }
              ];
              open-on-workspace = "games";
            }

            {
              matches = [
                { app-id = "info.mumble.Mumble"; }
              ];
              open-on-workspace = "browser-r";
            }
            {
              matches = [
                { app-id = "FreeTube"; }
              ];
              open-on-workspace = "browser-r";
            }
            {
              matches = [ { app-id = "librewolf"; } ];
              open-on-workspace = "browser-l";
            }
          ];

        };
      }).wrapper;

    graphical.steam.enable = true;
    graphical.deluge.enable = true;
    graphical.minecraft.enable = true;
    specialisation.arbeit.configuration = {
      graphical.steam.enable = lib.mkForce false;
      graphical.deluge.enable = lib.mkForce false;
      graphical.minecraft.enable = lib.mkForce false;
      graphical._freetime = false;
    };
    graphical.ime.enable = true;
    graphical.matlab.enable = true;

    services.nextjs-ollama-llm-ui = {
      enable = true;
    };
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "10.3.0";
        OLLAMA_KEEP_ALIVE = "15m";
      };
    };
    devel.helix.package =
      (config.devel.helix.wrapper.apply {
        languages = {
          language-server.lsp-ai = {
            command = lib.getExe pkgs.lsp-ai;
            timeout = 300;
            config = {
              memory = {
                file_store = { };
              };
              models = {
                qwen = {
                  type = "ollama";
                  model = "qwen3-quant";
                };
              };
              actions = [
                {
                  action_display_name = "Complete";
                  model = "qwen";
                  parameters = {
                    fim = {
                      start = "<|fim_prefix|>";
                      middle = "<|fim_suffix|>";
                      end = "<|fim_middle|>";
                    };
                  };
                }
                {
                  action_display_name = "Code from comment";
                  model = "qwen";
                  parameters = {
                    messages = [
                      {
                        role = "system";
                        content = builtins.readFile ./cfc.md;
                      }
                      {
                        role = "user";
                        content = ''
                          <context>
                          {CODE}
                          </context>
                          <input>
                          {SELECTED_TEXT}
                          </input>
                        '';
                      }
                    ];
                  };
                  post_process = {
                    extractor = "(?s)<answer>(.*?)</answer>";
                  };
                }
                {
                  action_display_name = "Code from comment (thinking)";
                  model = "qwen";
                  parameters = {
                    messages = [
                      {
                        role = "system";
                        content = lib.strings.concatLines [
                          (builtins.readFile ./cfc.md)
                          (builtins.readFile ./cot.md)
                        ];
                      }
                      {
                        role = "user";
                        content = ''
                          <context>
                          {CODE}
                          </context>
                          <input>
                          {SELECTED_TEXT}
                          </input>
                        '';
                      }
                    ];
                  };
                  post_process = {
                    extractor = "(?s)<answer>(.*?)</answer>";
                  };
                }
              ];
            };
          };
          language =
            (map
              (name: {
                inherit name;
                language-servers = [ "lsp-ai" ];
              })
              [
                "matlab"
                "python"
              ]
            )
            ++ [
              {
                name = "rust";
                language-servers = [
                  "rust-analyzer"
                  "lsp-ai"
                ];
              }
              {
                name = "nix";
                language-servers = [
                  "nixd"
                  "lsp-ai"
                ];
              }
            ];
        };
      }).wrapper;

    environment.systemPackages = with pkgs; [
      freecad
      prusa-slicer
      sbctl
      ghidra
      #needed for tpm support to function in virt-manager
      swtpm
    ];

    systemd.network.networks."10-lan" = {
      matchConfig.Name = "enp35s0f*";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DHCPPrefixDelegation = true;
      };
      linkConfig = {
        MTUBytes = 9000;
      };
    };

    nix.settings.substituters = [
      "http:192.168.0.1:5000"
    ];
    nix.settings.trusted-public-keys = [
      "doga:y1nuiJdAESNfSTOJz+pna+PoCtNe/cvVUddkD2jAsmI="
    ];

    services.scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopilot" ];
    };
  };
}
