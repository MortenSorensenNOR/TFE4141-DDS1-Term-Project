import math
import random

k = 257
A = random.randint(2**(k-1), 2**k)
B = random.randint(2**(k-1), 2**k)

A = 0x1a9bbe83f060d1a8f805552855b0f7bb7ad592e22f3b7361ed33af64a75b9647f
B = 0x12b3cf84434564c56bcf98a1d976d405b2bd8ece20cdd17d762c318ea5eae629c

def get_64_bit_hex(num, pos=0):
    return (num >> (pos * 64)) & ((1 << 64) - 1)

print(f"logic [256:0] A = 257'h{hex(A)[2:]};")
print(f"logic [256:0] B = 257'h{hex(B)[2:]};")
print(f"A = {hex(A)}")
print(f"B = {hex(B)}")
print("")

# print(f"vluint64_t A[5] = {'{'}\n\t{get_64_bit_hex(A)}, {get_64_bit_hex(A, 1)}, {get_64_bit_hex(A, 2)}, {get_64_bit_hex(A, 3)}, {get_64_bit_hex(A, 4)}\n{'}'};")
# print("")
# print(f"vluint64_t B[5] = {'{'}\n\t{get_64_bit_hex(B)}, {get_64_bit_hex(B, 1)}, {get_64_bit_hex(B, 2)}, {get_64_bit_hex(B, 3)}, {get_64_bit_hex(B, 4)}\n{'}'};")

print("")
C = A + B
print(f"C = {hex(get_64_bit_hex(C))}, {hex(get_64_bit_hex(C, 1))}, {hex(get_64_bit_hex(C, 2))}, {hex(get_64_bit_hex(C, 3))}, {hex(get_64_bit_hex(C, 4))}")

print("")
print(hex(A + B))
print(math.log2(A + B))

print((0x2d4f8e0833a6366e63d4edca2f27cbc12d9321b0500944df635fe0f34d467c71b == C))
