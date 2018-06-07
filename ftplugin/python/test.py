def f(a, b):
    """
    @type a: int,float
    @type b: int,float
    """
    return a + b


class A:
    def f(self, a, b):
        """
        @type self: A
        @type a: int
        @type b: int
        """
        return a + b

    def g(self, a, b):
        """
        @type self: A
        @type a: int
        @type b: int
        """
        def f(a, b):
            """
            @type a: int
            @type b: int
            """
            return a + b
        print(f.__qualname__)
        return f(a, b)

def g(a, b):
    """
    @type a: int
    @type b: int
    """
    def f(a, b):
        """
        @type a: int
        @type b: int
        """
        return a + b
    print(f.__qualname__)
    return f(a, b)

addunit = A()
addunit.f(1, 2)
addunit.g(1, 2)

g(1, 2)

f(1, 2)
f(1.0, 2.0)
parameters.logfunctionparameters()
parameters.logfunctionparameters()
