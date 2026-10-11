{
  description = "Development environment for the opf Ruby gem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.ruby_4_0
            ];

            # The nix-provided Ruby is read-only; install gems into a
            # project-local directory so bundler works out of the box.
            shellHook = ''
              export GEM_HOME="$PWD/.nix-gems"
              export GEM_PATH="$GEM_HOME"
              export PATH="$GEM_HOME/bin:$PATH"
            '';
          };
        }
      );
    };
}
