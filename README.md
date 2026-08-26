# nixos-config

Flake-based NixOS for three hosts. Every directory under `hosts/` is picked up
automatically by `flake.nix`, so adding a machine means adding a directory.

| host | machine | notes |
| --- | --- | --- |
| `twinkdesk` | desktop, NVIDIA | hibernates to a 64G swapfile |
| `twinkpad` | ThinkPad X13 Gen 4, AMD | s2idle only, so hibernation is load-bearing |
| `vm` | throwaway | |

`modules/` is shared by all hosts, `home/` is home-manager for `leo`, and
`hosts/<name>/` holds only what is true of that one machine.

## Rebuilding

```
nh os switch
```

## Installing a host from scratch

1. Boot the installer and partition with disko:

   ```
   nix run github:nix-community/disko -- --mode disko --flake .#<host>
   ```

   `hosts/<host>/disko.nix` addresses the disk by `by-partuuid`, so point it at
   the new disk before running this.

2. `nixos-install --flake .#<host>`

3. Reboot, then finish the steps below. Until they are done the machine boots
   fine but a few units stay red.

### Hibernation

The swapfile offset cannot be known before the filesystem exists, so a fresh
host has no `resume_offset` and `check-resume-offset` fails on purpose. Read the
real offset and put it in `hosts/<host>/default.nix`:

```
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

`boot.resumeDevice` is the UUID of the btrfs filesystem itself, from
`findmnt -no UUID /`. The check re-runs on every boot and will say so if a
balance ever moves the swapfile.

### AirVPN

`modules/airvpn.nix` carries everything from an AirVPN WireGuard config except
the two secrets, which stay out of the Nix store. Download a profile for the
server you want, then:

```
sudo sh -c 'umask 077; sed -n "s/^PrivateKey *= */AIRVPN_PRIVATE_KEY=/p; s/^PresharedKey *= */AIRVPN_PRESHARED_KEY=/p" <profile>.conf > /etc/airvpn.env'
sudo systemctl restart NetworkManager-ensure-profiles
```

The profile then appears under GNOME's VPN toggle. Adding a second server needs
only its `PublicKey` and `Endpoint` in the `servers` attrset; the client address
and DNS are the same in every profile AirVPN issues for a device.

### Fingerprint (twinkpad)

```
fprintd-enroll
```

### GPG

The public key and its ultimate trust come from `home/gpgpub.key`. The secret
key does not live here — restore it from the YubiKey with `gpg --card-status`.
