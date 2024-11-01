def MonPro(a_bar, b_bar, n, k):
    print("*********************")
    print(f"/A = {a_bar:08x}")
    print(f"/B = {b_bar:08x}")
    print(f"n = {n:08x}")
    print(f"k = {k}")
    
    u = 0
    
    for i in range(k):
        #print("**********************************************************")
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
            
        #print(f"config = {is_odd}{ai}")
        
        #print(f"B : {b_bar & ((1 << 32) - 1)}")
        #print(f"Un : {u & ((1 << 32) - 1)}")
        u = u + ((a_bar >> i) & 1) * b_bar
        if u & 1:
            u = u + n
        u = u >> 1
        print(f"Un+1 : {u:08x}")
    return u

A = int("1b254b238f68e0d59c0ee12a1c426115d0a47c748199f1b1bf912d35bb54ba4b", 16)
B = int("1b254b238f68e0d59c0ee12a1c426115d0a47c748199f1b1bf912d35bb54ba4b", 16)
N = int("19bfb084128dd8d58b7ab2b15fc9b082746e37ffd238398df42fa049b078ccbd", 16)
U_EXPECTED = int("5356fc9e2c6b3bd55ae47135933a28bd8c19e8181b4c27a56df73884b1179f5", 16)

MonPro(A, B, N, 256);

