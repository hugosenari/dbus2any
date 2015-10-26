'''
Created with dbus2any

https://github.com/hugosenari/dbus2any


This code require python-dbus

Parameters:
{% if args.template %}
* {{ args.template }}{% endif %}{% if args.xml %}
* {{ args.xml }}{% endif %}{% if args.objectPath %}
* {{ args.objectPath }}{% endif %}{% if args.busName %}
* {{ args.busName }}{% endif %}{% if args.interface %}
* {{ args.interface }}{% endif %}

See also:
    http://dbus.freedesktop.org/doc/dbus-specification.html
    http://dbus.freedesktop.org/doc/dbus-python/doc/tutorial.html
'''

import dbus
{% macro translate_params(arg) -%}{% if arg.attrib.type == 'y'
%}BYTE{% elif arg.attrib.type == 'b'
%}BOOLEAN{% elif arg.attrib.type == 'n'
%}INT16{% elif arg.attrib.type == 'q'
%}UINT16{% elif arg.attrib.type == 'i'
%}INT32{% elif arg.attrib.type == 'u'
%}UINT32{% elif arg.attrib.type == 'x'
%}INT64{% elif arg.attrib.type == 't'
%}UINT64{% elif arg.attrib.type == 'd'
%}DOUBLE{% elif arg.attrib.type == 's'
%}STRING{% elif arg.attrib.type == 'o'
%}OBJECT_PATH{% elif arg.attrib.type == 'g'
%}SIGNATURE{% elif arg.attrib.type == 'a'
%}ARRAY{% elif arg.attrib.type == 'v'
%}VARIANT{% elif arg.attrib.type == 'h'
%}UNIX_FD{% else
%}{{arg.attrib.type}}{% endif
%}{%- endmacro %}
{% macro print_member(member) -%}{%
if member.tag == 'method' %}
    def {{ member.attrib.name }}(self, *arg, **kw):
        '''
        Method (call me)
        {% if member.findall('./arg[@direction="in"]')
        %}params:
            {% for arg in member.findall('./arg[@direction="in"]') %}{{ arg.attrib.name }}: {{ translate_params(arg) }}
            {% endfor %}
        {% endif %}{%
        if member.findall('./arg[@direction="out"]')
        %}return:
            {% for arg in member.findall('./arg[@direction="out"]') %}{{ arg.attrib.name }}: {{ translate_params(arg) }}
            {% endfor %}{%
        endif %}
        See also:
            http://dbus.freedesktop.org/doc/dbus-specification.html#idp94392448
        '''
        return self._dbus_interface.{{ member.attrib.name }}(*arg, **kw)
{% elif member.tag == 'property' %}
    @property
    def {{ member.attrib.name }}(self):
        '''
        Property (acess me)
        Type:
            {{ translate_params(member) }} {{ member.attrib.access }}

        See also:
            http://dbus.freedesktop.org/doc/dbus-specification.html#idp94392448
        '''
        return self._get_property('{{ member.attrib.name }}')
    {% if member.attrib.access == 'readwrite' %}
    @{{ member.attrib.name }}.setter
    def {{ member.attrib.name }}(self, value):
        self._set_property('{{ member.attrib.name }}', value)
    {%endif
%}{% elif member.tag == 'signal' %}
    def {{ member.attrib.name }}(self, callback):
        '''
        Signal (wait for me)
        callback params:
            {% for arg in member %}{{ arg.attrib.name }} {{ translate_params(arg) }}
            {% endfor %}
        See also:
            http://dbus.freedesktop.org/doc/dbus-specification.html#idp94392448s
        '''
        self._dbus_interface.connect_to_signal('{{ member.attrib.name }}', callback)
        return self
{% endif
%}{%- endmacro %}
{% for interface in node.findall('interface') %}
class {{ interface.attrib.name.split('.')[-1] }}(object):
    '''
    {{ interface.attrib.name }}

    Usage:
    ------

    Instantiate this class and access the instance members and methods

    >>> obj = {{ interface.attrib.name.split('.')[-1] }}({% if not args.busName %}BUS_NAME{% endif %}{% if not args.objectPath %}, OBJECT_PATH{% endif %})

    '''

    def __init__(self, bus_name{% if args.busName %}=None{% endif %}, object_path{% if args.objectPath %}=None{% endif %}, interface=None, bus=None):
        '''Constructor'''
        self._dbus_interface_name = interface or "{{ interface.attrib.name }}"
        self._dbus_object_path = object_path {% if args.objectPath %}or "{{ args.objectPath }}"{% endif %}
        self._dbus_name = bus_name {% if args.busName %}or "{{ args.busName }}"{% endif %}

        bus = bus or dbus.SessionBus()
        self._dbus_object =  bus.get_object(self._dbus_name, self._dbus_object_path)
        self._dbus_interface = dbus.Interface(self._dbus_object,
            dbus_interface=self._dbus_interface_name)
        self._dbus_properties = obj = dbus.Interface(self._dbus_object,
            "org.freedesktop.DBus.Properties")

    def _get_property(self, name):
        return self._dbus_properties.Get(self._dbus_interface_name, name)

    def _set_property(self, name, val):
        return self._dbus_properties.Set(self._dbus_interface_name, name, val)

    {% for member in interface %}{{ print_member(member) }}{% endfor %}
{% endfor %}