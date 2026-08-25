{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  # File-backed swap, i.e. the swapfile hibernation would resume from.
  # size is null for partition-backed swap and for zram.
  swapfiles = lib.filter (s: s.size != null) config.swapDevices;
in
{
  # btrfs checksums every block but only verifies on read, so data nobody
  # touches is never checked. A scrub walks the whole filesystem and, on DUP
  # metadata, repairs what it finds.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # resume_offset is a physical block address, so recreating the swapfile
  # moves it and silently invalidates the kernel parameter. The symptom shows
  # up only on the next resume, long after the cause, so check it at boot and
  # fail loudly instead of leaving it to be discovered the hard way.
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
    # Catch up on timers missed while the machine was off, rather than
    # silently skipping a day.
    persistentTimer = true;

    configs = {
      # The only data here that the flake cannot rebuild, so it gets the
      # deepest retention.
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

      # On NixOS / is mostly symlinks into the store, and generations already
      # cover the system itself. What a snapshot actually buys here is
      # /var/lib service state, so retention is shallow.
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
