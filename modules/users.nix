{ pkgs, user, ... }:
{
  users.mutableUsers = false;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$7EjjIvchL56tLLlI5uU7E.$ZHcMPPUelBNnbGjSU0ZxILQWuizLcObrQg6rF.meM69";
  };

  users.users.root.initialHashedPassword = "$y$j9T$1TQe91H/nADAi30/Dzdaw.$3Pa5jiCTQ0ykK3iq0KZHDoeI50NddfN.VUdI32eCsM3";

  programs.fish.enable = true;
}
