{
  description = "SnowflakeOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      nixosModules.snowflake = import ./modules/default.nix;
      nixosModules.default = self.nixosModules.snowflake;
    };
}
