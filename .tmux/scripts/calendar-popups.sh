#!/bin/bash
# next_event_popup.sh

# # Dependencies:
# - icalBuddy: https://formulae.brew.sh/formula/ical-buddy
# - ansi2txt: https://github.com/gabe565/ansi2txt
# - tmux: https://github.com/tmux/tmux/wiki

# Get today's events and clean ANSI escape codes
all_events=$(icalBuddy -f -ea -n -b "*" -eep "attendees" eventsToday | ansi2txt)

# If no event data is found, display a message in the tmux popup and exit
if [ -z "$all_events" ]; then
	tmux display-popup -s "bg=#242933,fg=#D8DEE9" "echo 'No events found for today.'"
	exit 0
fi

# Extract Google Meet URLs
meet_urls=$(echo "$all_events" | grep -oE 'https://meet\.google\.com/[a-zA-Z0-9-]+')

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
			# Extract start time
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
		# Capture event time
		current_time="$line"
	elif [[ $line =~ https://meet\.google\.com/[a-zA-Z0-9-]+ ]]; then
		# Capture the Google Meet URL
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

# If no upcoming events were found
if [ -z "$next_event" ]; then
	tmux display-popup -s "bg=#242933,fg=#D8DEE9" "echo 'No upcoming events found for today.'"
	exit 0
fi

if [ $mins_until_next -lt 60 ]; then
	# Less than an hour - show minutes
	time_remaining="Starts in $mins_until_next minute"
	# Add 's' for plural if not exactly 1 minute
	if [ $mins_until_next -ne 1 ]; then
		time_remaining="${time_remaining}s"
	fi
else
	# More than an hour - show in hours and minutes
	hours=$((mins_until_next / 60))
	remaining_mins=$((mins_until_next % 60))

	# Format the string based on values
	if [ $remaining_mins -eq 0 ]; then
		# Exactly on the hour
		time_remaining="Starts in $hours hour"
		if [ $hours -ne 1 ]; then
			time_remaining="${time_remaining}s"
		fi
	else
		# Hours and minutes
		time_remaining="Starts in $hours hour"
		if [ $hours -ne 1 ]; then
			time_remaining="${time_remaining}s"
		fi
		time_remaining="$time_remaining, $remaining_mins minute"
		if [ $remaining_mins -ne 1 ]; then
			time_remaining="${time_remaining}s"
		fi
	fi
fi
# Extract the event name (removing email addresses and extra spaces)
name=$(echo "$next_event" | sed -E 's/^\*|\([^)]*\)//g' | xargs)

next_event_time=$(echo "$next_event_time" | xargs)

# If no URL is found, set a default message
if [ -z "$next_event_url" ]; then
	url="No URL available"
	url_action="echo 'No URL available'"
else
	url="$next_event_url"
	url_action="open '$url'"
fi

# Create a temporary script for the popup
TMP_SCRIPT=$(mktemp)
cat >"$TMP_SCRIPT" <<EOF
#!/bin/bash
echo ''
echo '╭───────────────────────────────────────────────────────────╮'
echo '│                      NEXT MEETING                         │'
echo '╰───────────────────────────────────────────────────────────╯'
echo ''
echo '  📅 $name'
echo '  🕒 $next_event_time'
echo '  🔗 $url'
echo ''
echo '  $time_remaining'
echo ''
echo '  Press o to open the meeting URL'
echo '  Press Escape to close this window'
# Wait for key press
while true; do
  read -s -n 1 key
  if [[ \$key == "o" ]]; then
    $url_action
    exit 0
  fi
done
EOF
chmod +x "$TMP_SCRIPT"

# Display the popup
tmux display-popup -w 70 -h 16 -s "bg=#242933,fg=#D8DEE9" "$TMP_SCRIPT"

# Clean up the temporary script
rm "$TMP_SCRIPT"
