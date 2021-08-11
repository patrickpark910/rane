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

        lines_to_skip = 0
        tally = False
        current_tally = []
        tally_number = ''
        debug = False

        heat_loads = {}
        with open(self.output_file) as f:
            read_volumes = False
            read_masses = False
            read_tally = False
            found_tally = False
            cells = []
            masses = []
            volumes = []
            cell_dict = {}
            heat_load_dict = {'neutron E':{},'gamma E':{},'beta E':{},
                              'neutron W':{},'gamma W':{},'beta W':{},
                              'neutron blade':{}, 'beta blade':{}, 'gamma blade':{},}
            mass_dict = {}
            vol_dict = {}
            for line in f:
                if lines_to_skip > 0:
                    lines_to_skip -= 1
                    continue
                elif line.startswith('1tally       '):
                    found_tally = True
                    try:
                        tally_type = {'16':'neutron E','24':'beta E','26':'gamma E',
                                      '36':'neutron W','44':'beta W','46':'gamma W',
                                      '56':'neutron blade','54':'beta blade','66':'gamma blade'}[line.split()[1]]
                    except:
                        print(f"\n   warning. (HeatLoadsOutputFile.py) tally {line.split()[1]} not recognized")
                        print(f"   warning. Skipping... \n")
                elif found_tally and line.startswith('           masses'):
                    read_masses = True
                elif found_tally and line.startswith('           volumes'):
                    read_volumes = True
                elif found_tally and line.startswith('           cell'):
                    cell_dict[line.split()[1]] = line[21:].strip()
                elif read_masses:
                    if len(line) < 5:
                        read_masses = False
                        read_tally = True
                        for cell, mass in zip(cells, masses):
                            if cell in cell_dict.keys():
                                mass_dict[cell_dict[cell]] = float(mass)
                            else:
                                mass_dict[cell] = float(mass)
                        cells, masses = [], []
                    elif line.startswith('                   cell'):
                        cells += line.split()[1:]
                    else:
                        masses += line.split()  
                elif read_volumes:
                    if len(line) < 5:
                        read_volumes = False
                        read_tally = True
                        for cell, volume in zip(cells, volumes):
                            if cell in cell_dict.keys():
                                vol_dict[cell_dict[cell]] = float(volume)
                            else:
                                vol_dict[cell] = float(volume)
                        cells, volumes = [], []
                    elif line.startswith('                   cell'):
                        cells += line.split()[1:]
                    else:
                        volumes += line.split()  
                elif read_tally:
                    items = len(line.split())
                    if len(line) < 5:
                        continue
                    elif line.startswith(' *****') or line.startswith(' ======'):
                        read_tally = False
                    elif line.startswith(' cell'):
                        tally_cell = line[6:].strip()
                        # print(f'strip tally {line}')
                    elif items == 3:
                        # print(tally_type)
                        if tally_type.startswith('neutron') or tally_type.startswith('gamma'):
                            # print(f'read tally {line}')
                            heat_load_dict[tally_type][tally_cell] = float(line.split()[1])*mass_dict[tally_cell]/self.keff
                        elif tally_type.startswith('beta'):
                            heat_load_dict[tally_type][tally_cell] = float(line.split()[1])*vol_dict[tally_cell]/self.keff

            all_cells = []
            for heat_load, values in heat_load_dict.items():
                for cell in values.keys():
                    if cell not in all_cells:
                        all_cells += [cell]

            df = pd.DataFrame(all_cells, columns=['cell(s)'])
            df.set_index('cell(s)', inplace=True)

            # print(heat_load_dict)
            for heat_load, values in heat_load_dict.items():
                for cell, value in values.items():
                    print(heat_load, value)
                    df.loc[cell,heat_load] = value

            df.to_csv(self.results_folder+f'heat_loads_{self.cycle_state}.csv')