import os
import re

def mod_exp(base, exp, mod):
    """Modular exponentiation to calculate (base^exp) % mod efficiently."""
    return pow(base, exp, mod)

def process_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".txt"):
            file_path = os.path.join(directory, filename)
            
            print(filename)
            with open(file_path, 'r') as file:
                lines = file.readlines()
            
            # Extract KEY N, KEY E, KEY D, and COMMAND values
            n_value = e_value = d_value = command_value = None
            data_lines = []

            n_value = int(lines[1].strip().split()[-1], 16)
            e_value = int(lines[3].strip().split()[-1], 16)
            d_value = int(lines[5].strip().split()[-1], 16)
            command_value = int(lines[7].strip().split()[-1], 10)
            print(n_value, e_value, d_value, command_value)

            for line in lines[9:]:
                print(len(line))
                print(int(line.strip().split()[-1], 16))
                data_lines.append(int(line.strip().split()[-1], 16))
            
            # Check that required values were found
            if n_value is None or e_value is None or d_value is None or command_value is None:
                print(f"Skipping {filename} - missing required fields.")
                continue
            
            # Compute R = (2^256) mod N and R_SQUARE = ((2^256)^2) mod N
            R = mod_exp(2, 256, n_value)
            R_square = mod_exp(2**256, 2, n_value)
            
            # Prepare new content
            new_content = [
                f"# KEY N\n{n_value:064x}\n",
                f"# KEY E\n{e_value:064x}\n",
                f"# KEY D\n{d_value:064x}\n",
                f"# R\n{R:064x}\n",
                f"# R_SQUARE\n{R_square:064x}\n",
                f"# COMMAND\n{command_value}\n\n"
            ]
            new_content.extend(f"{line:064x}" + "\n" for line in data_lines)

            print(new_content)
            
            # Write the updated content back to the file
            print()
            with open(file_path, 'w') as file:
                file.writelines(new_content)
                
            print(f"Processed {filename}")

# Specify your directory path
directory_path = "/home/morten/dev/TFE4141-DDS1-Term-Project/integration_kit/RSA_accelerator/testbench/rsa_tests/long_tests/inp_messages/"
process_files(directory_path)

