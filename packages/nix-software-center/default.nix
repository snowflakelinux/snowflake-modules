{ pkgs
, lib
, ...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nix-software-center";
    rev = "64ef8b1bb08fe27863743ea5f135391c7fd287a3";
    hash = "sha256-RbMm3jnRHA+U35hcNePcp2BsmpCAeuwqjsw7vxhu+o0=";
  })
{ inherit pkgs lib; })
