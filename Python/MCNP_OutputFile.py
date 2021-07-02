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


from Utilities import *
from Parameters import *
from plotStyles import *


class MCNP_OutputFile:

    def __init__(self, run_type, 
                       template_filepath=f"./Source/reed.template",
                       core_number=49,
                       rod_heights=None,
                       rod_being_calibrated=None,
                       sdm_config_ID=None,
                       source_folder=f'./Source',
                       MCNP_folder=f'./MCNP',
                       results_folder=f'./Results'
                       ): 
        """
        Class for parsing an MCNP output file and extracting appropriate results based on the run type.
        """

        self.template_filepath = template_filepath
        self.run_type = run_type
        self.sdm_config_ID = sdm_config_ID
        self.core_number = core_number
        self.rod_heights_dict = rod_heights
        self.rod_being_calibrated = rod_being_calibrated

        """
        Make sure the proper folders are defined
        """
        self.template_filepath = template_filepath
        self.MCNP_folder = f"{MCNP_folder}/{run_type}"
        self.results_folder = f"{results_folder}/{run_type}"
        self.source_folder = source_folder
        self.inputs_folder = f"{self.MCNP_folder}/inputs"
        self.output_folder = f"{self.MCNP_folder}/outputs"

        self.base_filename = f"{self.template_filepath.split('/')[-1].split('.')[0]}_core{self.core_number}_{self.run_type}"

        """
        Determine the output file name depending on run type and parameters
        Should be identical to how they were defined in MCNP_InputFile.py
        """
        if run_type in ['banked', 'kntc', 'rodcal']:
            self.output_filename = f"o_{self.base_filename}"\
                                   f"_a{str(self.rod_heights_dict['safe']).zfill(3)}"\
                                   f"_h{str(self.rod_heights_dict['shim']).zfill(3)}"\
                                   f"_r{str(self.rod_heights_dict['reg']).zfill(3)}.o"
        
        elif run_type in ['rcty']:
            self.output_filename = f"o_{self.base_filename}"\
                                   f"_{str(self.rcty_type)}"\
                                   f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                   f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                   f"_r{str(self.parameters['reg_height']).zfill(3)}.o"

        elif run_type == 'sdm':
            self.output_filename = f"o_{self.base_filename}"\
                                   f"_{self.sdm_config_ID}"\
                                   f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                   f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                   f"_r{str(self.parameters['reg_height']).zfill(3)}.o"

        else:
            self.output_filename = f'o_{self.base_filename}.o'
        
        self.output_filepath = f"{self.output_folder}/{self.output_filename}"

        print(f'\n extracting data from: {self.output_filename}')

        if os.path.exists(self.results_folder):
            if self.run_type in ['banked', 'kntc', 'power', 'rcty', 'rodcal', 'sdm']:
                try: 
                    self.extract_keff()
                except: 
                    print(f"\n   warning. keff not found in {self.output_filepath}")
                    print(f"   warning.   skipping {self.output_filepath}\n")
        else:
            print(f'\n   fatal. cannot find {self.results_folder}\n')
            sys.exit(2)


    def extract_keff(self):
        """
        Parses output file for neutron multiplication factor, keff, and its uncertainty.
        """
        get_keff = False
        found_keff = False
        with open(self.output_filepath) as f:
            for line in f:
                if found_keff:
                    return
                else:
                    if line.startswith(" the estimated average keffs"):
                        get_keff = True
                    elif get_keff and line.startswith("       col/abs/trk len"):
                        self.keff, self.keff_unc = float(line.split()[2]), float(line.split()[3])
                        found_keff = True
                        print(f' keff: {self.keff} +/- {self.keff_unc}')

        

