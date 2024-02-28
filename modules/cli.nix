{pkgs, ...}:
{
	environment.systemPackages = with pkgs;[
		joshuto #file manager
		ripgrep
		helix
		#zenith #process manager, build currently failing
	];
}
