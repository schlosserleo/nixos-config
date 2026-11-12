{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  imagemagick,
  copyDesktopItems,
  makeDesktopItem,
  aws-lc,
  gtk3,
  libGL,
  libxkbcommon,
  vulkan-loader,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
}:

let
  # winit, glutin and wgpu dlopen these at run time, so nothing links them.
  runtimeLibs = [
    libGL
    libxkbcommon
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "misterdownloadmanager";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "anefzaoui";
    repo = "misterdownloadmanager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WRBG1npj6+//0YjWooMmw03ngVRkDx1WyhvwOL2+7sc=";
  };

  cargoHash = "sha256-+l1+VATWsXyAD/JRq8tIfED7lIRsfJK95bWhVR6NSGE=";

  # Upstream counts any binary outside /usr/bin as a tar.gz install and offers
  # to overwrite itself; a store path must be treated as package-managed.
  postPatch = ''
    substituteInPlace crates/tools/src/update.rs \
      --replace-fail '|| exe.parent() == Some(Path::new("/usr/bin"))' \
                     '|| exe.parent() == Some(Path::new("/usr/bin")) || exe.starts_with("/nix/store")'
  '';

  cargoBuildFlags = [
    "-p"
    "mdm-app"
    "-p"
    "mdm-nmhost"
    "-p"
    "mdm-cli"
    "-p"
    "mdm-mcp"
  ];

  nativeBuildInputs = [
    pkg-config
    imagemagick
    copyDesktopItems
  ];

  # rustPlatform sets AWS_LC_SYS_USE_SYSTEM, so aws-lc-sys links this instead of
  # building its vendored copy.
  buildInputs = [
    aws-lc
    gtk3
  ];

  # The workspace tests need upstream's lab server and network access.
  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "misterdownloadmanager";
      desktopName = "Mister Download Manager";
      comment = "Download manager";
      exec = "misterdownloadmanager %U";
      icon = "misterdownloadmanager";
      categories = [
        "Network"
        "FileTransfer"
      ];
      mimeTypes = [
        "x-scheme-handler/magnet"
        "application/x-bittorrent"
      ];
    })
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    magick "art/Mister Download Manager.png" -resize 256x256 \
      $out/share/icons/hicolor/256x256/apps/misterdownloadmanager.png
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibs} $out/bin/misterdownloadmanager
  '';

  meta = {
    description = "Download manager with segmented downloads, torrents and browser integration";
    homepage = "https://github.com/anefzaoui/misterdownloadmanager";
    changelog = "https://github.com/anefzaoui/misterdownloadmanager/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    mainProgram = "misterdownloadmanager";
    platforms = lib.platforms.linux;
  };
})
