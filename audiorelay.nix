{
  lib,
  stdenv,
  buildFHSEnv,
  makeWrapper,
  fetchurl,
}:
let
  audiorelayRunEnv = buildFHSEnv {
    name = "audiorelay-env";

    targetPkgs =
      pkgs:
      (with pkgs; [
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXtst
        xorg.libXi
        xorg.libXxf86vm

        gtk3
        gdk-pixbuf
        atk
        glib
        zlib
        libGL
        stdenv.cc.cc.lib

        fontconfig
        freetype
        alsa-lib
        libpulseaudio
      ]);

    runScript = "";
  };
in
stdenv.mkDerivation rec {
  pname = "audiorelay";
  version = "0.27.5";

  src = fetchurl {
    url = "https://dl.audiorelay.net/setups/linux/${pname}-${version}.tar.gz";
    sha256 = "sha256-xIVBOaS9Iee/eIGntuIevEz+gjKGeD1Pua1L9O346Mc=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontStrip = true;
  dontPatchELF = true;
  dontAutoPatchelf = true;

  unpackPhase = ''
    mkdir -p audiorelay/
    tar xf $src --directory audiorelay/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R audiorelay/* $out

    mv $out/lib/app/AudioRelay.cfg $out/lib/app/AudioRelay-unwrapped.cfg

    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x "$FILE_PATH" ]]; then
        mv "$FILE_PATH" "$FILE_PATH-unwrapped"
        makeWrapper ${audiorelayRunEnv}/bin/audiorelay-env "$FILE_PATH" \
          --add-flags "$FILE_PATH-unwrapped"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Stream audio between your devices.";
    homepage = "https://audiorelay.net/";
    platforms = [ "x86_64-linux" ];
    mainProgram = "AudioRelay";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ];
  };
}
