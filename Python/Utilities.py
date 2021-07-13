from Parameters import *
import numpy as np
import multiprocessing

# From LA-UR-13-21822
U235_TEMPS_K_MAT_DICT = {294: '92235.80c', 600: '92235.81c', 900: '92235.82c', 1200: '92235.83c',
                  2500: '92235.84c', 0.1: '92235.85c', 250: '92235.86c', 77: '92235.67c', 3000: '92235.68c'}
U238_TEMPS_K_MAT_DICT = {294: '92238.80c', 600: '92238.81c', 900: '92238.82c', 1200: '92238.83c',
                  2500: '92238.84c', 0.1: '92238.85c', 250: '92238.86c', 77: '92238.67c', 3000: '92238.68c'}
PU239_TEMPS_K_MAT_DICT = {294: '94239.80c', 600: '94239.81c', 900: '94239.82c', 1200: '94239.83c',
                   2500: '94239.84c', 0.1: '94239.85c', 250: '94239.86c', 77: '94239.67c', 3000: '94239.68c'}
ZR_TEMPS_K_MAT_DICT = {294: '40000.66c', 300: '40000.56c', 587: '40000.58c'}

H_TEMPS_K_MAT_DICT = {294: '1001.80c', 600: '1001.81c', 900: '1001.82c', 1200: '1001.83c', 2500: '1001.84c',
                0.1: '1001.85c', 250: '1001.86c'}

O_TEMPS_K_MAT_DICT = {294: '8016.80c', 600: '8016.81c', 900: '8016.82c', 1200: '8016.83c', 2500: '8016.84c',
                0.1: '8016.85c', 250: '8016.86c'}

H_ZR_TEMPS_K_MT_DICT = {294: 'h-zr.20t', 400: 'h-zr.21t', 500: 'h-zr.22t', 600: 'h-zr.23t', 700: 'h-zr.24t',
                 800: 'h-zr.25t', 1000: 'h-zr.26t', 1200: 'h-zr.27t'}
ZR_H_TEMPS_K_MT_DICT = {294: 'zr-h.30t', 400: 'zr-h.31t', 500: 'zr-h.32t', 600: 'zr-h.33t', 700: 'zr-h.34t',
                 800: 'zr-h.35t', 1000: 'zr-h.36t', 1200: 'zr-h.37t'}
H2O_TEMPS_K_MT_DICT = {294: 'lwtr.20t', 350: 'lwtr.21t', 400: 'lwtr.22t', 450: 'lwtr.23t', 500: 'lwtr.24t',
                   550: 'lwtr.25t', 600: 'lwtr.26t', 650: 'lwtr.27t', 800: 'lwtr.28t'}



def h2o_temp_K_interpolate_mat(h2o_temp_K):
    """
    This function interpolates cross-sections

    example outputs:
    print(h2o_interpolate_mat(333.15)) # C = 60, K = 333.15
    >>> 1001.80c 1.698993390597    1001.81c 0.301006609403
    print(h2o_interpolate_mat(250)) # C= -23.15, K = 250
    >>> 1001.86c  2.000000000000

    ref:
    https://mcnp.lanl.gov/pdf_files/la-ur-08-5891.pdf
    pg 73
    """
    K = float('{:.2f}'.format(h2o_temp_K)) 
    # round to 2 decimal places to avoid floating point errors
    # rounding to < 2 digits causes errors, since there is a dictionary for K = 0.1

    T_1, T_2 = None, None

    for T in list(H_TEMPS_K_MAT_DICT.keys()):
      # print(T, K)
      if T == K:
        h2o_mat_lib_1, h2o_at_frac_1 = H_TEMPS_K_MAT_DICT[T], 2
        h2o_mats_interpolated = f"{h2o_mat_lib_1}  {'{:.12f}'.format(h2o_at_frac_1)}"
        return h2o_mats_interpolated

      elif T < K:
        if not T_1 or T > T_1:
          T_1 = T
          h2o_mat_lib_1 = H_TEMPS_K_MAT_DICT[T_1]
      
      elif T > K:
        if not T_2 or T < T_2:
          T_2 = T
          h2o_mat_lib_2 = H_TEMPS_K_MAT_DICT[T_2]

    h2o_at_frac_2 = 2 * ((np.sqrt(K) - np.sqrt(T_1))/(np.sqrt(T_2) - np.sqrt(T_1)))
    h2o_at_frac_1 = 2 - h2o_at_frac_2
    h2o_mats_interpolated = f"{h2o_mat_lib_1} {'{:.12f}'.format(h2o_at_frac_1)}    {h2o_mat_lib_2} {'{:.12f}'.format(h2o_at_frac_2)}"

    return h2o_mats_interpolated

# test
# print(h2o_interpolate_mat(250))

def find_closest_value(K, lst):
    return lst[min(range(len(lst)), key=lambda i: abs(lst[i] - K))]

def get_tasks():
    cores = multiprocessing.cpu_count()
    tasks = input(f" How many CPU cores should be used? Free: {cores}. Use: ")
    if not tasks:
        print(f' The number of tasks is set to the available number of cores: {cores}.')
        tasks = cores
    else:
        try:
            tasks = int(tasks)
            if tasks < 1 or tasks > multiprocessing.cpu_count():
                raise
        except:
            print(f' Number of tasks is inappropriate. Using maximum number of CPU cores: {cores}')
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


def find_h2o_temp_K_density(K):
    try:
        C = float('{:.2f}'.format(float(K)-273.15))
        density = float('{:.6f}'.format((
            999.83952
            +16.945176*C
            -7.9870401e-3*C**2
            -46.170461e-6*C**3
            +105.56302e-9*C**4
            -280.54253e-12*C**5)/(1+16.897850e-3*C)/1000))
        print(f"\n   comment. at {C} C, h2o density was calculated to be {density} g/cc \n")
        # Equation for water density given temperature in C, works for 0 to 150 C at 1 atm
        # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4909168/

        if C < 0 or C > 150: 
            print(f"\n   warning. h2o has calculated density {density} g/cc at given temp {C} C, ")
            print(f"   warning. but that is outside the range 0 - 150 C safely predicted by the formula \n")
        return density

    except:
        print(f"\n   fatal. finding h2o density for temperature {K} K failed")
        print(f"   fatal. ensure you are inputing a numeric-only str, float, or int into the function\n")

def find_poly_reg(x, y, degree):
    results = {}
    coeffs = np.polyfit(x, y, degree) # np.polyfit() object is just coefs of equation
    # Polynomial Coefficients
    results['polynomial'] = coeffs.tolist()
    # r-squared
    p = np.poly1d(coeffs)
    # fit values, and mean
    yhat = p(x)  # or [p(z) for z in x]
    ybar = np.sum(y) / len(y)  # or sum(y)/len(y)
    ssreg = np.sum((yhat - ybar) ** 2)  # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar) ** 2)  # or sum([ (yi - ybar)**2 for yi in y])
    results['r-squared'] = ssreg / sstot
    return results


