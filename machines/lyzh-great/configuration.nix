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
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelModules = [ "intel_hfi" "intel_vsec" "intel_hid" "soc_button_array" "xe" "tun" "tcp_bbr" ];
  boot.kernelParams = [
    "intel_pstate=active"
    "intel_hfi=on"
    "threadirqs"
    "irqaffinity=4-7"
    "rcu_nocbs=0-3"
    "usbcore.autosuspend=-1"
  ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

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

  powerManagement.enable = true;
  # powerManagement.resumeCommands = ''
  #   ${pkgs.systemd}/bin/systemctl restart fprintd
  # '';
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{power/control}="on"
  '';

  services.irqbalance.enable = false;
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  # services.scx.scheduler = "scx_bpfland";
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

  programs.ssh.askPassword = "${pkgs.zenity}/bin/zenity";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
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

    NIXOS_OZONE_WL = "1";
  };

  services.xremap = {
    enable = true;
    withGnome = true;
    # withKde = true;
    # withX11 = true;

  yamlConfig = ''
    keymap:
      - name: "macOS 核心快捷键 (Command 转 Ctrl)"
        remap:
          # ================= 基础编辑 =================
          Super-c: C-c       # 复制 (Cmd+C -> Ctrl+C)
          Super-v: C-v       # 粘贴 (Cmd+V -> Ctrl+V)
          Super-x: C-x       # 剪切 (Cmd+X -> Ctrl+X)
          Super-z: C-z       # 撤销 (Cmd+Z -> Ctrl+Z)
          Super-Shift-z: C-Shift-z # 重做 (Cmd+Shift+Z -> Ctrl+Shift+Z)
          Super-a: C-a       # 全选 (Cmd+A -> Ctrl+A)
          Super-f: C-f       # 查找 (Cmd+F -> Ctrl+F)
          Super-s: C-s       # 保存 (Cmd+S -> Ctrl+S)
          Super-p: C-p       # 打印 (Cmd+P -> Ctrl+P)
          Super-o: C-o       # 打开 (Cmd+O -> Ctrl+O)

          # ================= 窗口与标签页 =================
          Super-w: C-w       # 关闭当前标签页 (Cmd+W -> Ctrl+W)
          Super-t: C-t       # 新建标签页 (Cmd+T -> Ctrl+T)
          Super-n: C-n       # 新建窗口 (Cmd+N -> Ctrl+N)
          Super-r: C-r       # 刷新 (Cmd+R -> Ctrl+R)
          Super-q: Alt-F4    # 退出程序 (Cmd+Q -> Alt+F4，Linux通用退出)

          # ================= 文本光标移动 (Mac 灵魂) =================
          Super-left: Home        # Cmd+左 -> 跳到行首
          Super-right: End        # Cmd+右 -> 跳到行尾
          Super-up: C-Home        # Cmd+上 -> 跳到文档开头
          Super-down: C-End       # Cmd+下 -> 跳到文档结尾

          # ================= 带选中的光标移动 =================
          Super-Shift-left: Shift-Home    # Cmd+Shift+左 -> 选中到行首
          Super-Shift-right: Shift-End    # Cmd+Shift+右 -> 选中到行尾
          Super-Shift-up: C-Shift-Home    # Cmd+Shift+上 -> 选中到开头
          Super-Shift-down: C-Shift-End   # Cmd+Shift+下 -> 选中到结尾

      - name: "终端特例 (终端内 Command 转 Ctrl+Shift)"
        application:
          # 注意：请把你使用的终端名称加到这个列表里！
          only: [gnome-terminal, ghostty, kitty, alacritty, konsole, wezterm, foot]
        remap:
          # 终端里依然按 Cmd+C/V，但系统会发送 Ctrl+Shift+C/V 给终端
          Super-c: C-Shift-c     # 终端复制
          Super-v: C-Shift-v     # 终端粘贴
          Super-t: C-Shift-t     # 终端新建标签页
          Super-w: C-Shift-w     # 终端关闭标签页
          Super-f: C-Shift-f     # 终端搜索
  '';
  };

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
