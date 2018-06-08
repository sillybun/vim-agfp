def f(a, b=10):
    return a + b


class A:
    def f(self, a, b):
        return a + b

    def g(self, a, b):
        def f(a, b):
            return a + b
        return f(a, b)

def g(a, b):
    """
    @type a: int
    @type b: int
    @rtype: int
    """
    def f(a, b):
        """
        @type a: int
        @type b: int
        @rtype: int
        """
        return a + b
    return f(a, b)

addunit = A()
addunit.f(1, 2)
addunit.g(1, 2)

g(1, 2)

f(1, 2)
f(1.0, 2.0)
