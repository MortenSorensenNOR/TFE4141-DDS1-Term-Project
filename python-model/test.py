def MonPro(a_bar, b_bar, n, k):
    print("*********************")
    print(f"/A = {a_bar:064x}")
    print(f"/B = {b_bar:064x}")
    print(f"n = {n:064x}")
    print(f"k = {k}")
    print("")

    u = 0
    for i in range(k):
        is_odd = (u&1) ^ ((b_bar&1) and ((a_bar >> i)&1)) 
        ai = ((a_bar >> i)&1)
        if ai == 1:
            if is_odd == 1:
                print("Case 1")
            else:
                print("Case 2")
        else:
            if is_odd == 1:
                print("Case 3")
            else:
                print("Case 4")

        u = u + ((a_bar >> i) & 1) * b_bar
        if u & 1:
            u = u + n
        u = u >> 1
        print(f"Un+1 : {u:064x}")
        print("")

    if (u >= n):
        u -= n

    return u

A = 0x984586d263d242096e6cdeff865297a0076eba43b6e1d855720f71e05ce078f7
B = 0x984586d263d242096e6cdeff865297a0076eba43b6e1d855720f71e05ce078f7
N = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d

res = MonPro(A, B, N, 256);
print(f"U = {res:064x}")
