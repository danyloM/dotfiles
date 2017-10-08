#!/bin/bash
# ------------------------------------------------------------------------------
#
# Installation of tools for engineering and, in particular, software/algorithms
# development.
#
# ------------------------------------------------------------------------------

echo_prefix_temp="$echo_prefix"
echo_prefix="[dev tools setup] "

# Latest version of Git
git_version="$(git --version | cut -d ' ' -f 3 | cut -d '.' -f 1)"
if [ "$git_version" -lt 2 ]; then
    # Need to upgrade Git
    apt_get_install_pkg python-software-properties
    runcmd "add-apt-repository ppa:git-core/ppa -y"
    runcmd "apt-get update"
    apt_get_install_pkg git
fi

# Gitk
# Visual viewer of git history
apt_get_install_pkg gitk

# Build tools like gcc, g++
apt_get_install_pkg build-essential

# Google logging library
apt_get_install_pkg libgoogle-glog-dev

# gdbserver
# Remote debugging
apt_get_install_pkg gdbserver

# Java 8
java_version=$(java -version 2>&1 | grep "java version")
if ! echo "$java_version" | grep "1.8" &>/dev/null; then # TODO change to a check whether version is *at least* 1.8 (e.g. 1.9 is OK, don't do anything then)
    apt_get_install_pkg python-software-properties
    runcmd "add-apt-repository ppa:webupd8team/java -y"
    runcmd "apt-get update"
    apt_get_install_pkg oracle-java8-installer nonull
    apt_get_install_pkg oracle-java8-set-default
fi

# Terminator (replace Gnome Terminal with Terminator)
# Terminal emulator
if program_not_installed "terminator"; then
    runcmd "add-apt-repository ppa:gnome-terminator -y"
    runcmd "apt-get update"
    apt_get_install_pkg terminator

    # Make Terminator the new Gnome Terminal!
    runcmd "apt-get purge -y gnome-terminal"
    runcmd "ln -s /usr/bin/terminator /usr/bin/gnome-terminal"
    runcmd "sudo apt-get install nautilus-open-terminal" # Open nautilus view in terminal
fi

# Other command line utilities
apt_get_install_pkg aptitude
apt_get_install_pkg xclip
apt_get_install_pkg silversearcher-ag
apt_get_install_pkg screen
apt_get_install_pkg htop
apt_get_install_pkg sshpass
apt_get_install_pkg tree
apt_get_install_pkg bash-completion
#apt_get_install_pkg rxvt-unicode

# Meld Diff Viewer
# It is a GUI analog to the standard diff install diffutils and patch install patch command line tools
apt_get_install_pkg meld

# ghex
# Hex editor
apt_get_install_pkg ghex

# Sunflower Twin-panel file manager
if program_not_installed "sunflower"; then
    runcmd "wget http://sunflower-fm.org/pub/sunflower-0.3.61-1.all.deb -O /tmp/sunflower.deb"
    runcmd_noexit "dpkg -i /tmp/sunflower.deb" nonull
    runcmd "apt-get --assume-yes install -f" nonull
fi

# tmux (version 2.3)
# Terminal multiplexer
if [ "$(tmux -V)" != "tmux 2.3" ]; then
    apt_get_install_pkg libevent-dev
    apt_get_install_pkg libncurses5-dev
    wget_targz_install "tmux-2.3" "https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz"
fi

## rr
# Debugging tool (recording & deterministic debugging)
if program_not_installed "rr"; then
    runcmd "wget https://github.com/mozilla/rr/releases/download/4.5.0/rr-4.5.0-Linux-$(uname -m).deb -O /tmp/rr.deb"
    runcmd "dpkg -i /tmp/rr.deb" nonull
fi

# Upgrade GDB to 7.12.1 (latest stable version)
# Includes many fixes, of which most important is the `set max-completions`
# Description: Sets the maximum number of candidates to be considered
# during completion. The default value is 200. This limit allows GDB
# to avoid generating large completion lists, the computation of which
# can cause the debugger to become temporarily unresponsive.
apt_get_install_pkg texinfo
gdbVersion="$(/bin/echo $(gdb --version) | cut -d ' ' -f 4)"
if [ "$gdbVersion" != "7.12.1" ]; then
    # TODO make check only that $gdbVersion < 7.12.1 (so as not to downgrade if in the future user has a more recent version installed)
    wget_targz_install "gdb-7.12.1" "http://ftp.gnu.org/gnu/gdb/gdb-7.12.1.tar.gz"
fi

# GCC 7.1
# C/C++ compiler
gccVersion="$(/bin/echo $(gcc --version) | cut -d ' ' -f 4)"
if [ "$gccVersion" != "7.1.0" ]; then
	runcmd "add-apt-repository ppa:ubuntu-toolchain-r/test -y"
    runcmd "apt-get update"
    apt_get_install_pkg gcc-7
    apt_get_install_pkg g++-7
    runcmd "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7"
fi

# .bashrc personal inclusions
source_local_bashrc=false
if ! grep -q ".local.bashrc" "${home}/.bashrc"; then
    source_local_bashrc=true
fi
if $source_local_bashrc; then
    # source .local.bashrc
    runcmd "eval builtin echo \"\" >> ${home}/.bashrc" nonull
    runcmd "eval builtin echo \"# personal additions to .bashrc\" >> ${home}/.bashrc" nonull
    runcmd "eval builtin echo \"if [ -f ~/.local.bashrc ]; then\" >> ${home}/.bashrc" nonull
    runcmd "eval builtin echo \"    . ~/.local.bashrc\" >> ${home}/.bashrc" nonull
    runcmd "eval builtin echo \"fi\" >> ${home}/.bashrc" nonull
fi

# Fix Unity bug that Ctrl-Alt-T creates a new icon in the Unity Dash
runcmd "gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'"

# Install Wine pre-requisites for running Windows programs on Linux
# In particular, I use it to run [Arbre Analyste](http://www.arbre-analyste.fr/)
if program_not_installed "winetricks"; then
    runcmd "dpkg --add-architecture i386"
    runcmd "add-apt-repository ppa:wine/wine-builds -y"
    runcmd "apt-get update"
    runcmd "apt-get install --assume-yes --install-recommends winehq-devel"
    apt_get_install_pkg winetricks
fi


####### Programs below are installed *only* if they are not already installed

# Install SmartGit
if ! dpkg -l | grep -E '^ii' | grep smartgit &>/dev/null; then
    runcmd "wget http://www.syntevo.com/static/smart/download/smartgit/smartgit-17_0_3.deb -O /tmp/smartgit.deb"
    runcmd_noexit "dpkg -i /tmp/smartgit.deb" nonull
    runcmd "apt-get --assume-yes install -f"
fi

# Install Jetbrains CLion (C/C++)
#
# Additional plugins that I use:
#   - CodeGlance
#   - .ignore
#   - Frame Switcher
#   - Markdown support
#   - Fast-Scrolling
if [ ! -d "${home}/.jetbrains/clion" ]; then
    runcmd "wget https://download.jetbrains.com/cpp/CLion-2017.2.1.tar.gz -O /tmp/clion.tar.gz"
    runcmd "rm -rf ${home}/.jetbrains/clion"
    runcmd "mkdir -p ${home}/.jetbrains/clion"
    runcmd "tar zxf /tmp/clion.tar.gz --strip 1 -C ${home}/.jetbrains/clion"
    runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} ${home}/.jetbrains/clion"
fi

# Install Jetbrains PyCharm (Python)
if [ ! -d "${home}/.jetbrains/pycharm" ]; then
    runcmd "wget https://download.jetbrains.com/python/pycharm-professional-2017.2.1.tar.gz -O /tmp/pycharm.tar.gz"
    runcmd "rm -rf ${home}/.jetbrains/pycharm"
    runcmd "mkdir -p ${home}/.jetbrains/pycharm"
    runcmd "tar zxf /tmp/pycharm.tar.gz --strip 1 -C ${home}/.jetbrains/pycharm"
    runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} ${home}/.jetbrains/pycharm"
fi

# Install R and RStudio
if program_not_installed "rstudio"; then
    # Install R
    runcmd "eval sh -c 'echo \"deb http://cran.rstudio.com/bin/linux/ubuntu trusty/\" >> /etc/apt/sources.list'"
    runcmd "eval su -c \"gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9\" ${SUDO_USER:-$USER}"
    runcmd "gpg -a --export E084DAB9 | sudo apt-key add -"
    runcmd "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9"
    runcmd "apt-get update"
    runcmd "apt-get install --assume-yes --force-yes r-base"

    # Install RStudio
    runcmd "wget https://download1.rstudio.org/rstudio-1.0.136-amd64.deb -P /tmp/"
    runcmd_noexit "dpkg -i /tmp/rstudio-1.0.136-amd64.deb"
    runcmd "apt-get --assume-yes install -f"
fi

##### NB: below, Eclipse installations are essentially of Eclipse [VERSION] Platform Runtime Binary, which is the barebones minimalist Eclipse version (without any junk plugins preinstalled)

# Install Eclipse for C/C++, XML Web
#
# Additional software to install:
#   - CDT (https://tinyurl.com/lq5r4vk)
#   - Eclipse Marketplace
#   - Remote System Explorer (http://download.eclipse.org/releases/neon --> General Purpose Tools/Remote System Explorer End-User Runtime)
#   - Darkest Dark Theme, DevStyle beta (https://tinyurl.com/ybgswz7v)
#   - EasyShell (http://anb0s.github.io/EasyShell --> EasyShell 2.0.x, PluginBox)
if [ ! -f "${home}/.eclipse/eclipse_common/eclipse" ]; then
    echowarn "Please read the instructions in comments of .setup/install_dev_tools.sh for follow-up installation actions inside Eclipse!"
    runcmd "wget http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.7-201706120950/eclipse-platform-4.7-linux-gtk-x86_64.tar.gz&r=1 -O /tmp/eclipse_common.tar.gz"
    runcmd "mkdir -p ${home}/.eclipse/eclipse_common"
    runcmd "tar zxf /tmp/eclipse_common.tar.gz --strip 1 -C ${home}/.eclipse/eclipse_common"
    runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} ${home}/.eclipse"
fi

# Install Eclipse for LaTeX, Markdown
# 
# Additional software to install:
#   - TeXlipse (http://texlipse.sourceforge.net --> Pdf4Eclipse, TeXlipse)
#   - Markdown editor (http://www.certiv.net/updates --> Certiv Tools/FluentMark Editor)
if [ ! -f "${home}/.eclipse/eclipse_latex/eclipse" ]; then
    echowarn "Please read the instructions in comments of .setup/install_dev_tools.sh for follow-up installation actions inside Eclipse!"
    runcmd "wget http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.7-201706120950/eclipse-platform-4.7-linux-gtk-x86_64.tar.gz&r=1 -O /tmp/eclipse_latex.tar.gz"
    runcmd "mkdir -p ${home}/.eclipse/eclipse_latex"
    runcmd "tar zxf /tmp/eclipse_latex.tar.gz --strip 1 -C ${home}/.eclipse/eclipse_latex"
    runcmd "eval chown -R ${SUDO_USER:-$USER}:${SUDO_USER:-$USER} ${home}/.eclipse"
fi


echo_prefix="$echo_prefix_temp"
