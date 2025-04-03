{lib, ...}: {
  perSystem = {pkgs, ...}:
    with pkgs; let
      inherit (llvmPackages_latest) clang bintools stdenv openmp;
      LD_LIBRARY_PATH =
        if stdenv.hostPlatform.isDarwin
        then "DYLD_LIBRARY_PATH"
        else "LD_LIBRARY_PATH";
    in {
      devShells.default = mkShell.override {inherit stdenv;} {
        nativeBuildInputs = [cmake ninja clang bintools];

        buildInputs = with python312Packages;
          [
            python
            venvShellHook

            igraph
            ipywidgets
            joblib
            numpy
            plotly
            scikit-learn
            scipy
            wasserstein
          ]
          ++ [
            boost
            llvm
            openmp
          ];

        hardeningDisable = ["all"];
        enableParallelBuilding = true;

        venvDir = "./.venv";
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
        '';

        postShellHook = ''
          unset SOURCE_DATE_EPOCH
          export ${LD_LIBRARY_PATH}=${lib.makeLibraryPath [stdenv.cc.cc]}
        '';

        env = {
          LDFLAGS = "-fuse-ld=lld";
          CXXFLAGS = "-O3 -Wall -march=native -mtune=native -funroll-loops -flto";
          NIX_ENFORCE_NO_NATIVE = 0;
          NIX_ENFORCE_PURITY = 0;
        };
      };
    };
}
