from typing import List, Set, Dict, Tuple, Text, Optional, AnyStr

def f(a: List[List[int]]) -> int:
    c: int = 0
    for b in a:
        c += sum(b)
    return c
