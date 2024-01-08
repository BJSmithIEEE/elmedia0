### ks/include/ks-el9-15lcl-00el0_usedtest.inc

# Locale in US Eastern Daylight Time (EDT) / Eastern Standard Time (EST)
# Assume Hardware Real Time Clock (RTC) is Universal Time Coordinate (UTC)
# EL9:	timezone --isUtc is deprecated, use --utc
# EL9:	timezone --nontp is deprecated, use timesource --ntp-disable
# IMPORTANT:  setup chrony/NTP either in %post or post-install
timezone America/New_York --utc
timesource --ntp-disable


