
let
  bootSystem = import <nixpkgs/nixos> {
    # system = ...;

    configuration = { config, pkgs, lib, ... }: with lib; {
      imports = [
          <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
      ];
      ## Some useful options for setting up a new system
      services.mingetty.autologinUser = mkForce "root";
      # Enable sshd which gets disabled by netboot-minimal.nix
      systemd.services.sshd.wantedBy = mkOverride 0 [ "multi-user.target" ];
      users.users.root.openssh.authorizedKeys.keys = [
     "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAyh58ehgbZVwj59zfIGvezkqD+a0hlCYeil3L4c4I174BEMqj3aI87dnHYLsAS/XP/PZq9rcmZLyw62fZIfph3DRpewwvZ0mpZFEjUk/qIjpUt2Mr5Fj5+5Q/eNnNLCJOPpMWuLXfG6HE/63OscixR9z1R7/6y43kCVfbSCya1kmazATU+VlkIdzE5cAApdEsC2H9WA9IeMq9yMdodgk6thv8Wdgm4JbM0xiNQt5ackBbqTi5dHcNELDBHULpA6KlK0nDOdPL/KVN5iPd98MnSirtRasI1miKhyWnrGEA6IHaaFbYMFVATfhxqT29D3SEjKH2G035qeN3A+GCTIdNOQ== looney@nas"
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJO6sfbq6owMTXi8EkWRQIWPumTjT0H6yK5zDlOeoMtTE0htz1a63/lG9WlT+H/G8y4TjG+bn3Ma8xWZIoS5WB1dCvyCren620RchZNJmc47A5p+eWtqm9ctwghN+WJVjBk5N6gI9VfU3np+OjJECDMsJTtEjJeqJ6LDXv5cavafOEsL/uFG1noZRJ94ug88uIcmUevyy85nh3QfoGXCrPjd3Th6zCfCHDopDn+ykQiAgJv+oUYxrYUkxnOJXKmdD3i1sm2De8lbtEJA/rgBFjRRL+xG0TQ6bp4Xfl0lA6LCUfcDlq+RO6/l8bS9i2sQZk+Jm++AnhFoBltwQC20J5 looney@laptop"
  ];
    };
  };

  pkgs = import <nixpkgs> {};
in
  pkgs.symlinkJoin {
    name = "netboot";
    paths = with bootSystem.config.system.build; [
      netbootRamdisk
      kernel
      netbootIpxeScript
    ];
    preferLocalBuild = true;
  }

