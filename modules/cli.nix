{pkgs, ...}:
{
	environment.systemPackages = with pkgs;[
    nushell
    starship
    htop
    helix
		joshuto #file manager
		ripgrep
		#zenith #process manager, build currently failing
	];
}
