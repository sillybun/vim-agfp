from functools import wraps

FUNCTIONPARAMETERS = dict()


def recordparametertype(func):

    def gettypename(sth):
        _type = type(sth)
        if isinstance(sth, list) and len(sth) > 0:
            return "list[" + gettypename(sth[0]) + "]"
        elif isinstance(sth, tuple) and len(sth) > 0:
            return "tuple(" + gettypename(sth[0]) + ")"
        elif isinstance(sth, set) and len(sth) > 0:
            return "set(" + gettypename(list(sth)[0]) + ")"
        elif isinstance(sth, dict) and len(sth) > 0:
            key = list(sth.keys())[0]
            return "dict(" + gettypename(key) + "=>" + gettypename(sth[key]) + ")"
        else:
            typestr = str(_type)
            return typestr[(typestr.find("'") + 1
                            ):typestr.rfind("'")].split(".")[-1]

    global FUNCTIONPARAMETERS

    @wraps(func)
    def wrapper(*args, **kwargs):
        if func not in FUNCTIONPARAMETERS:
            FUNCTIONPARAMETERS[func] = dict()
            for i, arg in enumerate(args):
                FUNCTIONPARAMETERS[func][i] = set([gettypename(arg)])
        else:
            for i, arg in enumerate(args):
                FUNCTIONPARAMETERS[func][i].add(gettypename(arg))
        result = func(*args, **kwargs)
        return result

    return wrapper


def logfunctionparameters():
    logfile = open(".AGFPparameters.log", "w")
    for key, value in FUNCTIONPARAMETERS.items():
        logfile.write(key.__qualname__ + ">>")
        for pnum, ptype in value.items():
            logfile.write(str(pnum) + ":")
            logfile.write(",".join(list(ptype)) + ";")
        logfile.write("\n")


if __name__ == "__main__":

    class A:

        @recordparametertype
        def f(self, a, b):
            return a + b

    a = A()
    a.f(1, 2)
    a.f(1, 2.0)

    @recordparametertype
    def g(b):
        return len(b)

    g(range(10))
    g([1, 2, 3])
