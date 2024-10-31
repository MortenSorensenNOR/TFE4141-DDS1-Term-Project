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

A = int("2cfa92f666437733", 16)
B = int("c0bf71cc942bada", 16)
N = int("3567cae757bd801f", 16)

MonPro(A, B, N, 64);

