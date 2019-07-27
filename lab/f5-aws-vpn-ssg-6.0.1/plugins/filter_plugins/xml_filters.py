#!/usr/bin/python
# by Tim Rupp t.rupp@f5.com

import xmltodict
import json

def xml_to_dict(arg):
    return json.dumps(xmltodict.parse(arg))

class FilterModule(object):
    def filters(self):
        return {
            'xml_to_dict': xml_to_dict
        }
