{ pkgs
, lib
, ...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "snowflakelinux";
    repo = "icicle";
    rev = "8185449c3401e8d10bbbe121f96add92e906e051";
    hash = "sha256-ERum4eRLa0FaR6MFRbMJihK1QaVUFt2eKuP43bARkag=";
})
{ inherit pkgs lib; })
