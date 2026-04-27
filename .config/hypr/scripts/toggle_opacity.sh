#!/bin/bash
OPACITY=$(hyprctl getoption decoration:active_opacity | awk 'NR==1{print $2}')

if (( $(echo "$OPACITY == 1" | bc -l) )); then
    hyprctl keyword decoration:active_opacity 0.85
    hyprctl keyword decoration:inactive_opacity 0.75
else
    hyprctl keyword decoration:active_opacity 1
    hyprctl keyword decoration:inactive_opacity 1
fi
