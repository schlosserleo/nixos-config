{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # snapper's timeline fails without <SUBVOLUME>/.snapshots and nothing creates
  # it. A subvolume, so snapshots of the parent don't include old snapshots.
  systemd.services.snapper-subvolumes =
    let
      dirs = lib.mapAttrsToList (
        _: cfg: "${lib.removeSuffix "/" cfg.SUBVOLUME}/.snapshots"
      ) config.services.snapper.configs;
    in
    {
      description = "Create the .snapshots subvolume for each snapper config";
      wantedBy = [ "multi-user.target" ];
      requiredBy = [
        "snapper-timeline.service"
        "snapper-cleanup.service"
      ];
      before = [
        "snapper-timeline.service"
        "snapper-cleanup.service"
      ];
      after = [ "local-fs.target" ];
      path = [ pkgs.btrfs-progs ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = lib.concatMapStrings (dir: ''
        if [ ! -e ${lib.escapeShellArg dir} ]; then
          btrfs subvolume create ${lib.escapeShellArg dir}
        fi
      '') dirs;
    };

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ user ];
        # ALLOW_USERS does nothing without this.
        SYNC_ACL = true;
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 12;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 3;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      root = {
        SUBVOLUME = "/";
        ALLOW_USERS = [ user ];
        # ALLOW_USERS does nothing without this.
        SYNC_ACL = true;
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 6;
        TIMELINE_LIMIT_DAILY = 5;
        TIMELINE_LIMIT_WEEKLY = 0;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };
  };
}
