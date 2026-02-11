GL.iNET Flint 2 (GL-MT6000) custom build with LuCi.

Repository for building [pesa1234's](https://forum.openwrt.org/u/pesa1234) [GL.iNET - MT 6000 custom build](https://github.com/pesa1234/MT6000_cust_build) based on [Cjom's](https://forum.openwrt.org/u/cjom) [GL-MT6000 custom OpenWrt firmware builder](https://github.com/cjom/gl-mt6000) with following customizations:

- Mbed TLS relaced with OpenSSL
- WiFi UCODE scripts
- Ad Block Fast
- Bridger
- DDNS
- DNS Crypt Proxy
- Irqbalance with exceptions set by smp_affinity
- MWAN3
- OpenSSH and SFTP with [hardened config](https://github.com/cjom/GL-MT6000/tree/main/files/etc/ssh) from [Cjom](https://forum.openwrt.org/u/cjom)
- SQM with [mq_cake](https://forum.openwrt.org/t/mt6000-custom-build-with-luci-and-some-optimization-kernel-6-12-x/185241/2761?u=guesswho41) script by [mindwolf](https://forum.openwrt.org/u/mindwolf)
- TCP BBR
- UPnP
- Wireguard
- ZRAM
- Removed: dropbear, odhcpd and ppp
