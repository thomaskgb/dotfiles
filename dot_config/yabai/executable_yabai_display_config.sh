#!/opt/homebrew/bin/zsh

if $wide_display_found; then
    # Configuration specific to wide screen monitors
    yabai -m config layout bsp

    # Add padding to windows when there is only 1 or 2 windows visible
    num_windows=$(yabai -m query --windows --space | jq '[.[] | select((.["is-visible"] == true) and (.["is-floating"] == false) and (.["id"] | tonumber != 0))] | length')
    if ((num_windows == 1)); then
        yabai -m config left_padding $(echo "$display_width * 0.6 / 2" | bc)
        yabai -m config right_padding $(echo "$display_width * 0.6 / 2" | bc)
            # Allow dynamic padding adjustment
        yabai -m signal --add event=window_resized action="configure_display"
        yabai -m signal --add event=window_moved action="configure_display"
        yabai -m signal --add event=window_floated action="configure_display"
    elif ((num_windows == 2)); then
        yabai -m config left_padding $(echo "$display_width * 0.3 / 2" | bc)
        yabai -m config right_padding $(echo "$display_width * 0.3 / 2" | bc)
    else
        yabai -m config left_padding $default_padding
        yabai -m config right_padding $default_padding
    fi

else
    # Configuration specific to non-wide screen monitors
    $yabai_config
    yabai -m config left_padding $default_padding
    yabai -m config right_padding $default_padding        
fi