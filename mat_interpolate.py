"""
Print temperature-interpolated light water material card

Exported from Reed neutronics scripts for U Maryland demo


Patrick Park 
ppark@reed.edu
07/09/2021

"""
import sys
import numpy as np

"""
ACE Data Tables for xs and S(a,B) libraries

ref: 
LA-UR-17-20709
https://permalink.lanl.gov/object/tr?what=info:lanl-repo/lareport/LA-UR-17-20709
"""
'''
U235_TEMPS_K_MAT_DICT = {294: '92235.80c', 600: '92235.81c', 900: '92235.82c', 1200: '92235.83c',
                  2500: '92235.84c', 0.1: '92235.85c', 250: '92235.86c', 77: '92235.67c', 3000: '92235.68c'}
U238_TEMPS_K_MAT_DICT = {294: '92238.80c', 600: '92238.81c', 900: '92238.82c', 1200: '92238.83c',
                  2500: '92238.84c', 0.1: '92238.85c', 250: '92238.86c', 77: '92238.67c', 3000: '92238.68c'}
PU239_TEMPS_K_MAT_DICT = {294: '94239.80c', 600: '94239.81c', 900: '94239.82c', 1200: '94239.83c',
                   2500: '94239.84c', 0.1: '94239.85c', 250: '94239.86c', 77: '94239.67c', 3000: '94239.68c'}
ZR_TEMPS_K_MAT_DICT = {294: '40000.66c', 300: '40000.56c', 587: '40000.58c'}
'''

H_TEMPS_K_MAT_DICT = {293.6: '1001.80c', 600: '1001.81c', 900: '1001.82c', 1200: '1001.83c', 2500: '1001.84c',
                0.1: '1001.85c', 250: '1001.86c'}

O_TEMPS_K_MAT_DICT = {293.6: '8016.80c', 600: '8016.81c', 900: '8016.82c', 1200: '8016.83c', 2500: '8016.84c',
                0.1: '8016.85c', 250: '8016.86c'}

'''
H_ZR_TEMPS_K_MT_DICT = {294: 'h/zr.20t', 400: 'h/zr.21t', 500: 'h/zr.22t', 600: 'h/zr.23t', 700: 'h/zr.24t',
                 800: 'h/zr.25t', 1000: 'h/zr.26t', 1200: 'h/zr.27t'}
ZR_H_TEMPS_K_MT_DICT = {294: 'zr/h.30t', 400: 'zr/h.31t', 500: 'zr/h.32t', 600: 'zr/h.33t', 700: 'zr/h.34t',
                 800: 'zr/h.35t', 1000: 'zr/h.36t', 1200: 'zr/h.37t'}
'''
H2O_TEMPS_K_MT_DICT = {294: 'lwtr.20t', 350: 'lwtr.21t', 400: 'lwtr.22t', 450: 'lwtr.23t', 500: 'lwtr.24t',
                   550: 'lwtr.25t', 600: 'lwtr.26t', 650: 'lwtr.27t', 800: 'lwtr.28t'}


def main():

    h2o_temp_C = None
    while h2o_temp_C == None:
        h2o_temp_C = input(' Input water temp in C, up to 2 decimal places: ')
        if h2o_temp_C in ['q', 'quit', 'kill']:
            sys.exit()
        try:
            h2o_temp_K = float('{:.2f}'.format(float(h2o_temp_C) + 273.15))
        except:
            print(f" Unknown input. Try again, or type 'q' to quit.")
            h2o_temp_C = None

    h_mats, o_mat_lib = find_h2o_mat_libs(h2o_temp_K)
    h2o_mt_lib = find_h2o_mt_lib(h2o_temp_K)

    lwtr_mat_card = f'm102  {h_mats} \n      {o_mat_lib}  1.0 \nmt102 {h2o_mt_lib}'

    print(lwtr_mat_card)


def find_h2o_mat_libs(h2o_temp_K):
    """
    find mat libraries for light water isotopes
    """
    h2o_mat_interpolated_str = h2o_interpolate_mat(h2o_temp_K) # Utilities.py
    try:
        o_mat_lib = O_TEMPS_K_MAT_DICT[h2o_temp_K]
    except:
        closest_temp_K = find_closest_value(h2o_temp_K,list(O_TEMPS_K_MAT_DICT.keys()))
        o_mat_lib = O_TEMPS_K_MAT_DICT[closest_temp_K]
        print(f"\n   warning. oxygen cross-section (xs) data at {h2o_temp_K} K does not exist")
        print(f"   warning.   using closest available xs data at temperature: {closest_temp_K} K\n")

    return h2o_mat_interpolated_str, o_mat_lib


def find_h2o_mt_lib(h2o_temp_K):
    # find mt libraries
    try:
        h2o_mt_lib = H2O_TEMPS_K_MT_DICT[h2o_temp_K]
    except:
        closest_temp_K = find_closest_value(h2o_temp_K,list(H2O_TEMPS_K_MT_DICT.keys()))
        h2o_mt_lib = H2O_TEMPS_K_MT_DICT[closest_temp_K]
        print(f"\n   warning. light water scattering (S(a,B)) data at {h2o_temp_K} K does not exist")
        print(f"   warning.   using closest available S(a,B) data at temperature: {closest_temp_K} K\n")
    return h2o_mt_lib


def find_closest_value(K, lst):
    return lst[min(range(len(lst)), key=lambda i: abs(lst[i] - K))]


def h2o_interpolate_mat(h2o_temp_K):
    """
    This function interpolates cross-sections

    example outputs:
    print(h2o_interpolate_mat(60)) # K = 333.15
    >>> 1001.80c 1.698993390597    1001.81c 0.301006609403
    print(h2o_interpolate_mat(-23.15)) # K = 250
    >>> 1001.86c  2.000000000000

    ref:
    https://mcnp.lanl.gov/pdf_files/la-ur-08-5891.pdf
    pg 73
    """

    K = h2o_temp_K
    '''
    Use:
    K = float('{:.2f}'.format(float(h2o_temp_C) + 273.15)) 

    if using h2o_interpolate_mat(h2o_temp_C)
    round to 2 decimal places to avoid floating point errors
    rounding to < 2 digits causes errors, since there is a dictionary for K = 0.1
    '''

    T_1, T_2 = None, None

    if K >= max(list(H_TEMPS_K_MAT_DICT.keys())) or K <= min(list(H_TEMPS_K_MAT_DICT.keys())):
        print(f'\n   fatal. desired light water temp {K} K is beyond ENDF 7 ranges (0.1, 2500) K \n')
        sys.exit()

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


if __name__ == "__main__":
    main()


