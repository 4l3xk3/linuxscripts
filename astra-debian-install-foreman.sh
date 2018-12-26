#!/bin/bash

# AstraLinux SE 1.6, AstraLinux CE 2.12, Debian stretch, foreman installer
# ========================================================================
# Author: Alexey Kovin <4l3xk3@gmail.com>
# All rights reserved
# Russia, Electrostal, 2018

# Localization
# ------------
function echo_en () {
    if [ x"$LANG" != "xru_RU.UTF-8" ]; then
        echo "$1"
    fi
}

function echo_ru () {
    if [ x"$LANG" = "xru_RU.UTF-8" ]; then
        echo "$1"
    fi
}

# Check EUID
# ----------
echo "EUID=$EUID"
if [ x"$EUID" != "x0" ]; then
    echo_ru "Запустите программу с правами администратора системы (sudo) (root) .."
    echo_en "Launch program as administrator (sudo) (root) .."
    exit 1
fi

# sources.list
# ------------
echo_ru "Создание /etc/apt/sources.list.d/foreman.conf .."
echo_en "Creating /etc/apt/sources.list.d/foreman.conf .."
echo "deb http://deb.theforeman.org/ stretch 1.20" > /etc/apt/sources.list.d/foreman.list
echo "deb http://deb.theforeman.org/ plugins 1.20" >> /etc/apt/sources.list.d/foreman.list

echo_ru "Добаление ключа foreman в APT .."
echo_en "Add foreman key to APT .."

wget -q https://deb.theforeman.org/pubkey.gpg -O- | apt-key add -

echo_ru "Установка foreman .."
echo_en "Install foreman .."

apt update
apt install foreman foreman-sqlite3 foreman-libvirt ruby-logging


if [ -f /etc/foreman/database.yml ] ; then
    echo_ru "Настройка foreman .."
    echo_en "Tune foreman .."

    cp /usr/share/foreman/config/database.yml.example /etc/foreman/database.yml

    mcedit /etc/foreman/settings.yaml 
    mcedit /etc/foreman/database.yml

    foreman-rake db:migrate
    foreman-rake db:seed
fi
