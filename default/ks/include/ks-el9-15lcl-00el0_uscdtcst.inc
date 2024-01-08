### ks/include/ks-el9-15lcl-00el0_uscdtcst.inc

# Locale in US Central Daylight Time (CDT) / Central Standard Time (CST)
# Assume Hardware Real Time Clock (RTC) is Universal Time Coordinate (UTC)
# EL9:	timezone --isUtc is deprecated, use --utc
# EL9:	timezone --nontp is deprecated, use timesource --ntp-disable
# IMPORTANT:  setup chrony/NTP either in %post or post-install
timezone America/Chicago --utc
timesource --ntp-disable

