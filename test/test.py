def f(a, b=10):
    """
    @type a: float
    @type b: float
    @rtype: float
    """
    return a + b


class A:
    def f(self, a, b):
        """
        @type self: __main__.A
        @type a: int
        @type b: int
        @rtype: int
        """
        return a + b

    def g(self, a, b):
        """
        @type self: __main__.A
        @type a: int
        @type b: int
        @rtype: int
        """
        def f(a, b):
            return a + b
        return f(a, b)

def g(a, b):
    """
    @type a: int
    @type b: float
    @rtype: float
    """
    def f(a, b):
        """
        @type a: int
        @type b: float
        @rtype: float
        """
        return a + b
    return f(a, b)

addunit = A()
addunit.f(1, 2)

g(1, 2.0)

f(1.0, 2.0)
