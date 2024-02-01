#!/bin/sh
displays=$(xrandr -q | grep " connected" | cut -d ' ' -f1)

FILE_PATH="/tmp/external_display";

if [ -f "$FILE_PATH" ]; then
    ext_dp_on=$(cat "$FILE_PATH");
fi

builtin_display=$(echo "$displays" | sort -d -r | head -n1)
external_display=$(echo "$displays" | sort -d | head -n1)

echo "builtin_display = $builtin_display";
echo "external_display = $external_display";

if [ -z "$ext_dp_on" ]; then
    echo "Setting up external display";
    # we haven't switch to external display yet
    echo "$external_display" > "$FILE_PATH";
    xrandr --auto --output "$external_display" --same-as "$builtin_display";
    xrandr --auto;
    xrandr --output "$builtin_display" --off;
else
    # we've switch to external display and we now want to go back to builtin
    # display
    echo "Setting up builtin display";
    external_display="$ext_dp_on";
    rm "$FILE_PATH";
    xrandr --auto;
    xrandr --auto --output "$external_display" --left-of "$builtin_display";
    xrandr --output "$external_display" --off;
fi


