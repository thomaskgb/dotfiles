display_width=$(yabai -m query --displays --display | jq '.frame.w' | bc -l | cut -d '.' -f 1)
display_height=$(yabai -m query --displays --display | jq '.frame.h')

wide_display_found=false
for width in $display_width; do
	if ((width >= 3440)); then
		wide_display_found=true
		break
	fi
done

export WIDE_DISPLAY=$wide_display_found

if $wide_display_found; then
	# Do something for wide displays
	echo "wide display found: $wide_display_found"
else
	# Do something for non-wide displays
	echo "wide display found: $wide_display_found"
fi
