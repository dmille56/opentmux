{
  description = "OpenCode tmux integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        opentmux = pkgs.buildNpmPackage {
          pname = "opentmux";
          version = "1.5.7";

          src = ./.;
          npmDepsHash = "sha256-3zD095mPLTZpsy4wSAtjeWD9Dga6PfcRP1UOsmpUquk=";
          npmDepsFetcherVersion = 2;
          makeCacheWritable = true;
          npmBuildScript = "build";
          npmInstallFlags = [ "--ignore-scripts" ];

          nativeBuildInputs = [
            pkgs.makeWrapper
          ];

          buildInputs = [
            pkgs.nodejs
            pkgs.tmux
          ];

          buildPhase = ''
            npm run build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp dist/bin/opentmux.js $out/bin/opentmux
            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/opentmux \
              --suffix PATH : "${pkgs.lib.makeBinPath [ pkgs.tmux ]}"
          '';

          meta = {
            homepage = "https://github.com/AnganSamadder/opentmux";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.darwin ++ pkgs.lib.platforms.linux;
            description = "OpenCode tmux integration plugin";
          };
        };
      in
      {
        packages.default = opentmux;
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/opentmux";
        };
      }
    );
}
