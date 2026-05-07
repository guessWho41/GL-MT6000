GL.iNet Flint 2 (GL-MT6000) custom build with LuCi.

Repository for building [Pesa1234's](https://forum.openwrt.org/u/pesa1234) [GL.iNET - MT 6000 custom build](https://github.com/pesa1234/MT6000_cust_build) based on [Cjom's](https://forum.openwrt.org/u/cjom) [GL-MT6000 custom OpenWrt firmware builder](https://github.com/cjom/gl-mt6000) with following customizations:

- Dropbear replaced with OpenSSH and SFTP with [hardened config](https://github.com/cjom/GL-MT6000/tree/main/files/etc/ssh) by [Cjom](https://forum.openwrt.org/u/cjom)
- Mbed TLS relaced with OpenSSL
- uHTTPd replaced with nginx
- Wi-Fi UCODE scripts
- AdBlock-Fast
- Bridger
- Dynamic DNS Client
- dnscrypt-proxy 2
- Irqbalance with exceptions set by smp_affinity
- mwan3 [nftables port](https://github.com/dl12345/mwan3) by [dl12345](https://forum.openwrt.org/u/dl12345)
- **SQM**
- TCP BBR
- MiniUPnPd
- usteer
- Wireguard VPN with NPTv6
- ZRAM
- Removed: odhcpd and ppp
