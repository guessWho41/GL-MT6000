#!/bin/sh

# WireGuard NPTv6 using primary wan6 interface

. /lib/functions/network.sh

find_primary_wan6() {
	local best_if best_metric metric iface family member members policy dump

	if [ -f /etc/config/mwan3 ] && /etc/init.d/mwan3 enabled 2>/dev/null; then
		policy=$(uci -q get mwan3.default_rule_v6.use_policy)
		if [ -n "$policy" ]; then
			members=$(uci -q get mwan3."$policy".use_member)
			for member in $members; do
				iface=$(uci -q get mwan3."$member".interface)
				[ -z "$iface" ] && continue
				family=$(uci -q get mwan3."$iface".family)
				[ "$family" = "ipv6" ] || continue
				metric=$(uci -q get mwan3."$member".metric)
				[ -z "$metric" ] && metric=0
				if [ -z "$best_if" ] || [ "$metric" -lt "$best_metric" ]; then
					best_if="$iface"
					best_metric="$metric"
				fi
			done
		fi
	fi

	if [ -z "$best_if" ]; then
		dump=$(ubus call network.interface dump)
		for iface in $(echo "$dump" | jsonfilter -e '@.interface[@.route[@.target="::" && !@.table]].interface'); do
			metric=$(echo "$dump" | jsonfilter -e "@.interface[@.interface='$iface'].metric")
			[ -z "$metric" ] && metric=0
			if [ -z "$best_if" ] || [ "$metric" -lt "$best_metric" ]; then
				best_if="$iface"
				best_metric="$metric"
			fi
		done
	fi

	[ -n "$best_if" ] || return 1
	export -- "$1=$best_if"
}

find_primary_wan6 WAN6_IF || exit 0
network_flush_cache
network_get_device WAN_DEV "$WAN6_IF" || exit 0
network_get_prefix6 WAN_PFX "$WAN6_IF" || exit 0

for WG_IF in $(ubus call network.interface dump | jsonfilter -e '@.interface[@.proto="wireguard"].interface'); do
	unset WG_UP WG_ADDR WG_MASK
	eval $(ubus call network.interface."$WG_IF" status 2>/dev/null | jsonfilter \
		-e 'WG_UP=@.up' \
		-e 'WG_ADDR=@["ipv6-address"][0].address' \
		-e 'WG_MASK=@["ipv6-address"][0].mask')
	[ "$WG_UP" = "1" ] || continue
	[ -n "$WG_ADDR" ] || continue
	[ -n "$WG_MASK" ] || continue
	nft add rule inet fw4 srcnat oifname "${WAN_DEV}" snat ip6 prefix to ip6 saddr map { "${WG_ADDR}/${WG_MASK}" : "${WAN_PFX}" }
done
