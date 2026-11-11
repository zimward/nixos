let tmpdir = mktemp -d
cd $tmpdir
try {
  #fetch repo
  ^git clone --depth 1 $env.REPO nixos
  cd nixos
  let closure = n build .
  ^nixos-rebuild --elevate none --store-path $closure switch
} finally {
  #cleanup
  cd $"($tmpdir)/.."
  rm -rf $tmpdir
}
if $env.REBOOT == 1 {
  let booted = ^readlink ...(glob "/run/booted-system/{initrd,kernel,kernel-modules}")
  let built = ^readlink ...(glob "/nix/var/nix/profiles/system/{initrd,kernel,kernel-modules}")
  if $booted != $built {
    #reboot needed
    ^systemctl reboot
  }
}
