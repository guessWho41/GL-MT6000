#!/bin/sh

. /lib/functions/network.sh

network_find_wan6 WAN6_IF
[ -z "$WAN6_IF" ] && exit 0

network_flush_cache
network_get_device WAN_DEV "$WAN6_IF" || exit 0
network_get_prefix6 WAN_PFX "$WAN6_IF" || exit 0

WG_INTERFACES=$(ubus call network.interface dump | jsonfilter -e '@.interface[@.proto="wireguard"].interface')
[ -z "$WG_INTERFACES" ] && exit 0
for WG_IF in $WG_INTERFACES; do
    WG_STATUS=$(ubus call network.interface."$WG_IF" status 2>/dev/null)
    [ "$(echo "$WG_STATUS" | jsonfilter -e '@.up')" != "true" ] && continue

    WG_ADDR=$(echo "$WG_STATUS" | jsonfilter -e '@["ipv6-address"][0].address')
    [ -n "$WG_ADDR" ] || continue
    WG_MASK=$(echo "$WG_STATUS" | jsonfilter -e '@["ipv6-address"][0].mask')
    [ -n "$WG_MASK" ] || continue

    nft add rule inet fw4 srcnat oifname "${WAN_DEV}" snat ip6 prefix to ip6 saddr map { "${WG_ADDR}/${WG_MASK}" : "${WAN_PFX}" }
done
