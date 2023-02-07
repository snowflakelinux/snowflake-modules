{ pkgs
, lib
, ...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nix-software-center";
    rev = "0.1.1";
    hash = "sha256-98WJom0WtCymJboUom7Uuo8f53JfITR9uqD+L7BifbY=";
  })
{ inherit pkgs lib; })
