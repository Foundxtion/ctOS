{config, lib, pkgs, ...}:
with lib;
let
	my-kubernetes-helm = with pkgs; wrapHelm kubernetes-helm {
		plugins = with pkgs.kubernetes-helmPlugins; [
			helm-secrets
			helm-diff
			helm-s3
			helm-git
		];
	};

	my-helmfile = pkgs.helmfile-wrapped.override {
		inherit (my-kubernetes-helm) pluginsDir;
	};
in
{
    options = {
        fndx.packages.k8s.enable = mkEnableOption "K8s clients";  
    };

    config = mkIf config.fndx.packages.k8s.enable {
		environment.systemPackages = with pkgs; [
			my-kubernetes-helm
			my-helmfile
			kubectl
		];
    };
}
