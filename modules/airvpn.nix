{ lib, ... }:
let
  # Everything below comes from AirVPN's config generator (Client Area → Config
  # Generator → Linux → WireGuard). The client address and the DNS servers are
  # the same in every config it hands out for a given device; only the peer's
  # PublicKey and Endpoint change per server, so those are all a new entry needs.
  address4 = "10.165.86.112/32"; # [Interface] Address, IPv4 half
  address6 = "fd7d:76ee:e68f:a993:6cc4:b91f:bcde:1a73/128"; # [Interface] Address, IPv6 half

  # AirVPN's own resolvers, reachable only inside the tunnel.
  dns4 = "10.128.0.1";
  dns6 = "fd7d:76ee:e68f:a993::1";

  servers = {
    nl = {
      publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
      endpoint = "nl3.vpn.airdns.org:1637";
    };
  };

  mkProfile = name: peer: {
    connection = {
      id = "AirVPN ${lib.toUpper name}";
      type = "wireguard";
      interface-name = "airvpn-${name}";
      # GNOME's VPN toggle turns these on; nothing should grab them at boot.
      autoconnect = false;
    };

    wireguard = {
      private-key = "$AIRVPN_PRIVATE_KEY";
      # 0 = the key lives in the profile, so no prompt on connect.
      private-key-flags = 0;
      # AirVPN's servers fragment above this.
      mtu = 1320;
    };

    "wireguard-peer.${peer.publicKey}" = {
      inherit (peer) endpoint;
      preshared-key = "$AIRVPN_PRESHARED_KEY";
      preshared-key-flags = 0;
      allowed-ips = "0.0.0.0/0;::/0;";
      persistent-keepalive = 15;
    };

    # No gateway: the default route follows from allowed-ips above.
    ipv4 = {
      method = "manual";
      address1 = address4;
      dns = "${dns4};";
      # A negative priority makes this the only resolver while connected, so
      # the ISP's DNS cannot answer anything behind the VPN's back.
      dns-priority = -10;
      dns-search = "~;";
    };

    ipv6 = {
      method = "manual";
      address1 = address6;
      dns = "${dns6};";
      dns-priority = -10;
      dns-search = "~;";
      addr-gen-mode = "default";
    };
  };
in
{
  networking.networkmanager.ensureProfiles = {
    # Substituted into the profiles at activation, so the keys stay out of the
    # world-readable Nix store. Create it by hand, root-owned and chmod 600:
    #   AIRVPN_PRIVATE_KEY=...
    #   AIRVPN_PRESHARED_KEY=...
    environmentFiles = [ "/etc/airvpn.env" ];
    profiles = lib.mapAttrs mkProfile servers;
  };

  # NetworkManager routes a full-tunnel WireGuard peer the way wg-quick does,
  # with an fwmark and a suppress_prefixlength rule; strict reverse-path
  # filtering drops the replies that come back over the tunnel.
  networking.firewall.checkReversePath = "loose";
}
