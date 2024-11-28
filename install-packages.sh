#!/bin/bash

install_apt_packages() {
    local apt_file="apt-packages.txt"

    if [[ ! -f $apt_file ]]; then
        echo "Error: $apt_file not found. Ensure the file exists and try again."
        return 1
    fi

    echo "Starting installation of apt packages from $apt_file..."

    while IFS= read -r line; do
        package_name=$(echo "$line" | awk -F/ '{print $1}') # Extract package name
        if dpkg -l | grep -q "^ii\s\+$package_name"; then
            echo "Package '$package_name' is already installed. Skipping."
        else
            echo "Installing package '$package_name'..."
            if sudo apt-get install -y "$package_name"; then
                echo "Successfully installed '$package_name'."
            else
                echo "Error installing '$package_name'. Skipping."
            fi
        fi
    done < <(grep -E '^[a-zA-Z0-9]' "$apt_file") # Filter valid package lines
}

install_snaps() {
    local snap_file="snap-packages.txt"

    if [[ ! -f $snap_file ]]; then
        echo "Error: $snap_file not found. Ensure the file exists and try again."
        return 1
    fi

    echo "Starting installation of snap packages from $snap_file..."

    while IFS= read -r line; do
        package_name=$(echo "$line" | awk '{print $1}') # Extract package name
        if snap list | grep -q "^$package_name\s"; then
            echo "Snap package '$package_name' is already installed. Skipping."
        else
            echo "Installing snap package '$package_name'..."
            if sudo snap install "$package_name"; then
                echo "Successfully installed snap package '$package_name'."
            else
                echo "Error installing snap package '$package_name'. Skipping."
            fi
        fi
    done < <(tail -n +2 "$snap_file") # Skip header row
}

echo "Installing packages..."

install_apt_packages
install_snaps

echo "Package installation complete."
