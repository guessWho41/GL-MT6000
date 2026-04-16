#!/bin/sh

. /lib/functions/network.sh

WG_INTERFACES=$(ubus call network.interface dump | jsonfilter -e '@.interface[@.proto="wireguard"].interface')
[ -z "$WG_INTERFACES" ] && exit 0

network_find_wan6 WAN6_IF
[ -z "$WAN6_IF" ] && exit 0

network_flush_cache
if ! network_get_device WAN_DEV "$WAN6_IF" || ! network_get_prefix6 WAN_PFX "$WAN6_IF" || [ -z "$WAN_PFX" ]; then
    exit 0
fi

for WG_IF in $WG_INTERFACES; do
    WG_STATUS=$(ubus call network.interface."$WG_IF" status 2>/dev/null)
    [ "$(echo "$WG_STATUS" | jsonfilter -e '@.up')" != "true" ] && continue

    eval $(echo "$WG_STATUS" | jsonfilter -e WG_ADDR='@["ipv6-address"][0].address' -e WG_MASK='@["ipv6-address"][0].mask')
    if [ -z "$WG_ADDR" ] || [ -z "$WG_MASK" ]; then
        continue
    fi
    WG_PFX="${WG_ADDR%:*}:/${WG_MASK}"
    nft add rule inet fw4 srcnat oifname "${WAN_DEV}" snat ip6 prefix to ip6 saddr map { "${WG_PFX}" : "${WAN_PFX}" }
done
