import math
import numpy as np
import random
from Crypto.Util import number
from Crypto.Util.number import inverse

def MonPro(a_bar, b_bar, n, k, debug = False):
    if debug:
        print()
        print("Monpro:")

    u = 0
    for i in range(k):
        if debug:
            print(f"I: {i+1}:")

        odd = (u&1) ^ ((b_bar&1) and ((a_bar >> i)&1))
        ai = ((a_bar >> i)&1)
        
        if debug:
            if (ai and odd):
                print("Case 1")
            elif (ai and not odd):
                print("Case 2")
            elif (not ai and odd):
                print("Case 3")
            else:
                print("Case 4")

        u = u + ((a_bar >> i) & 1) * b_bar
        if debug:
            print(f"u: {u:065x}")
        if u & 1:
            u = u + n
        u = u >> 1

        if debug:
            print(f"Un+1 : {u:064x}")
            print("")

    if (u >= n):
        u -= n

    if debug:
        print(f"U = {u:064x}")
    return u

def RSA_Montgomery(M, e, n, k):
    # Precomputed
    r = 1 << k
    x_bar = r % n
    r_square = (r * r) % n

    print(f"x_bar: \t{x_bar:064x}")
    print(f"r_square: \t{r_square:064x}")
    print()

    # Main algorithm
    M_bar = MonPro(M, r_square, n, k)
    print(f"M_bar: {M_bar:064x}")
    print()

    for i in range(k - 1, -1, -1):
        print(f"I: {i}")
        print(f"x_bar: {x_bar:064x}")
        print(f"n: {n:064x}")
        x_bar = MonPro(x_bar, x_bar, n, k, i == 9)
        print(f"x_bar: {x_bar:064x}")
        print()

        if (e >> i) & 1:
            print(f"M_bar: {M_bar:064x}")
            print(f"x_bar: {x_bar:064x}")
            print(f"n: {n:064x}")
            x_bar = MonPro(M_bar, x_bar, n, k)
            print(f"x_bar: {x_bar:064x}")
            print()

    x = MonPro(x_bar, 1, n, k)

    return x

def ModularExponentiationVerify(base, exp, mod):
    result = 1
    base = base % mod

    while exp > 0:
        if exp % 2 == 1:
            result = (result * base) % mod
        
        base = (base * base) % mod
        exp = exp // 2

    return result

k = 256


M = 0x0a23232323232323232323232323232323232323232323232323232323232323
E = 0x0000000000000000000000000000000000000000000000000000000000010001
N = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
X = 0x85EE722363960779206A2B37CC8B64B5FC12A934473FA0204BBAAF714BC90C01

res = RSA_Montgomery(M, E, N, k)
print(hex(res))

# p = number.getPrime(127)
# q = number.getPrime(127)
# n = (p * q)
# phi = (p - 1) * (q - 1)
#
# assert(n < (1 << k))
#
# e = 65537
# d = inverse(e, phi)
#
# M = 12312321321421
#
# x_mont_encrypt = RSA_Montgomery(M, e, n, k)
# x_verify_encrypt = ModularExponentiationVerify(M, e, n)
# assert(x_mont_encrypt == x_verify_encrypt)
#
# x_mont_decrypt = RSA_Montgomery(x_mont_encrypt, d, n, k)
# x_verify_decrypt = ModularExponentiationVerify(x_mont_encrypt, d, n)
# assert(x_mont_decrypt == x_verify_decrypt)
