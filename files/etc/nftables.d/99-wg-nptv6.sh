#!/bin/sh

. /lib/functions/network.sh

RULE_COMMENT="WireGuard VPN NPTv6"

WG_IF=$(uci -q show network | grep "proto='wireguard'" | cut -d. -f2 | head -n 1)
network_find_wan6 WAN6_IF

HANDLE=$(nft -a list chain inet fw4 srcnat | grep -F "comment \"$RULE_COMMENT\"" | awk '{print $NF}')
for H in $HANDLE; do
    nft delete rule inet fw4 srcnat handle "$H"
done

if [ -z "$WG_IF" ] || [ -z "$WAN6_IF" ]; then
    exit 0
fi

WG_ADDR=$(uci -q get network."$WG_IF".addresses | tr ' ' '\n' | grep ':' | head -n 1)
if [ -n "$WG_ADDR" ]; then
    WG_ADDR_PART=$(echo "$WG_ADDR" | cut -d'/' -f1)
    WG_MASK_PART=$(echo "$WG_ADDR" | cut -d'/' -f2)
    WG_PFX_BASE=$(echo "$WG_ADDR_PART" | sed 's/:[^:]*$/::/' | sed 's/::\{1,\}/::/g')
    WG_PFX="${WG_PFX_BASE}/${WG_MASK_PART}"
else
    exit 0
fi

network_flush_cache
if network_get_device WAN_DEV "$WAN6_IF" && network_get_prefix6 WAN_PFX "$WAN6_IF"; then
    if [ -n "$WAN_PFX" ]; then
        nft add rule inet fw4 srcnat \
        oifname "${WAN_DEV}" snat ip6 prefix to ip6 \
        saddr map { "${WG_PFX}" : "${WAN_PFX}" } \
        comment "\"${RULE_COMMENT}\""
    fi
fi
