def fd(a):
    """
    @type a: dict(int=>str)
    """
    return len(a)

def fs(a):
    """
    @type a: set(str)
    """
    return len(a)

def fl(a):
    """
    @type a: list[int]
    """
    return len(a)


d = dict()
d[0] = "happy"
fd(d)

s = set(["happy"])
fs(s)
fl([1, 2, 3])
