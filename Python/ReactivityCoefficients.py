import os
import sys
import fnmatch
import traceback, sys
import fileinput
import numpy as np
import shutil
import platform
import json
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.axes3d import Axes3D, get_test_data
from matplotlib import cm as cmx  
import matplotlib.colors as colors
import json


from MCNP_OutputFile import *
from Utilities import *
from Parameters import *
from plotStyles import *


class ReactivityCoefficients(MCNP_OutputFile):

    self.keff_filename = f'{self.base_filename}_{self.run_type}_{self.rcty_type}_keff.csv'
    self.keff_filepath = f"{self.results_folder}/{self.keff_filename}"

    self.rho_filename = f'{self.base_filename}_{self.run_type}_{self.rcty_type}_rho.csv'
    self.rho_filepath = f"{self.results_folder}/{self.rho_filename}"

    self.params_filename = f'{self.base_filename}_{self.run_type}_{self.rcty_type}_params.csv'
    self.params_filepath = f"{self.results_folder}/{self.params_filename}"

    def process_mod_temp_coef(self):
        print(f'\n processing: {self.output_filename}')
        if self.keff_filename in os.listdir(self.results_folder):
            try:
                df_keff = pd.read_csv(self.keff_filepath, encoding='utf8')
                df_keff.set_index('height (%)', inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.keff_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the first column header is 'height (%)', followed by rod names 'safe', 'shim', 'reg'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.keff_filepath}')
            df_keff = pd.DataFrame(ROD_CAL_HEIGHTS, columns=["height (%)"])
            df_keff.set_index('height (%)', inplace=True)

    def process_fuel_temp_coef(self):
        print(f'\n processing: {self.output_filename}')
        if self.keff_filename in os.listdir(self.results_folder):
            try:
                df_keff = pd.read_csv(self.keff_filepath, encoding='utf8')
                df_keff.set_index('height (%)', inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.keff_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the first column header is 'height (%)', followed by rod names 'safe', 'shim', 'reg'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.keff_filepath}')
            df_keff = pd.DataFrame(ROD_CAL_HEIGHTS, columns=["height (%)"])
            df_keff.set_index('height (%)', inplace=True)

    def process void_coef(self):
        print(f'\n processing: {self.output_filename}')
        if self.keff_filename in os.listdir(self.results_folder):
            try:
                df_keff = pd.read_csv(self.keff_filepath, encoding='utf8')
                df_keff.set_index('height (%)', inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.keff_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the first column header is 'height (%)', followed by rod names 'safe', 'shim', 'reg'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.keff_filepath}')
            df_keff = pd.DataFrame(ROD_CAL_HEIGHTS, columns=["height (%)"])
            df_keff.set_index('height (%)', inplace=True)


        