
This works best when ~/repos/nixpkgs is at checkout 22a3bf9fb9edad917fb6cd1066d58b5e426ee975 - after that, it takes too long

NIX_PATH=nixpkgs=/home/looney/repos/nixpkgs/ nix-build system.nix -A config.system.build.sdImage  --argstr system armv7l-linux -j10

```
# Make the netboot server image
./build.sh --argstr system aarch64-linux
./build.sh --argstr system armv7l-linux
./build.sh --argstr system armv6l-linux

# Make the OS image the netboot server will serve
nix-build --out-link /tmp/netboot netboot.nix

```
