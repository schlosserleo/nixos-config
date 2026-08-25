{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  swapfiles = lib.filter (s: s.size != null) config.swapDevices;
in
{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  systemd.services.check-resume-offset = lib.mkIf (swapfiles != [ ] && config.boot.resumeDevice != "") (
    let
      swapfile = (lib.head swapfiles).device;
    in
    {
      description = "Verify the hibernation resume offset still matches the swapfile";
      wantedBy = [ "multi-user.target" ];
      after = [ "swap.target" ];
      unitConfig.ConditionPathExists = swapfile;
      path = [ pkgs.btrfs-progs ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        actual=$(btrfs inspect-internal map-swapfile -r ${swapfile})
        booted=$(cat /sys/power/resume_offset)
        if [ "$actual" != "$booted" ]; then
          echo "resume_offset is stale: booted with $booted, ${swapfile} now starts at $actual" >&2
          echo "hibernation will not resume until boot.kernelParams is updated to resume_offset=$actual" >&2
          exit 1
        fi
        echo "resume_offset $actual still matches ${swapfile}"
      '';
    }
  );

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ user ];
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
