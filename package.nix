{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  gtk3,
  gtksourceview4,
  gtksourceview3,
  libgee,
  gnome-keyring,
  libsecret,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  libsoup_3,
  webkitgtk_4_1,
  json-glib,
  libnotify,
  libcanberra-gtk3,
  at-spi2-atk,
  dbus,
  xorg,
  libGL,
  sources,
}:

stdenv.mkDerivation rec {
  pname = "tableplus";
  inherit (sources.tableplus) version;

  src = sources.tableplus.src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    gtk3
    gtksourceview4
    gtksourceview3
    libgee
    gnome-keyring
    libsecret
    glib
    cairo
    pango
    gdk-pixbuf
    libsoup_3
    webkitgtk_4_1
    json-glib
    libnotify
    libcanberra-gtk3
    at-spi2-atk
    dbus
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    libGL
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/applications $out/share/pixmaps

    cp -r opt/tableplus/* $out/lib/

    ln -s $out/lib/resource/image/logo.png $out/share/pixmaps/tableplus.png

    makeWrapper $out/lib/tableplus $out/bin/tableplus \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    cp $out/lib/tableplus.desktop $out/share/applications/
    substituteInPlace $out/share/applications/tableplus.desktop \
      --replace-fail "/usr/local/bin/tableplus" "$out/bin/tableplus" \
      --replace-fail "/opt/tableplus/resource/image/logo.png" "tableplus"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern, native database management tool";
    homepage = "https://tableplus.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "tableplus";
  };
}
