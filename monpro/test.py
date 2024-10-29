def MonPro(a_bar, b_bar, n, k):
    print("*********************")
    print(f"/A = {a_bar:064x}")
    print(f"/B = {b_bar:064x}")
    print(f"n = {n:064x}")
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
        print(f"Un+1 : {u:064x}")
    return u

A = int("1fc255c23a521b8e5ff3c6476dc0387f9baf2b64f388304f544b019cd3828187", 16)
B = int("0f6975d1c4f38f2ea20a4daffaf041284b0768660137d9bee923051bf5a1f6df", 16)
N = int("214113026b14068150e3ea296f64941438a6bd102fa443799b485a2af3cf6177", 16)

MonPro(A, B, N, 256);

