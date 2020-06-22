```
# Make the netboot server image
./build.sh --argstr system aarch64-linux
./build.sh --argstr system armv7l-linux
./build.sh --argstr system armv6l-linux

# Make the OS image the netboot server will serve
nix-build --out-link /tmp/netboot netboot.nix

```
