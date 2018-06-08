import numpy as np


def f(a):
    """
    @type a: numpy.ndarray
    """
    return a.sum()


a = np.random.rand(10)
f(a)
