#!/bin/bash
# ----------------------------------------------------------------------
#
# Installation of tools for better Python programming experience.
#
# ----------------------------------------------------------------------

echo_prefix_temp="$echo_prefix"
echo_prefix="[python tools setup] "

########################
####### Jupyter notebook
#######################
# Instructions from:
# http://bikulov.org/blog/2015/11/07/install-jupyter-notebook-and-scientific-environment-in-ubuntu-14-dot-04-with-python-3/

### Install prerequisites

# install curl virtualenvwrapper
apt_get_install_pkg curl
apt_get_install_pkg virtualenvwrapper

# install as workaround for https://github.com/matplotlib/matplotlib/issues/3029/
apt_get_install_pkg pkg-config

# install g++
apt_get_install_pkg g++

# install dependencies for scipy
apt_get_install_pkg libblas-dev
apt_get_install_pkg liblapack-dev
apt_get_install_pkg gfortran

# install some dependencies for matplotlib
apt_get_install_pkg libfreetype6-dev
apt_get_install_pkg libpng-dev
apt_get_install_pkg libjpeg8-dev


### Now create and activate virtualenv, install all the packages via pip

# create and activate virtual environment using mkvirtualenv wrapper (env name is jupnb)
# if [ ! -d "${home}/.python_venv/jupnb" ]; then
#     runcmd "sudo -u ${normal_user} /usr/local/bin/virtualenv --no-setuptools --python /usr/bin/python3.4 ${home}/.python_venv/jupnb"
# fi
# runcmd ". ${home}/.python_venv/jupnb/bin/activate"

# install fresh setuptools
runcmd "sudo -H pip install setuptools distribute"

# install numpy as it is dependecy for many others
runcmd "sudo -H pip install numpy"

# install scientific packages (seaborn instead of matplotlib for pretty plots)
runcmd "sudo -H pip install sympy scipy seaborn pandas jupyter"

# install scikit-learn separately, it depends on numpy and scipy
runcmd "sudo -H pip install scikit-learn"

######## Setup virtualenvs
runcmd "sudo -u ${normal_user} mkdir -p ${home}/.python_venv"
runcmd "sudo -u ${normal_user} python -m pip install virtualenv --user"

# configure python2 kernel
runcmd "sudo -u ${normal_user} python -m virtualenv -p python2 ${home}/.python_venv/py2_kernel"
runcmd ". ${home}/.python_venv/py2_kernel/bin/activate"
runcmd "sudo -H python -m pip install ipykernel"
runcmd "ipython kernel install --name py2 --user"
runcmd "deactivate"

# configure python3 kernel
runcmd "sudo -u ${normal_user} python -m virtualenv -p python3 ${home}/.python_venv/py3_kernel"
runcmd "source ${home}/.python_venv/py3_kernel/bin/activate"
runcmd "sudo -H python -m pip install ipykernel"
runcmd "ipython kernel install --name py3 --user"
runcmd "deactivate"

(runcmd "sudo -u ${normal_user} mkdir -p ${home}/.jupyter" && \
	runcmd "cd ${home}/.jupyter" && \
	runcmd "eval chown -R ${normal_user}:${normal_user} \"${home}/.local/share/jupyter\"")
#runcmd "sudo -u ${normal_user} jupyter notebook --generate-config" nonull
#runcmd "eval chown -R ${normal_user}:${normal_user} \"${home}/.jupyter\""
 

echo_prefix="$echo_prefix_temp"