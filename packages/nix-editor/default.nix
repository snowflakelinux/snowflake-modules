{ pkgs
, lib
, ...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nix-editor";
    rev = "0174ad26a105a94bb8846d9dd3c3e6e1a5467a99";
    hash = "sha256-+Poc2pz8ah/azWkoa6kH9UtfaSy9sNOlcGwvu2ARAfA=";
})
{ inherit pkgs lib; })
