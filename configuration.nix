{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  nixpkgs.overlays = [(self: super: {
    # Does not cross-compile...
    alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";

    # A "regression" in nixpkgs, where python3 pycryptodome does not cross-compile.
    crda = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
  })];

  # (Failing build in a dep to be investigated)
  security.polkit.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # texinfoInteractive has trouble cross-compiling
  documentation.info.enable = lib.mkForce false;

  # `xterm` is being included even though this is GUI-less.
  # → https://github.com/NixOS/nixpkgs/pull/62852
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;

  # ec6224b6cd147943eee685ef671811b3683cb2ce re-introduced udisks in the installer
  # udisks fails due to gobject-introspection being not cross-compilation friendly.
  services.udisks2.enable = lib.mkForce false;

  users.extraUsers.nixos.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAyh58ehgbZVwj59zfIGvezkqD+a0hlCYeil3L4c4I174BEMqj3aI87dnHYLsAS/XP/PZq9rcmZLyw62fZIfph3DRpewwvZ0mpZFEjUk/qIjpUt2Mr5Fj5+5Q/eNnNLCJOPpMWuLXfG6HE/63OscixR9z1R7/6y43kCVfbSCya1kmazATU+VlkIdzE5cAApdEsC2H9WA9IeMq9yMdodgk6thv8Wdgm4JbM0xiNQt5ackBbqTi5dHcNELDBHULpA6KlK0nDOdPL/KVN5iPd98MnSirtRasI1miKhyWnrGEA6IHaaFbYMFVATfhxqT29D3SEjKH2G035qeN3A+GCTIdNOQ== looney@nas.baldoyle.magicbluesmoke.net"
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJO6sfbq6owMTXi8EkWRQIWPumTjT0H6yK5zDlOeoMtTE0htz1a63/lG9WlT+H/G8y4TjG+bn3Ma8xWZIoS5WB1dCvyCren620RchZNJmc47A5p+eWtqm9ctwghN+WJVjBk5N6gI9VfU3np+OjJECDMsJTtEjJeqJ6LDXv5cavafOEsL/uFG1noZRJ94ug88uIcmUevyy85nh3QfoGXCrPjd3Th6zCfCHDopDn+ykQiAgJv+oUYxrYUkxnOJXKmdD3i1sm2De8lbtEJA/rgBFjRRL+xG0TQ6bp4Xfl0lA6LCUfcDlq+RO6/l8bS9i2sQZk+Jm++AnhFoBltwQC20J5 looney@looney2-l.dub.corp.google.com"
  ];
  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;
  # OpenSSH is forced to have an empty  on the installer system[1], this won't allow it
  # to be started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  # Enable OpenSSH out of the box.
  services = {
    sshd.enabled = true;
  services = {
    dhcpd4 {
      enable = true;
      extraConfig = ''
      option domain-name "contest.fb.com";
      option domain-name-servers 8.8.4.4;

      subnet 192.168.150.0 netmask 255.255.255.0 {
        range 192.168.150.10 192.168.150.100;
        option routers 192.168.150.1;
        option subnet-mask 255.255.255.0;
      }
      '';
    };
    pixiecore = {
      # pixiecore boot  -d --dhcp-no-bind   bzImage initrd --cmdline='init=/nix/store/jd5gkdggwjak16g81ygp59s4czkvjx0k-nixos-system-nixos-20.03.2176.a84b797b28e/init initrd=initrd loglevel=4' --port 80 --status-port=80
      kernel =  "to be filled in from netboot.nix";
      initrd =  "to be filled in from netboot.nix";;
      dhcpNoBind = true;
      cmdLine = "init=/nix/store/jd5gkdggwjak16g81ygp59s4czkvjx0k-nixos-system-nixos-20.03.2176.a84b797b28e/init initrd=initrd loglevel=4";
    };
  }

  networking = {
    extraHosts = ''
      192.168.150.10 testhost10
      192.168.150.11 testhost11
      192.168.150.12 testhost12
      192.168.150.13 testhost13
      192.168.150.14 testhost14
      192.168.150.15 testhost15
      192.168.150.16 testhost16
      192.168.150.17 testhost17
      192.168.150.18 testhost18
    '';

    firewall = {
      enable = lib.mkForce true;
      allowPing = true;
      logRefusedConnections = false;
      rejectPackets = false;
      allowedTCPPorts = [ 22 ];
      #allowedTCPPortRanges = [{ from = 220; to = 230; }];
      trustedInterfaces = ["eth1"];
    };
    enableIPv6 = true;
    useDHCP = true;
    hostName = "jumphost.contest.fb.com";
    interfaces = {
      eth0 = {
        ip4.useDhcp = true;
      }
      eth1 = {
        ipv4.addresses = [
          { address="192.168.150.1"; prefixLength = 24; }
        ];
      }
    };
    nat = {
      enable = true;
      internalInterfaces = [ "eth1" ];
      externalInterface = "eth0";
      internalIPs = [ "192.168.150.1/24" ];
    };
  };


}
