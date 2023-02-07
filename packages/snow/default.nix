{ pkgs
, lib,
...
}:
(import
  (pkgs.fetchFromGitHub {
    owner = "snowflakelinux";
    repo = "snow";
    rev = "12a860ebe973c567c1ef8df8446cbbe6de96ee90";
    hash = "sha256-pxw1x0gRyINWM99Pf8XdAx3s1Ke8ctPy7hmcLvu6blw=";
})
{ inherit pkgs lib; })
