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


class Flux(MCNP_File):

    def process_flux_tallies(self):

        """ ex: F4 tally output
        1tally       46        nps =     1998748
        +                                   gamma-ray heating(watts/gram), .149 g/cc 6% LH2                            
                   tally type 6    track length estimate of heating.                                   
                   particle(s): photons  
         number of histories used for normalizing tallies =      1900000.00        

                   this tally is all multiplied by  2.44000E+05
                   cell  f is (807 808 809 810 812)                                                                                                                                                                     

                   masses  
                           cell:      807          f     
                                 5.68096E+02  3.53413E+03
         
         cell  807                                                                                                                             
              energy   
            2.0000E+01   2.17972E-01 0.0151
         
        cell (807 808 809 810 812)                                                                                                            
             energy   
           2.0000E+01   2.19261E-01 0.0076
        """

        """ ex: F6 tally output snippet
        1tally       46        nps =     1998748
        +                                   gamma-ray heating(watts/gram), .149 g/cc 6% LH2                            
                   tally type 6    track length estimate of heating.                                   
                   particle(s): photons  
         number of histories used for normalizing tallies =      1900000.00        

                   this tally is all multiplied by  2.44000E+05
                   cell  f is (807 808 809 810 812)                                                                                                                                                                     

                   masses  
                           cell:      807          f     
                                 5.68096E+02  3.53413E+03
         
         cell  807                                                                                                                             
              energy   
            2.0000E+01   2.17972E-01 0.0151
         
        cell (807 808 809 810 812)                                                                                                            
             energy   
           2.0000E+01   2.19261E-01 0.0076
        """
        if self.run_type == 'flux':
            self.index_header, self.index_data = "tally number", FLUX_TALLIES_DICT.keys()
            self.tallies_dict = FLUX_TALLIES_DICT
            self.tally_filepath = f"{self.results_folder}/{self.base_filename}_tally"\
                                  f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                  f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                  f"_r{str(self.parameters['reg_height']).zfill(3)}.csv"
        elif self.run_type == 'heat':
            self.tallies_dict = HEAT_TALLIES_DICT
            self.tally_filepath = f"{self.results_folder}/{self.base_filename}_tally.csv"
            # self.tallies_dict = 

        """
        Setup or read keff dataframe
        """
        df_tally = pd.DataFrame(self.index_data, columns=[self.index_header])
        df_tally.set_index(self.index_header, inplace=True)

        """
        Parse tally cards (holy fuck troubleshooting this was ass)
        """
        lines_to_skip = 0 # 6000 or length of original input
        tally = False
        current_tally = []
        tally_number = ''

        heat_loads = {}
        with open(self.output_filepath) as f:
            read_volume = False
            read_mass = False
            read_tally = False
            found_tally = False
            cells = []
            masses = []
            volumes = []
            cells_dict = {}
            masses_dict = {}
            volumes_dict = {}
            tally_results_dict = {}

            for line in f:
                entries = line.split()
                if lines_to_skip > 0:
                    lines_to_skip -= 1

                elif line.lstrip().startswith('1tally'): # do not use 'entries[0]' since line may be empty
                    """ okay, let's read the first line:
                    1tally      214        nps =     4613649
                    we want to record that we parsed the start of this tally, its tally number (214), and the tally description from the dictionary
                    """
                    tally_recognized = False
                    for k in self.tallies_dict.keys():
                        if k in entries[1]:
                            found_tally = True
                            tally_recognized = True
                            bin_number = 1 # resets bin number from parsing tally result energy bins
                            tally_number, tally_desc = k, self.tallies_dict[k]
                            df_tally.loc[tally_number, 'tally desc'] = tally_desc
                            print(f"   comment. (Flux.py) found tally {line.split()[1]} ({tally_desc})")
                    if not tally_recognized and 'fluctuation' not in line: 
                        print(f"\n   warning. (Flux.py) tally number '{line.split()[1]}' not recognized in user-defined flux tally dictionary")
                        print(f"   warning. skipping... \n") 

                if found_tally:
                    if line.lstrip().startswith('masses'): # used in F6 tally
                        read_mass = True
                    elif line.lstrip().startswith('volumes'): # used in F4 tally
                        read_volume = True

                    elif read_volume and 'cell:' not in entries:
                        df_tally.loc[tally_number, 'volume'] = entries[0]
                        read_volume = False
                        if len(entries) > 1:
                            print(f"\n   warning. (Flux.py) seems like more than one volume is listed for tally number {tally_number} ")
                            print(f" warning. but rane can only parse one per tally")

                    elif not read_volume and not read_mass and line.lstrip().startswith('energy'):
                        read_tally = True

                    elif read_tally:
                        if entries[0] == 'total':
                            read_tally = False
                        elif tally_number.endswith('4'):
                            # print(tally_number, bin_number, entries)
                            df_tally.loc[tally_number, f'energy {bin_number} (MeV)'] = entries[0]
                            df_tally.loc[tally_number, f'f4 bin {bin_number} (flux)'] = entries[1]
                            df_tally.loc[tally_number, f'f4 unc {bin_number} (flux)'] = entries[2]
                            bin_number += 1
                        else:
                            print(f"\n   warning. (Flux.py) f{tally_number[-1]} for tally number {tally_number} is not yet supported in rane")

        ###### exit for loop

        print(tally_results_dict)

        for t in tally_results_dict.keys():
            df_tally.loc[t, 'tally desc']   = tally_results_dict[t]['tally desc']
            df_tally.loc[t, 'volume']       = tally_results_dict[t]['volume']



        df_tally.to_csv(self.tally_filepath)
