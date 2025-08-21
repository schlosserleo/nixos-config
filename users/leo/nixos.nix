{ pkgs, inputs, ... }:
{
  programs.fish.enable = true;
  users.users.leo = {
    isNormalUser = true;
    home = "/home/leo";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$Kccgxupo9BLou66Y$WCAwVbJO5JD4SJLEBYC5qImmABONYgs0spDB9RtzkdMMl4T/krjZW/4MJbnj.jXsDLYWZdYuNqZK28b23700W/";
  };
}
