import math
import numpy as np
import random
from Crypto.Util import number
from Crypto.Util.number import inverse

def MonPro(a_bar, b_bar, n, k, debug = False):
    print(f"B + N: {b_bar + n:064x}")

    u = 0
    for i in range(k):
        odd = (u&1) ^ ((b_bar&1) and ((a_bar >> i)&1))
        ai = ((a_bar >> i)&1)
        
        if debug:
            print(f"{i}: ", end="")
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
        if u & 1:
            u = u + n
        u = u >> 1

        if debug:
            print(f"u = {u:064x}")
            print("")

    if (u >= n):
        u -= n
        if debug:
            print("Final subtraction")

    if debug:
        print(f"Final value: {u:064x}")

    return u

def RSA_Montgomery(M, e, n, k):
    # Precomputed
    r = 1 << k
    x_bar = r % n
    r_square = (r * r) % n

    # Main algorithm
    M_bar = MonPro(M, r_square, n, k)

    for i in range(k - 1, -1, -1):
        print(f"1: xbar = {x_bar:064x}")
        x_bar = MonPro(x_bar, x_bar, n, k, False)
        print(f"xbar = {x_bar:064x}")
        print("")

        if (e >> i) & 1:
            print(f"2: xbar = {x_bar:064x}\nMbar = {M_bar:064x}")
            x_bar = MonPro(M_bar, x_bar, n, k)
            print(f"xbar = {x_bar:064x}")
            print("")

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

A = 0x79d5686c6da2c90cd58f3ed75486c6adacbf3e872a288a754763b6da42bf2478
B = 0x79d5686c6da2c90cd58f3ed75486c6adacbf3e872a288a754763b6da42bf2478
N = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d

result = MonPro(A, B, N, k, True)
print(f"U = {result:064x}")

# M = 0x0A2320202020202020202020203336203A2020544E554F43204547415353454D
# E = 0x0000000000000000000000000000000000000000000000000000000000010001
# N = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
#
# result = RSA_Montgomery(M, E, N, k)
# print(f"Result = {result:064x}")

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
# x_mont_encrypt, case_dist = RSA_Montgomery(M, e, n, k)
# x_verify_encrypt = ModularExponentiationVerify(M, e, n)
# assert(x_mont_encrypt == x_verify_encrypt)
#
# x_mont_decrypt, case_dist = RSA_Montgomery(x_mont_encrypt, d, n, k)
# x_verify_decrypt = ModularExponentiationVerify(x_mont_encrypt, d, n)
# assert(x_mont_decrypt == x_verify_decrypt)
#
# case_sum = 2 * case_dist[0] + case_dist[1] + case_dist[2] + case_dist[3]
# if case_sum != 0:
#     print(f"Distribution:\t Case 1: {case_dist[0] * 2}\t Case 2: {case_dist[1]}\t Case 3: {case_dist[2]}\t Case 4: {case_dist[3]}\t Loading: {case_dist[4]}\t")
#     print(f"Distribution percent:\t Case 1: {2 * case_dist[0] / case_sum}\t Case 2: {case_dist[1] / case_sum}\t Case 3: {case_dist[2] / case_sum}\t Case 4: {case_dist[3] / case_sum}\t")
# num_clks_without_improv = case_dist[0] * 2 + case_dist[1] + case_dist[2] + case_dist[3] + case_dist[4]
# num_clks_with_improv1 = case_dist[0] + case_dist[1] + case_dist[2] + case_dist[3] + case_dist[4]
# num_clks_with_improv2 = case_dist[0] + case_dist[1] + case_dist[2] + case_dist[3]
# mum_clks_with_improv3 = case_dist[0] + case_dist[1] + case_dist[2]
#
# print("Number of clock cycles without improvement: ", num_clks_without_improv)
# print("Number of clock cycles with improvement 1: ", num_clks_with_improv1)
# print("Number of clock cycles with improvement 2: ", num_clks_with_improv2)
# print("Number of clock cycles with improvement 3: ", mum_clks_with_improv3)
#
# percentage_improv1 = (num_clks_with_improv1) / num_clks_without_improv
# percentage_improv2 = (num_clks_with_improv2) / num_clks_without_improv
# percentage_improv3 = (mum_clks_with_improv3) / num_clks_without_improv
# print("Percentage improvement 1: ", percentage_improv1)
# print("Percentage improvement 2: ", percentage_improv2)
# print("Percentage improvement 3: ", percentage_improv3)
#
# original_ms_per_msg = 2.2
# estimated_ms_per_msg = original_ms_per_msg * percentage_improv3
# print("Estimated ms per message: ", estimated_ms_per_msg)
#
# estimated_core_count = 10
# num_msgs = 882
# estimated_time = estimated_ms_per_msg * num_msgs / estimated_core_count
# print("Estimated time: ", estimated_time)
