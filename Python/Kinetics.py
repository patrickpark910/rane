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


from MCNP_File import *
from Utilities import *
from Parameters import *
from plotStyles import *


class Kinetics(MCNP_File):

    print(f'\n extracting data from: {self.output_filename}')
    self.extract_keff() # gets self.keff, self.keff_unc or raises warnings if not found

    def find_kinetic_parameters(self):

        results_filepath = f"{self.results_folder}/{self.base_filename}_results.csv"

        print(f'  Processing: {self.output_filepath}')
        if os.path.exists(results_filepath):
            print(' * loading existing results file')
            df_kntc = pd.read_csv(results_filepath, encoding='utf8')
            df_kntc.set_index('Cycle state', inplace=True)
            core_numbers = list(df_kntc.index.values)
        else:
            core_numbers = [self.core_number]
            print(' * creating new results file')
            df_kntc = pd.DataFrame(core_numbers, columns=['Cycle state'])
            df_kntc.set_index('Core', inplace=True)
            cols = ['Lifetime (us)','Lifetime unc (us)']+\
                   ['Beff','Beff unc']+\
                   [f'B_{i}' for i in range(1,7)]+\
                   [f'L_{i}' for i in range(1,7)]+\
                   ['half life (s)'] +\
                   [f'E_{i}' for i in range(1,7)]+\
                   [f'E_{i} unc' for i in range(1,7)]
            for col in cols:
                df_kntc[col] = 0.0 
        
        """ Example section of the MCNP output to extract data from:

                            estimate      std. dev.
 
           gen. time        53.11160        0.93066    (usec)
         rossi-alpha    -1.22730E-04    1.15456E-05    (/usec)
            beta-eff         0.00652        0.00060
 
 effective delayed neutron fraction, average emission energy, and decay constants by precursor group:
 
         precursor    beta-eff   std. dev.      energy   std. dev.    lambda-i   std. dev.    half-life
                                                 (MeV)                  (/sec)                    (sec)
 
             1         0.00041     0.00014     0.39992     0.01034     0.01334     0.00000     51.97561
             2         0.00105     0.00022     0.47347     0.00487     0.03271     0.00000     21.18895
             3         0.00116     0.00025     0.43722     0.00467     0.12075     0.00001      5.74031
             4         0.00232     0.00038     0.55492     0.00430     0.30289     0.00002      2.28847
             5         0.00113     0.00025     0.50433     0.00672     0.85057     0.00012      0.81492
             6         0.00045     0.00016     0.54803     0.01194     2.85505     0.00053      0.24278
        """
        with open(self.output_filepath) as f:
            print(f' * seaching {self.output_filepath} for kinetics parameters')
            get_precursors = False
            for line in f:
                if len(line.split()) >= 1:
                    if line.split()[0] == 'gen.':
                        df_kntc.loc[self.core_number,'Lifetime (us)'] = float(line.split()[2])
                        df_kntc.loc[self.core_number,'Lifetime unc (us)'] = float(line.split()[3])
                    elif line.split()[0] == 'beta-eff':
                        df_kntc.loc[self.core_number,'Beff'] = float(line.split()[1])
                        df_kntc.loc[self.core_number,'Beff unc'] = float(line.split()[2])
                        get_precursors, lines_skipped = True, 0
                    elif get_precursors:
                        lines_skipped += 1 
                        if lines_skipped >= 6:
                            group = line.split()[0]
                            beta, beta_unc, E, E_unc, Lambda, Lambda_unc, HL = [float(value) for value in line.split()[1:]]
                            df_kntc.loc[self.core_number,f'B_{group}'] = beta
                            df_kntc.loc[self.core_number,f'B_{group} unc'] = beta_unc
                            df_kntc.loc[self.core_number,f'L_{group}'] = Lambda
                            df_kntc.loc[self.core_number,f'L_{group} unc'] = Lambda_unc
                            df_kntc.loc[self.core_number,f'E_{group}'] = E
                            df_kntc.loc[self.core_number,f'E_{group} unc'] = E_unc
                            df_kntc.loc[self.core_number,'half life (s)'] = HL
                            if group == '6':
                                df_kntc.to_csv(results_filepath, encoding='ascii')
                                print(f'   Updated: {results_filepath}')
                                return True
