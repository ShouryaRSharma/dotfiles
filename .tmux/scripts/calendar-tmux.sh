#!/bin/bash

# calendar-tmux.sh
# Shows next event in tmux status-right if it's within 10 minutes
# Displays a popup warning if it's within 1 minute
#
# Dependencies:
# - icalBuddy: https://formulae.brew.sh/formula/ical-buddy
# - ansi2txt: https://github.com/gabe565/ansi2txt
# - tmux: https://github.com/tmux/tmux/wiki

# Get today's events and clean ANSI escape codes
all_events=$(icalBuddy -f -ea -n -b "*" -eep "attendees" eventsToday | ansi2txt)

# If no event data is found, exit
test -z "$all_events" && echo "#{E:@catppuccin_status_application}" && exit 0

# Get current time in minutes since midnight
current_hour=$(date +%H)
current_min=$(date +%M)
current_mins=$((current_hour * 60 + current_min))

# Initialize variables to track the next event
next_event=""
next_event_time=""
next_event_url=""
mins_until_next=1000 # Set a high initial value

# Process events as blocks instead of line-by-line
current_event=""
current_time=""
current_url=""

while IFS= read -r line; do
	if [[ $line == \** ]]; then
		# New event starts, process the previous one
		if [[ -n "$current_event" && -n "$current_time" ]]; then
			start_time=$(echo "$current_time" | grep -oE '[0-9]{1,2}:[0-9]{2}' | head -n 1)
			start_hour=$(echo "$start_time" | cut -d':' -f1)
			start_min=$(echo "$start_time" | cut -d':' -f2)
			start_mins=$((start_hour * 60 + start_min))
			mins_until=$((start_mins - current_mins))

			# Check if it's the soonest upcoming event
			if [ $mins_until -gt 0 ] && [ $mins_until -lt $mins_until_next ]; then
				mins_until_next=$mins_until
				next_event="$current_event"
				next_event_time="$current_time"
				next_event_url="$current_url"
			fi
		fi

		# Start a new event block
		current_event="$line"
		current_time=""
		current_url=""
	elif [[ $line =~ [0-9]{1,2}:[0-9]{2}\ -\ [0-9]{1,2}:[0-9]{2} ]]; then
		current_time="$line"
	elif [[ $line =~ https://meet\.google\.com/[a-zA-Z0-9-]+ ]]; then
		current_url=$(echo "$line" | grep -oE 'https://meet\.google\.com/[a-zA-Z0-9-]+')
	fi
done <<<"$all_events"

# Process the last event (if applicable)
if [[ -n "$current_event" && -n "$current_time" ]]; then
	start_time=$(echo "$current_time" | grep -oE '[0-9]{1,2}:[0-9]{2}' | head -n 1)
	start_hour=$(echo "$start_time" | cut -d':' -f1)
	start_min=$(echo "$start_time" | cut -d':' -f2)
	start_mins=$((start_hour * 60 + start_min))
	mins_until=$((start_mins - current_mins))

	if [ $mins_until -gt 0 ] && [ $mins_until -lt $mins_until_next ]; then
		mins_until_next=$mins_until
		next_event="$current_event"
		next_event_time="$current_time"
		next_event_url="$current_url"
	fi
fi

# If no upcoming events were found, exit
test -z "$next_event" && echo "#{E:@catppuccin_status_application}" && exit 0

# Extract the event name
name=$(echo "$next_event" | sed -E 's/^\*|\([^)]*\)//g' | xargs)
next_event_time=$(echo "$next_event_time" | xargs)

# Show event in tmux status-right if it's within 10 minutes
if [ $mins_until_next -le 10 ]; then
	echo "📅 $name (${next_event_time})"

	# If event is within 1 minute, display a popup warning
	if [ $mins_until_next -le 1 ]; then
		TMP_SCRIPT=$(mktemp)
		cat >"$TMP_SCRIPT" <<EOF
#!/bin/bash

echo ''
echo '╭───────────────────────────────────────────────────────────╮'
echo '│                   ⚠️  MEETING STARTING  ⚠️                  │'
echo '╰───────────────────────────────────────────────────────────╯'
echo ''
echo '  📅 $name'
echo '  🕒 $next_event_time'
echo '  🔗 ${next_event_url:-No URL available}'
echo ''
echo '  Meeting starts in $mins_until_next minute(s)!'
echo '  Press o to open the meeting URL'
echo '  Press Escape to close this window'
echo ''

sleep 30 && exit 0 &

while true; do
  read -s -n 1 key
  if [[ \$key == "o" ]]; then
    ${next_event_url:+open "$next_event_url"}
    exit 0
  fi
done
EOF

		chmod +x "$TMP_SCRIPT"

		(
			tmux display-popup -w 80 -h 16 -s "bg=#242933,fg=#D8DEE9" "$TMP_SCRIPT"
			rm "$TMP_SCRIPT"
		) &
	fi
else
	echo "#{E:@catppuccin_status_application}"
fi
