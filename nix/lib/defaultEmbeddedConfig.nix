{ pkgs, ... }:
let
  inherit (pkgs) fetchgit;

  tree-sitter-parser-src =
    {
      name,
      src,
      abi ? "15",
      scanner ? null,
    }:
    pkgs.runCommand name
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.tree-sitter
        ];
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/src
        tree-sitter generate --abi ${abi} ${src}/grammar.js -o $out/src
        ${pkgs.lib.optionalString (scanner != null) "cp -r ${scanner}/* $out/src/"}
      '';
  tree-sitter-parser-lib =
    { name, src }:
    pkgs.runCommand name
      {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.tree-sitter
          pkgs.stdenv.cc
        ];
      }
      ''
        export HOME=$TMPDIR
        tree-sitter build ${src} -o $out
      '';

  queries = ./../../topiary-queries/queries;
in
{
  languages = {
    # Example of building from parser.c
    # tree-sitter-bash contains the generated parser.c, so that we don't need to use `tree-sitter-parser-src`
    # However, this is just an example
    # This pattern might be helpful when writing a new tree-sitter grammar
    bash = {
      extensions = [
        "sh"
        "bash"
      ];
      grammar.source.path =
        let
          src = fetchgit {
            url = "https://github.com/tree-sitter/tree-sitter-bash.git";
            rev = "d1a1a3fe7189fdab5bd29a54d1df4a5873db5cb1";
            hash = "sha256-XiiEI7/6b2pCZatO8Z8fBgooKD8Z+SFQJNdR/sGGkgE=";
          };
        in
        tree-sitter-parser-lib {
          name = "tree-sitter-bash";
          src = tree-sitter-parser-src {
            name = "tree-sitter-bash-src";
            inherit src;
            scanner = pkgs.runCommand "scanners" { } ''
              mkdir -p $out
              cp ${src}/src/scanner.c $out/
            '';
          };
        };
      query = "${queries}/bash/formatting.scm";
    };

    css = {
      extensions = [ "css" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-css";
        src = fetchgit {
          url = "https://github.com/tree-sitter/tree-sitter-css.git";
          rev = "6e327db434fec0ee90f006697782e43ec855adf5";
          hash = "sha256-en379DlqzzvQNvKgE8CtiA00j7phUyipttqbnETGHKc=";
        };
      };
      query = "${queries}/css/formatting.scm";
    };

    json = {
      extensions = [
        "json"
        "avsc"
        "geojson"
        "gltf"
        "har"
        "ice"
        "JSON-tmLanguage"
        "jsonl"
        "mcmeta"
        "tfstate"
        "tfstate.backup"
        "topojson"
        "webapp"
        "webmanifest"
      ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-json";
        src = fetchgit {
          url = "https://github.com/tree-sitter/tree-sitter-json.git";
          rev = "v0.24.8";
          hash = "sha256-DNZC2cTy1C8OaMOpEHM6NoRtOIbLaBf0CLXXWCKODlw=";
        };
      };
      query = "${queries}/json/formatting.scm";
    };

    nickel = {
      extensions = [ "ncl" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-nickel";
        src = fetchgit {
          url = "https://github.com/nickel-lang/tree-sitter-nickel";
          rev = "488ee4e6af15e10dd4be527777c9ba18a817d407";
          hash = "sha256-CMlf80y1te30HwjT9ykHeg6xvQc/lcCCHDMVGs7oVXQ=";
        };
      };
      query = "${queries}/nickel/formatting.scm";
    };

    ocaml = {
      extensions = [ "ml" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-ocaml";
        src = "${
          fetchgit {
            url = "https://github.com/tree-sitter/tree-sitter-ocaml.git";
            rev = "a45fda5fe73cda92f2593d16340b3f6bd46674b8";
            hash = "sha256-u8R3JvjaOrW6kCX1hNTGMl86HnKAoopSMvHr8Sj0i04=";
          }
        }/grammars/ocaml";
      };
      query = "${queries}/ocaml/formatting.scm";
    };

    ocaml_interface = {
      extensions = [ "mli" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-ocaml-interface";
        src = "${
          fetchgit {
            url = "https://github.com/tree-sitter/tree-sitter-ocaml.git";
            rev = "a45fda5fe73cda92f2593d16340b3f6bd46674b8";
            hash = "sha256-u8R3JvjaOrW6kCX1hNTGMl86HnKAoopSMvHr8Sj0i04=";
          }
        }/grammars/interface";
      };
      query = "${queries}/ocaml_interface/formatting.scm";
    };

    ocamllex = {
      extensions = [ "mll" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-ocamllex";
        src = fetchgit {
          url = "https://github.com/314eter/tree-sitter-ocamllex.git";
          rev = "5da5bb7508ac9fd3317561670ef18c126a0fe2aa";
          hash = "sha256-qfmIfcZ3zktYzuNNYP7Z6u6c7XoKsKD86MRMxe/qkpY=";
        };
      };
      query = "${queries}/ocamllex/formatting.scm";
    };

    openscad = {
      extensions = [ "scad" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-openscad";
        src = fetchgit {
          url = "https://github.com/openscad/tree-sitter-openscad.git";
          rev = "acc196e969a169cadd8b7f8d9f81ff2d30e3e253";
          hash = "sha256-x6fU1yPhYfoXemjswk+yRHW+c5V6nJgesK5tunYE7MI=";
        };
      };
      query = "${queries}/openscad/formatting.scm";
    };

    rust = {
      extensions = [ "rs" ];
      indent = "    ";
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-rust";
        src = fetchgit {
          url = "https://github.com/tree-sitter/tree-sitter-rust.git";
          rev = "e0e8b6de6e4aa354749c794f5f36a906dcccda74";
          hash = "sha256-egTxBuliboYbl+5N6Jdt960EMLByVmLqSmQLps3rEok=";
        };
      };
      query = "${queries}/rust/formatting.scm";
    };

    sdml = {
      extensions = [
        "sdm"
        "sdml"
      ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-sdml";
        src = fetchgit {
          url = "https://github.com/sdm-lang/tree-sitter-sdml";
          rev = "056fc1d0b8624aa4e58967c67bb129ebdfa6d563";
          hash = "sha256-UrlhkcfdBFN/o+NhSPDqfCS0/OpLByVA/5NPl+JPD58=";
        };
      };
      query = "${queries}/sdml/formatting.scm";
    };

    toml = {
      extensions = [ "toml" ];
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-toml";
        src = fetchgit {
          url = "https://github.com/tree-sitter/tree-sitter-toml.git";
          rev = "342d9be207c2dba869b9967124c679b5e6fd0ebe";
          hash = "sha256-5nLNBxFeOGE+gzbwpcrTVnuL1jLUA0ZLBVw2QrOLsDQ=";
        };
      };
      query = "${queries}/toml/formatting.scm";
    };

    tree_sitter_query = {
      extensions = [ "scm" ];
      grammar = {
        source.path = tree-sitter-parser-lib {
          name = "tree-sitter-query";
          src = fetchgit {
            url = "https://github.com/nvim-treesitter/tree-sitter-query";
            rev = "a0ccc351e5e868ec1f8135e97aa3b53c663cf2df";
            hash = "sha256-H2QLsjl3/Kh0ojCf2Df38tb9KrM2InphEmtGd0J6+hM=";
          };
        };
        symbol = "tree_sitter_query";
      };
      query = "${queries}/tree_sitter_query/formatting.scm";
    };

    wit = {
      extensions = [ "wit" ];
      indent = "    ";
      grammar.source.path = tree-sitter-parser-lib {
        name = "tree-sitter-wit";
        src = fetchgit {
          url = "https://github.com/bytecodealliance/tree-sitter-wit";
          rev = "v1.2.0";
          hash = "sha256-scye60ETUak1mXJXC+UY5sqbuqAcjxCsm4+AVJHhGws=";
        };
      };
      query = "${queries}/wit/formatting.scm";
    };
  };
}
