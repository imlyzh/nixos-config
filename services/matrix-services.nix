# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  services.caddy.enable = true;
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "ylms.org";
      database_backend = "rocksdb";
    };
  };
  services.jitsi-meet.enable = true;

  # systemd.services = {
  #   matrix-conduit.before = [ "jitsi-videobridge2.service" ];
  # };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}

