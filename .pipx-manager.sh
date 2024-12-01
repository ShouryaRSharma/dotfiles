#!/bin/bash

BACKUP_JSON="$HOME/dotfiles/pipx_installations.json"

backup_installations() {
	echo "Backing up pipx installations..."
	pipx list --json >"$BACKUP_JSON"
	echo "Backup created at: $BACKUP_JSON"
}

restore_installations() {
	if [ ! -f "$BACKUP_JSON" ]; then
		echo "Backup file not found at $BACKUP_JSON"
		exit 1
	fi

	echo "Restoring pipx installations..."

	# Process the JSON backup to handle special cases:
	# - Packages with specific versions (e.g., poetry==1.4.2)
	# - Packages with suffixes (e.g., poetry@1.4.2)
	# - Standard packages (e.g., pocker-tui)
	while IFS= read -r line; do
		# Extract package specification and any suffix
		# Example: poetry==1.4.2 @1.4.2
		package_spec=$(echo "$line" | cut -f1)
		suffix=$(echo "$line" | cut -f2)

		if [ ! -z "$package_spec" ]; then
			echo "Installing $package_spec..."

			install_cmd="pipx install $package_spec"

			# Handle packages that were installed with suffixes
			# This maintains separate versions of the same package
			# Example: poetry@1.4.2 alongside latest poetry
			if [ ! -z "$suffix" ] && [ "$suffix" != "null" ]; then
				install_cmd="$install_cmd --suffix $suffix"
			fi

			echo "Running: $install_cmd"
			eval "$install_cmd"
		fi
	done < <(jq -r '.venvs | to_entries[] | 
        .value.metadata.main_package | 
        [.package_or_url, .suffix] | 
        @tsv' "$BACKUP_JSON")

	echo "Restoration complete!"
}

case "$1" in
"backup")
	backup_installations
	;;
"restore")
	restore_installations
	;;
*)
	echo "Usage: $0 {backup|restore}"
	echo "  backup  - Create backup of current pipx installations"
	echo "  restore - Restore pipx installations from backup"
	exit 1
	;;
esac
