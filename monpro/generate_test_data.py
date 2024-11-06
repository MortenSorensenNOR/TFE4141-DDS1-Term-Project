import math
import numpy as np
import random
import types
from Crypto.Util import number
from Crypto.Util.number import inverse

class MonProTestData:
    def __init__(self, A, B, n, k, U):
        self.A = A
        self.B = B
        self.N = n
        self.k = k
        self.U = U

        self.higher = U > n

    def toString(self):
        # For system verilog testing
        if self.higher:
            self.U = self.U - self.N

        # VERBOSE FILE OUTPUT
        # prefix = "parameter logic unsigned [DATAWIDTH-1:0] "
        # A_txt = prefix + f"A = 256'h{self.A:0x}" + ",\n"
        # B_txt = prefix + f"B = 256'h{self.B:0x}" + ",\n"
        # N_txt = prefix + f"N = 256'h{self.N:0x}" + ",\n"
        # U_txt = prefix + f"U_EXPECTED = 256'h{self.U:0x}" + "\n"

        # RAW FILE OUTPUT
        A_txt = f"{self.A:064x} "
        B_txt = f"{self.B:064x} "
        N_txt = f"{self.N:064x} "
        U_txt = f"{self.U:064x}\n"


        # if self.higher:
        #     return "HIGHER\n" + A_txt + B_txt + N_txt + U_txt
        return A_txt + B_txt + N_txt + U_txt

class MonExpTestData:
    def __init__(self, M, key_e_d, n, k, x):
        self.M = M
        self.key_e_d = key_e_d
        self.n = n
        self.k = k
        self.x = x

    def toString(self):
        prefix = "constant "
        post_fix = ' : std_logic_vector (C_block_size-1 downto 0) := x"'

        M_text = prefix + "M" + post_fix + f"{self.M:064x}" + '"\n'
        E_text = prefix + "E" + post_fix + f"{self.key_e_d:064x}" + '"\n'
        N_text = prefix + "N" + post_fix + f"{self.n:064x}" + '"\n'
        X_text = prefix + "X" + post_fix + f"{self.x:064x}" + '"\n'

        return M_text + E_text + N_text + X_text

def write_test_data_to_file(test_data, filename: str = "test_data.txt"):
    with open(filename, "w") as f:
        #f.write("================================\n")
        for data in test_data:
            f.write(data.toString()) 
            #f.write("================================\n")

mon_pro_test_data: list[MonProTestData] = []
mon_exp_test_data: list[MonExpTestData] = []

def MonPro(a_bar, b_bar, n, k):
    u = 0
    for i in range(k):
        u = u + ((a_bar >> i) & 1) * b_bar
        if u & 1:
            u = u + n
        u = u >> 1

    # if u > n:
    #     u = u - n

    return u

def RSA_Montgomery(M, e, n, k):
    # Precomputed
    r = 1 << k
    x_bar = r % n
    r_square = (r * r) % n

    # Main algorithm
    M_bar = MonPro(M, r_square, n, k)
    for i in range(k - 1, -1, -1):
        U = MonPro(x_bar, x_bar, n, k)
        mon_pro_test_data.append(MonProTestData(x_bar, x_bar, n, k, U))
        assert(math.log2(U) <= k)
        x_bar = U

        if (e >> i) & 1:
            U = MonPro(M_bar, x_bar, n, k)
            mon_pro_test_data.append(MonProTestData(M_bar, x_bar, n, k, U))
            assert(math.log2(U) <= k)
            x_bar = U

    x = MonPro(x_bar, 1, n, k)

    return x

k = 256

for i in range(10):
    p = number.getPrime(k//2 - 1)
    q = number.getPrime(k//2 - 1)
    n = (p * q)
    phi = (p - 1) * (q - 1)

    assert(n < (1 << k))

    e = 65537
    d = inverse(e, phi)

    M = random.randint(1, 2**(k-1))

    x_mont_encrypt = RSA_Montgomery(M, e, n, k)
    x_mont_decrypt = RSA_Montgomery(x_mont_encrypt, d, n, k)

    mon_exp_test_data.append(MonExpTestData(M, e, n, k, x_mont_encrypt))
    mon_exp_test_data.append(MonExpTestData(x_mont_encrypt, d, n, k, x_mont_decrypt))

print(f"MonPro Test Data length: {len(mon_pro_test_data)}")
write_test_data_to_file(mon_pro_test_data, "./raw_mon_pro_test_data.txt")

print(f"MonExp Test Data length: {len(mon_exp_test_data)}")
write_test_data_to_file(mon_exp_test_data, "mon_exp_test_data.txt")

