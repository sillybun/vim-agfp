class A:
    def __init__(self):
        """
        @type self: __main__.A
        """
        self.A = 1

def f(a):
    """
    @type a: __main__.A
    """
    return a.A

a = A()
f(a)
