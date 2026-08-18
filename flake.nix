{
  description = "Spacebirds64 - A flappy bird inspired obstacle avoidance game for the commodore c64 of 1982 developed in 2024-2025";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    dotfiles-llamato.url = "github:llamato/dotfiles";
  };

  outputs = { self, nixpkgs, dotfiles-llamato }: let
    pythonVersion = "3.10.1";
    system = "x86_64-linux";
  in let
    pkgs = nixpkgs.legacyPackages."${system}";
    lib = pkgs.lib;
    tmpx = pkgs.callPackage (dotfiles-llamato + "/nixos/packages/tmpx/package.nix") { };

    diskName = "spacebirds64";
    diskTyp = "d64";
    formatCommand = (diskFileName: filePath: cbmFileName: "${pkgs.vice}/bin/c1541 -format ${diskName},0 ${diskTyp} $out/${diskFileName} -attach $out/${diskFileName} -write ${filePath} ${cbmFileName}");
    writeCommand = (diskFileName: filePath: cbmFileName: "${pkgs.vice}/bin/c1541 -attach $out/${diskFileName} -write ${filePath} ${cbmFileName}");

    splitLines = (str: lib.splitString "\n"  str);
    flatTmpAsm = (basedir: asm: 
      lib.concatLines (map 
          (line: let 
            matches = builtins.match ".*\\.include[[:space:]]+\"([^\"]+\\.asm)\".*" line; in 
          if isNull matches || builtins.length matches == 0 then 
            line
          else let
            includedFilePath = builtins.head matches;
            absoluteFilePath = "${basedir}/${includedFilePath}";
          in
            flatTmpAsm basedir (builtins.readFile absoluteFilePath) 
          ) 
        (splitLines asm)
      )
    );
  in {
    packages."${system}" = rec {
      prg = pkgs.stdenvNoCC.mkDerivation {
        name = "Spacebirds64 executable";
        src = ./.;
        buildPhase = ''
          mkdir $out
          ${tmpx}/bin/tmpx -i main.asm -o $out/main.prg
        '';
      };

      prgdisk = pkgs.stdenvNoCC.mkDerivation rec {
        name = "Spacebirds64 program disk";
        src = ./.;
        buildPhase = with builtins // lib; let 
          diskFileName = "prgdisk.d64";
          assetsDir = src + "/assets";
          prgFile = head (attrNames (readDir prg));
          prgFilePath = "${prg}/${prgFile}";
          prgCbmName = removeSuffix ".prg" prgFile;
          assetFiles = attrNames (filterAttrs (n: v: v == "regular") (readDir assetsDir));
          prgCommand = formatCommand prgFilePath prgCbmName;
          assetCommands = concatLines (map (assetFile: writeCommand diskFileName "${assetsDir}/${assetFile}" assetFile) assetFiles);
        in ''
          mkdir $out
          ${prgCommand}
          ${assetCommands}
        '';
      };

      asmdisk = pkgs.stdenvNoCC.mkDerivation rec {
        name = "Spacebirds64 code disk";
        src = ./.;
        buildPhase = with builtins // lib; let
          diskFileName = "asmdisk.d64";
          asmFileSuffix = ".asm";
          asmFiles = attrNames (filterAttrs (n: v: v == "regular" && hasSuffix asmFileSuffix n) (readDir src));
          asmCommands = concatLines ([(formatCommand diskFileName (head asmFiles) (head asmFiles))] ++ map (asmFile: writeCommand diskFileName "${src}/${asmFile}" asmFile) (tail asmFiles));
        in ''
          mkdir $out
          ${asmCommands}
        '';
      };

      asmdiskTmpCompatible = pkgs.stdenvNoCC.mkDerivation rec {
        name = "Spacebirds 64 code disk compatible with the turbo macro pro assembler for the c64";
        src = ./.;
        buildPhase = with builtins // lib; let
          diskFileName = "asmdisk.d64";
          asmFileSuffix = ".asm";
          mainFileName = "main.asm";
          flatFileName = "flatmain.asm";
          assetsDir = src + "/assets";
          mainFilePath = "${src}/${mainFileName}";
          flatAsm = flatTmpAsm src (readFile mainFilePath);
          flatAsmFilePath = toFile flatFileName flatAsm;
          assetFiles = attrNames (filterAttrs (n: v: v == "regular") (readDir assetsDir));
          assetCommands = concatLines (map (assetFile: writeCommand diskFileName "${assetsDir}/${assetFile}" assetFile) assetFiles);
          asmCommand = formatCommand diskFileName "./${flatFileName}" (removeSuffix asmFileSuffix flatFileName);
        in ''
          mkdir $out
          ${pkgs.vice}/bin/petcat -text -w2 -o ${flatFileName} ${flatAsmFilePath}
          ${asmCommand}
          ${assetCommands}
        '';
      };
    };

    devShells."${system}".default = pkgs.mkShell {
      packages = with pkgs; [
        tmpx
        vice
      ];
    };
  };
}