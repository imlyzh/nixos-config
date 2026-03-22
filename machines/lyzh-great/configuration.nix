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
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelModules = [ "intel_hfi" "intel_vsec" "intel_hid" "soc_button_array" "xe" "tun" "tcp_bbr" ];
  boot.kernelParams = [
    # "intel_pstate=active"
    "intel_hfi=on"

    "iwlwifi.power_save=0" 
    # "pcie_aspm=off"

    "xe.enable_psr=0"

    "intel_iommu=on"
    # "iommu=pt"

    "usbcore.autosuspend=-1"
  ];
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";

    "vm.max_map_count" = 2147483642;
  };

  systemd.oomd.enable = false;

  networking.hostName = "lyzh-great"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      rime
    ];
  };
  # environment.sessionVariables = {
  #   INPUT_METHOD = "ibus";
  #   SDL_IM_MODULE = "ibus";
  #   GLFW_IM_MODULE = "ibus";
  # };

  # i18n.inputMethod = {
  #   enable = true;
  #   type = "fcitx5";
  #   fcitx5.addons = with pkgs; [
  #     fcitx5-rime
  #     qt6Packages.fcitx5-chinese-addons
  #     qt6Packages.fcitx5-configtool
  #     fcitx5-gtk
  #   ];
  # };
  # environment.sessionVariables = {
  #   INPUT_METHOD = "fcitx";
  #   SDL_IM_MODULE = "fcitx";
  #   GLFW_IM_MODULE = "fcitx";
  # };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver vpl-gpu-rt intel-compute-runtime libvdpau-va-gl ];
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.xpadneo.enable = true;
  hardware.sensor.iio.enable = true;

  zramSwap.enable = true;

  # services.udev.extraRules = ''
  #   ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{power/control}="on"
  # '';
  # powerManagement.resumeCommands = ''
  #   ${pkgs.systemd}/bin/systemctl restart fprintd
  # '';
  powerManagement.enable = true;

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.irqbalance.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = { governor = "powersave"; energy_performance_preference = "power"; turbo = "never"; };
  #   charger = { governor = "performance"; energy_performance_preference = "performance"; turbo = "always"; };
  # };

  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  # services.displayManager.sddm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "gnome";

  programs.ssh.askPassword = "${pkgs.zenity}/bin/zenity";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    options = "caps:escape";
    variant = "";
  };

  # services.xrdp.enable = true;

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
  services.libinput.enable = true;
  services.fprintd.enable = true;
  security.sudo-rs.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.libfido2
    pkgs.yubikey-personalization
  ];

  security.pam.services = {
    # login.fprintAuth = true;
    sudo.fprintAuth = true;
    # lightdm.fprintAuth = true; # lightdm
    gdm.fprintAuth = true;    # GNOME
    # sddm.fprintAuth = true;   # KDE (Plasma)
    polkit-1.fprintAuth = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lyzh = {
    isNormalUser = true;
    description = "lyzh";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "input" ];
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

    libva-utils
    nvtopPackages.intel

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

    # breeze-icons
    adwaita-icon-theme
    hicolor-icon-theme

    gnomeExtensions.xremap

    lutris
    wineWowPackages.stable
    wineWowPackages.staging
    winetricks
    dxvk
    vkd3d-proton

    mangohud

    rnote
    openboard
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables = {
    TERMINAL = "ghostty";
    RUSTUP_HOME = "\${HOME}/.rustup";
    CARGO_HOME = "\${HOME}/.cargo";
    CC = "clang";
    CXX = "clang++";
  };

#   services.xremap = {
#     enable = true;
#     withGnome = true;
#     # withKde = true;
#     # withX11 = true;

#   yamlConfig = ''
# keymap:
#   - name: "macOS 核心快捷键 (使用物理 Alt 键模拟 Cmd)"
#     remap:
#       # ================= 基础编辑 =================
#       Alt-c: C-c       # 大拇指 Alt+C -> 发送 Ctrl+C (复制)
#       Alt-v: C-v       # 大拇指 Alt+V -> 发送 Ctrl+V (粘贴)
#       Alt-x: C-x       # 剪切
#       Alt-z: C-z       # 撤销
#       Alt-Shift-z: C-Shift-z # 重做
#       Alt-a: C-a       # 全选
#       Alt-s: C-s       # 保存
#       Alt-f: C-f       # 查找
#       Alt-p: C-p       # 打印

#       # ================= 窗口与标签页 =================
#       Alt-w: C-w       # 关闭当前标签页
#       Alt-t: C-t       # 新建标签页
#       Alt-n: C-n       # 新建窗口
#       Alt-q: Alt-F4    # 退出程序 (完美复刻 Cmd+Q！)

#       # ================= 文本光标移动 (Mac 灵魂) =================
#       Alt-left: Home        # Cmd+左 -> 跳到行首
#       Alt-right: End        # Cmd+右 -> 跳到行尾
#       Alt-up: C-Home        # Cmd+上 -> 跳到文档开头
#       Alt-down: C-End       # Cmd+下 -> 跳到文档结尾

#       # ================= 按单词跳跃 (Mac 里的 Option 键) =================
#       # 在 PC 键盘上，Win 键的位置恰好对应 Mac 的 Option 键
#       Super-left: C-left    # Win+左 -> 按单词向左跳
#       Super-right: C-right  # Win+右 -> 按单词向右跳

#   - name: "终端特例 (保护终端的进程终止功能)"
#     application:
#       # ⚠️ 注意：填入你真实使用的终端名字
#       only: [gnome-terminal, ghostty, kitty, alacritty, konsole, wezterm, foot]
#     remap:
#       # 在终端里，大拇指按 Alt+C 发送 Ctrl+Shift+C (复制)
#       # 小拇指按真正的 Ctrl+C 依然会原样传递给终端 (终止进程)
#       Alt-c: C-Shift-c
#       Alt-v: C-Shift-v
#       Alt-t: C-Shift-t
#       Alt-w: C-Shift-w
#   '';
#   };

  services.tailscale.enable = true;
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
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  # programs.mangohud.enable = true;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  home-manager.backupFileExtension = "backup";
}
