# JankyBorders control
jb-off() { killall borders 2>/dev/null && echo "borders stopped" || echo "borders not running" }
jb-on()  { borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0 & disown && echo "borders started" }
