{
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;
    prettier.enable = true;
  };

  settings.formatter.prettier.includes = ["*.md" "*.json" "*.yaml" "*.yml"];
}
