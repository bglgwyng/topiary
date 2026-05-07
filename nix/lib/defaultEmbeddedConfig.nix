{ pkgs, ... }:
let
  # build tree-sitter parser lib from parser.c.
  tree-sitter-parser-lib =
    name: src:
    pkgs.stdenv.mkDerivation {
      name = name;
      src = src;
      nativeBuildInputs = [
        pkgs.nodejs
        pkgs.gcc
      ];
      buildPhase = ''
        export HOME=$TMPDIR
        ${pkgs.tree-sitter}/bin/tree-sitter build $src -o $out
      '';
    };
in
{
  languages = {
    bash = {
      extensions = [
        "sh"
        "bash"
      ];
      grammar = {
        source = {
          path = tree-sitter-parser-lib "tree-sitter-bash" (
            pkgs.fetchgit {
              url = "https://github.com/tree-sitter/tree-sitter-bash.git";
              rev = "d1a1a3fe7189fdab5bd29a54d1df4a5873db5cb1";
              hash = "sha256-XiiEI7/6b2pCZatO8Z8fBgooKD8Z+SFQJNdR/sGGkgE=";
            }
          );
        };
      };
    };
  };
}
