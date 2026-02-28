{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  fetchurl,
  xorg,
  gtk3,
  gdk-pixbuf,
  atk,
  glib,
  zlib,
  libGL,
  fontconfig,
  freetype,
  alsa-lib,
  libpulseaudio,

}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "audiorelay";
  version = "0.27.5";

  src = fetchurl {
    url = "https://dl.audiorelay.net/setups/linux/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-xIVBOaS9Iee/eIGntuIevEz+gjKGeD1Pua1L9O346Mc=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];
  dontAutoPatchelf = true;

  buildInputs = [
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

    fontconfig
    freetype
    alsa-lib
    libpulseaudio

  ];

  unpackPhase = ''
    mkdir -p audiorelay/
    tar xf $src --directory audiorelay/
  '';

  installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R audiorelay/* $out

      mv $out/lib/app/AudioRelay.cfg $out/lib/app/AudioRelay-unwrapped.cfg

      # for FILE in $(ls $out/bin); do
      #   FILE_PATH="$out/bin/$FILE"
      #   if [[ -x "$FILE_PATH" ]]; then
      #     mv "$FILE_PATH" "$FILE_PATH-unwrapped"
      #     makeBinaryWrapper "$FILE_PATH-unwrapped" "$FILE_PATH" \
      #         --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" 
      #   fi
      # done

    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x "$FILE_PATH" ]]; then
        mv "$FILE_PATH" "$FILE_PATH-unwrapped"
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          "$FILE_PATH-unwrapped"
        makeBinaryWrapper "$FILE_PATH-unwrapped" "$FILE_PATH" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
            --prefix LD_LIBRARY_PATH : "$out/lib/runtime/lib" \
            --prefix LD_LIBRARY_PATH : "$out/lib/runtime/lib/server"
      fi
    done

      runHook postInstall
  '';

  meta = {
    description = "Stream audio between your devices.";
    homepage = "https://audiorelay.net/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "AudioRelay";
    maintainers = with lib.maintainers; [ ];
  };
})
