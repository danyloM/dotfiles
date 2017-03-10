# ~/.bash_profile: used for login shells, run at login either of the
# local computer or when starting an ssh session. Put non-bash related
# stuff here like setting the PATH/one-time configuration of the
# working environment.

# source .bashrc
# see http://stackoverflow.com/questions/820517/bashrc-at-ssh-login
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# personal additions to .bashrc
if [ -f ~/.local.bashrc ]; then
    . ~/.local.bashrc
fi

# add .bin directory to path, which includes custom
# user scripts
if [ -d ~/.bin ]; then
    PATH="${HOME}/.bin:$PATH"
fi

# add other things to PATH
if [ -d ~/.jetbrains/clion-2016.3.2/bin ]; then
    # Add CLion IDE to PATH
    PATH="${HOME}/.jetbrains/clion-2016.3.2/bin:$PATH"
fi
if [ -d ~/.jetbrains/pycharm-2016.3.2/bin ]; then
    # Add PyCharm IDE to PATH
    PATH="${HOME}/.jetbrains/pycharm-2016.3.2/bin:$PATH"
fi
if [ -d ~/.jetbrains/idea-IU-163.12024.16/bin ]; then
    # Add IntelliJ IDEA IDE to PATH
    PATH="${HOME}/.jetbrains/idea-IU-163.12024.16/bin:$PATH"
fi

export EDITOR=$(type -P emacsclient || type -P emacs || type -P nano)
export VISUAL=$EDITOR
