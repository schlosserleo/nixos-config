{pkgs, ...}: {
  users = {
    mutableUsers = false;
    users = {
      leo = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["wheel" "input"];
        # FIXME: move to sops-nix or agenix
        hashedPassword = "$y$j9T$yNdH78UHzeQnPlNXL9mhl1$lCFH86eSjuG9Og.gpBXDavWOpbZE0dYb/jeaRr2V3R5";
      };
      root.initialHashedPassword = "$y$j9T$uJcKGpp54PUa26YSvcx2p/$uTtpTgM5iCGMy8TbZMic34Cy4AuL6Nr8leJi0UVxPT.";
    };
  };

  programs.fish.enable = true;
}
