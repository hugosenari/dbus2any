===============================
dbus2any
===============================

.. image:: https://img.shields.io/travis/hugosenari/dbus2any.svg
        :target: https://travis-ci.org/hugosenari/dbus2any

.. image:: https://img.shields.io/pypi/v/dbus2any.svg
        :target: https://pypi.python.org/pypi/dbus2any


convert dbus instrospection to code

* Free software: ISC license
* Documentation: https://dbus2any.readthedocs.org.

Features
--------

* Convert xml into python-dbus client


examples
--------

MPRIS2 media players

> python -m dbus2any -t pydbusclient.tpl -n 'org.mpris.MediaPlayer2.gmusicbrowser' -p '/org/mpris/MediaPlayer2'

> python -m dbus2any -t pydbusclient.tpl -n 'org.mpris.MediaPlayer2.vlc' -p '/org/mpris/MediaPlayer2'

Pidgin (libpurple)

> python -m dbus2any -t pydbusclient.tpl -n 'im.pidgin.purple.PurpleService' -p '/im/pidgin/purple/PurpleObject'

