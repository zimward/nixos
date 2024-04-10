{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    rustup
    gcc_multi
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.numpy
      python-pkgs.matplotlib
    ]))
  ];
}
