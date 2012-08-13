

class AttributeDictionary(dict):

    def __init__(self, init=None):
        if not init: init = dict()
        dict.__init__(self, init)

    def __getstate__(self):
        return self.__dict__.items()

    def __setstate__(self, items):
        for key, val in items:
            self.__dict__[key] = val

    def __repr__(self):
        return "%s(%s)" % (self.__class__.__name__, dict.__repr__(self))

    def __setitem__(self, key, value):
        return super(AttributeDictionary, self).__setitem__(key, value)

    def __getitem__(self, name):
        return super(AttributeDictionary, self).__getitem__(name)

    def __delitem__(self, name):
        return super(AttributeDictionary, self).__delitem__(name)

    __getattr__ = __getitem__
    __setattr__ = __setitem__

    def copy(self):
        ch = AttributeDictionary(self)
        return ch
