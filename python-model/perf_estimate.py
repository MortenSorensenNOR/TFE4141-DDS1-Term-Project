import numpy as np

# Known data
msg_count = 882
cores = 12

# Tested data
orig_freq = 100_000_000
ms_per_msg = 2.3
msg_time_per_freq = ms_per_msg * orig_freq

# Proposed imporovements
proposed_freq = 200_000_000
new_msg_time = msg_time_per_freq / proposed_freq

resulting_ms_per_message = new_msg_time / 2 # because crt

# Result
ms_all_msgs = (msg_count) / cores * resulting_ms_per_message
print(ms_all_msgs)
