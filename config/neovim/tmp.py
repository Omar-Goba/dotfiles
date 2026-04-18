import math as m


def main() -> int:
    """
    hello
    """
    x: int = 1
    y: int = 2
    z: bool = True
    CONST: int = 3
    list_: list[int] = [1, 2, 3]

    # loop
    for i in list_:
        x += i
        y += i

    if z:
        print("hi")

    list_two_: list[int] = list(map(lambda i: i + 1, list_))
    result: int = x + y + CONST + sum(list_two_)

    return result


if __name__ == "__main__":
    main()
    print("Hello, World!")
    print(m.sqrt(4))
    print(m.factorial(5))
    print(m.pi)
    print(m.e)
    print(m.tau)
    print(m.inf)
    print(m.nan)
