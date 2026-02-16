# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelModules = [ "tun" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "intel_pstate=active" "usbcore.autosuspend=-1" "nvidia-drm.modeset=1" ];

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    "net.core.rmem_max" = 67108864;
    "net.core.wmem_max" = 67108864;
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  networking.hostName = "lyzh-nixos-workstation"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
      fcitx5-gtk
    ];
  };

  powerManagement.enable = true;
  # powerManagement.powertop.enable = true;

  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver libva-vdpau-driver libvdpau-va-gl intel-compute-runtime];
  hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.xpadneo.enable = true;
  #hardware.steam-hardware.enable = true;

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.power-profiles-daemon.enable = false;

  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  security.sudo-rs.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_zenhei
    wqy_microhei
    corefonts
    sarasa-gothic  #更纱黑体
    source-code-pro
    hack-font
    fira-code
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lyzh = {
    isNormalUser = true;
    description = "lyzh";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    # packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btrfs-progs
    powertop

    intel-gpu-tools

    vim
    nano
    wget
    curl
    git
    zsh
    vscode
    #code-server

    tailscale
    clash-verge-rev
    #v2raya
    firefox

    tigervnc
    samba

    lutris
    wineWowPackages.stable
    wineWowPackages.staging
    winetricks
    dxvk
    vkd3d-proton
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx"; # 兼容 XWayland 应用
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx"; # 兼容 SDL 应用 (比如一些游戏)
  };
  environment.variables = {
  #  TERMINAL = "kitty";
    RUSTUP_HOME = "\${HOME}/.rustup";
    CARGO_HOME = "\${HOME}/.cargo";
    CC = "clang";
    CXX = "clang++";

    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  # services.blueman.enable = true;
  # services.cloudflare-warp.enable = true;
  services.tailscale.enable = true;
  services.v2raya.enable = true;
  services.mihomo.webui = pkgs.metacubexd;

  programs.clash-verge = {
    enable = true;
    autoStart = true;
    serviceMode = true;
    tunMode = true;
  };

  programs.zsh.enable = true;
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;
  programs.thunar.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = "/etc/nix/cache-keys/secret.key";
    # port = 5000;
  };

  services.samba = {
    enable = true;
    nmbd.enable = true;
    settings = {
      public = {
        browseable = "yes";
        comment = "Public samba share.";
        path = "/home/lyzh/Documents";
        "guest ok" = "yes";
        "read only" = "yes";
      };
    };
  };


  # Open ports in the firewall.
  # Krfb
  # networking.firewall.allowedTCPPorts = [ 5900 3389 139 445 ];
  # networking.firewall.allowedUDPPorts = [ 137 138 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;


  services.resolved.enable = false;
  services.smartdns = {
    enable = true;
    settings = {
      dualstack-ip-selection = "yes";
      speed-check-mode = "ping,tcp:80";

      server-https = [
        "https://dns.alidns.com/dns-query"
        "https://doh.pub/dns-query"
      ];

      server = [
        "223.5.5.5"
        "119.29.29.29"
        "114,114,114,114"
      ];

      # domain-rules = [
      #   "/battle.net/ -speed-check-mode tcp:80"
      #   "/blizzard.com/ -speed-check-mode tcp:80"
      # ];
    };
  };

  networking.nameservers = [ "127.0.0.1" ];
  networking.networkmanager.dns = "none";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  home-manager.backupFileExtension = "backup";
}
