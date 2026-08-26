{ lib, ... }:
let
  # From AirVPN's config generator. Only PublicKey and Endpoint differ between
  # servers, so those are all a new entry needs.
  address4 = "10.165.86.112/32";
  address6 = "fd7d:76ee:e68f:a993:6cc4:b91f:bcde:1a73/128";

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

    ipv4 = {
      method = "manual";
      address1 = address4;
      dns = "${dns4};";
      # Negative priority makes this the only resolver while connected.
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
    # Keys stay out of the store; created by hand, root-owned 0600. See README.
    environmentFiles = [ "/etc/airvpn.env" ];
    profiles = lib.mapAttrs mkProfile servers;
  };

  # A full-tunnel peer is routed with an fwmark and a suppress_prefixlength
  # rule; strict reverse-path filtering drops the replies.
  networking.firewall.checkReversePath = "loose";
}
