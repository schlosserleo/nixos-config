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

  # Deliberately not conditioned on boot.resumeDevice being set: a host with a
  # swapfile and no resume device is precisely the case this check exists to
  # catch, and common.nix hands every host suspend-then-hibernate.
  systemd.services.check-resume-offset = lib.mkIf (swapfiles != [ ]) (
    let
      swapfile = (lib.head swapfiles).device;
      offsetParam = lib.findFirst (p: lib.hasPrefix "resume_offset=" p) null config.boot.kernelParams;
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
        if [ -z "${config.boot.resumeDevice}" ]; then
          echo "${swapfile} is in use but boot.resumeDevice is unset" >&2
          echo "the kernel has nowhere to resume from, so hibernation will fail" >&2
          exit 1
        fi

        actual=$(btrfs inspect-internal map-swapfile -r ${swapfile})
        configured=${if offsetParam == null then "" else lib.removePrefix "resume_offset=" offsetParam}

        if [ -z "$configured" ]; then
          echo "${swapfile} starts at $actual but boot.kernelParams sets no resume_offset" >&2
          echo "hibernation cannot resume until resume_offset=$actual is added" >&2
          exit 1
        fi

        if [ "$actual" != "$configured" ]; then
          echo "resume_offset is stale: configured $configured, ${swapfile} now starts at $actual" >&2
          echo "hibernation will not resume until boot.kernelParams is updated to resume_offset=$actual" >&2
          exit 1
        fi

        booted=$(cat /sys/power/resume_offset)
        if [ "$booted" != "$actual" ]; then
          echo "resume_offset $actual is correct, but this kernel booted with $booted - reboot to enable hibernation"
          exit 0
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
