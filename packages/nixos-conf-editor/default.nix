{ pkgs
, lib,
...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "vlinkz";
    repo = "nixos-conf-editor";
    rev = "0.1.1";
    hash = "sha256-TeDpfaIRoDg01FIP8JZIS7RsGok/Z24Y3Kf+PuKt6K4=";
})
{ inherit pkgs lib; })
