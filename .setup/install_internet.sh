#!/bin/bash
# ----------------------------------------------------------------------
#
# Installation of Internet/Web applications.
#
# ----------------------------------------------------------------------

echo_prefix_temp="$echo_prefix"
echo_prefix="[internet setup] "

# Google Chrome
if program_not_installed "google-chrome"; then
    apt_get_install_pkg libxss1
    apt_get_install_pkg libappindicator1
    apt_get_install_pkg libindicator7
    runcmd "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb"
    runcmd_noexit "dpkg -i /tmp/chrome.deb" nonull
    runcmd "apt-get --assume-yes install -f" nonull
fi

# Dropbox
if program_not_installed "dropbox"; then
	apt_get_install_pkg dropbox
fi

# Google Drive client for the commandline
# https://github.com/odeke-em/drive
if [ ! -f "${home}/gopath/bin/drive" ]; then
	# Install the Go programming language
	GOPATH="${home}/gopath"
	if [ ! -d "/usr/local/go" ]; then
		runcmd "wget https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz -O /tmp/go_language.tar.gz"
		runcmd "tar zxf /tmp/go_language.tar.gz -C /tmp/"
		runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} /tmp/go"
		runcmd "mv /tmp/go /usr/local"
		# Make path for Go
		runcmd "mkdir -p $GOPATH"
		runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} $GOPATH"
	fi
	# Install Google Drive client
	(runcmd "export GOPATH=$GOPATH" && runcmd "/usr/local/go/bin/go get -u github.com/odeke-em/drive/cmd/drive")
fi

# Rclone
# "rsync for cloud storage"
# Rclone is a command line program to sync files and directories to and from cloud services (Google Drive, Dropbox, etc.)
# Installation instructions taken from https://rclone.org/install/
if program_not_installed "rclone"; then
	# Fetch and unpack
	runcmd "wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O /tmp/rclone.zip"
	runcmd "unzip /tmp/rclone.zip -d /tmp/"
	# Copy binary file
	runcmd "cp /tmp/rclone-*-linux-amd64/rclone /usr/bin/"
	runcmd "chown root:root /usr/bin/rclone"
	runcmd "chmod 755 /usr/bin/rclone"
	# Install manpage
	runcmd "mkdir -p /usr/local/share/man/man1"
	runcmd "cp /tmp/rclone-*-linux-amd64/rclone.1 /usr/local/share/man/man1/"
	runcmd "mandb"
fi

echo_prefix="$echo_prefix_temp"
