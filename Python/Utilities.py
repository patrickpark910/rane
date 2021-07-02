from Parameters import *
import multiprocessing

def find_closest_value(K, lst):
    return lst[min(range(len(lst)), key=lambda i: abs(lst[i] - K))]

def get_tasks():
    cores = multiprocessing.cpu_count()
    tasks = input(f"How many CPU cores should be used? Free: {cores}. Use: ")
    if not tasks:
        print(f'The number of tasks is set to the available number of cores: {cores}.')
        tasks = cores
    else:
        try:
            tasks = int(tasks)
            if tasks < 1 or tasks > multiprocessing.cpu_count():
                raise
        except:
            print(f'Number of tasks is inappropriate. Using maximum number of CPU cores: {cores}')
            tasks = cores
    return tasks  # Integer between 1 and total number of cores available.

def get_mass_fracs(row):
    fe_id = row['I']
    g_Pu239 = row['V']
    g_U = row['W']
    g_U235 = row['X']
    g_U238 = g_U - g_U235 # We assume all the U is either U-235 or U-238.
    g_U_total = g_Pu239 + g_U235 + g_U238 # should be <= 8.5% of total weight (mass) of FE
    g_ZrH_total = g_U_total/ 8.5 * 91.5 # Assume rest of FE mass of ZrH
    a_Pu239 = g_Pu239 / AMU_PU239 * AVO
    a_U235 = g_U235 / AMU_U235 * AVO
    a_U238 = g_U238 / AMU_U238 * AVO
    a_Zr = g_ZrH_total/(AMU_ZR/AVO + RATIO_HZR*AMU_H/AVO)
    a_H = RATIO_HZR * a_Zr
    g_Zr = a_Zr * AMU_ZR / AVO
    g_H = a_H * AMU_H / AVO
    return fe_id, g_U235, g_U238, g_Pu239, g_Zr, g_H, a_U235, a_U238, a_Pu239, a_Zr, a_H

