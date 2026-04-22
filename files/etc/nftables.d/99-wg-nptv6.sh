#!/bin/sh

. /lib/functions/network.sh

network_flush_cache
network_find_wan6 WAN6_IF || exit 0
network_get_device WAN_DEV "$WAN6_IF" || exit 0
network_get_prefix6 WAN_PFX "$WAN6_IF" || exit 0

for WG_IF in $(ubus call network.interface dump | jsonfilter -e '@.interface[@.proto="wireguard"].interface'); do
	eval $(ubus call network.interface."$WG_IF" status 2>/dev/null | jsonfilter -e 'WG_UP=@.up' -e 'WG_ADDR=@["ipv6-address"][0].address' -e 'WG_MASK=@["ipv6-address"][0].mask')
	[ "$WG_UP" = "1" ] || continue
	[ -n "$WG_ADDR" ] || continue
	[ -n "$WG_MASK" ] || continue
	nft add rule inet fw4 srcnat oifname "${WAN_DEV}" snat ip6 prefix to ip6 saddr map { "${WG_ADDR}/${WG_MASK}" : "${WAN_PFX}" }
done
