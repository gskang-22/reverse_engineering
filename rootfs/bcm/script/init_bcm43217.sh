#!/bin/sh
#
# script file to init WLAN bcm43217
#

##basic setting
wl -i wl0 tp_id 1
wl -i wl0 phy_watchdog 0
wl -i wl0 wds none
wl -i wl0 up
wl -i wl0 down
wl -i wl0 mbss 1
wl -i wl0 bss -C 0 down
wl -i wl0 bss -C 1 down
wl -i wl0 bss -C 2 down
wl -i wl0 bss -C 3 down
wl -i wl0 ssid -C 0 'B''r''c''m''A''P''0'
wl -i wl0 ssid -C 1 'w''l''0''_''G''u''e''s''t''1'
wl -i wl0 ssid -C 2 'w''l''0''_''G''u''e''s''t''2'
wl -i wl0 ssid -C 3 'w''l''0''_''G''u''e''s''t''3'
wl -i wl0 ap 1
wl -i wl0 infra 1
wl -i wl0 country CN
wl -i wl0 band b
wl -i wl0 regulatory 0
wl -i wl0 radar 0 2>/dev/null
wl -i wl0 spect 0 2>/dev/null
wl -i wl0 nmode -1
wl -i wl0 mimo_bw_cap 1
wl -i wl0 nreqd 0
wl -i wl0 stbc_rx 0
wl -i wl0 sgi_tx 1
wl -i wl0 leddc 0
wl -i wl0 rxchain_pwrsave_stas_assoc_check 1
wl -i wl0 radio_pwrsave_stas_assoc_check 1
wl -i wl0 wdswsec 0
wl -i wl0 wdswsec_enable 0
wl -i wl0 nar 0
#wl -i wl0 bss -C 0 up
#wl -i wl0 bss -C 1 up
#wl -i wl0 bss -C 2 up
#wl -i wl0 bss -C 3 up