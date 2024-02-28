{pkgs, ...}:
{
	environment.systemPackages = with pkgs;[
		joshuto #file manager
		ripgrep
		#zenith #process manager, build currently failing
	];
}
