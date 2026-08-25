{ user, ... }:
{
  # btrfs checksums every block but only verifies on read, so data nobody
  # touches is never checked. A scrub walks the whole filesystem and, on DUP
  # metadata, repairs what it finds.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

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
