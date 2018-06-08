def count(line, prev):
    """
    @type line: str
    @type prev: tuple(int)
    """
    line = line.strip()
    leftnum = prev[0]
    rightnum = prev[1]
    condition = prev[2]
    i = 0
    while i < len(line):
        if condition == '"':
            if line[i] == "\\":
                i += 2
            elif line[i] == '"':
                condition = None
                i += 1
            else:
                i += 1
        elif condition == "'":
            if line[i] == "\\":
                i += 2
            elif line[i] == "'":
                condition = None
                i += 1
            else:
                i += 1
        else:
            if line[i] == "(":
                leftnum += 1
            elif line[i] == ")":
                rightnum += 1
            elif line[i] == '"':
                condition = '"'
            elif line[i] == "'":
                condition = "'"
            i += 1
    return (leftnum, rightnum, condition)




if __name__ == "__main__":
    print(count("def f(a=\"(\"", (0, 0, None)))
