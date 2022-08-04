import matplotlib.pyplot as plt # plotting library
import numpy as np              # vector and matrix math library
import pandas as pd             # data analysis and manipulation tool
import sys                      # system-specific parameters and functions
from sys import platform        # to find os platform for geom_plotter ghostscript command
import os                       # miscellaneous operating system interfaces
from jinja2 import Template     # templating language
import fnmatch
import traceback, sys
import shutil
import platform
import json
import glob
import getpass
import math
import xlrd, openpyxl
import multiprocessing
from datetime import datetime
from Parameters import *
from Utilities import *

class MCNP_File:

    def __init__(self, run_type,
                       tasks,
                       print_input=True,       # default: only defines self variables and does not print input template
                       index_data=None,
                       template_filepath=None, # default: uses ./Source/reed.template
                       core_number=49,         # default: reads fuel load positions from ./Source/Core/49.core 
                       MCNP_folder=None,
                       results_folder=None,
                       source_folder=f"./Source",
                       skip_mcnp=False,
                       delete_extensions=['.s'],  # default: '.s'
                       fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                       rod_heights={'ecp':None}, # used in: all run types
                       rod_config_id=None,     # used in: sdm
                       ct_mat=102,             # used in: rcty, 102 is mat code for light water in reed.template
                       ct_mat_density=None,    #  
                       h2o_temp_K=294,         # used in: rcty, 293 K = 20 C = room temp = default temp in mcnp
                       h2o_density=None,       # used in: rcty, set None to calculate h2o_density from h2o_temp_K
                       h2o_void_percent=0,     # 
                       uzrh_temp_K=294,        # used in: rcty
                       add_samarium=True,
                       ):     

        """
        Define core parameters
        """
        self.index_data = index_data
        self.print_input = print_input
        self.datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.template_filepath = template_filepath
        self.run_type = run_type
        self.tasks = tasks
        self.core_number = core_number
        self.delete_extensions = delete_extensions
        self.username = getpass.getuser()
        self.fuel_filepath = fuel_filepath
        self.source_folder = source_folder
        self.mcnp_skipped = skip_mcnp # set to False when MCNP is actually run by run_mcnp()



        # rod heights
        self.rod_config_id = rod_config_id
        self.rod_heights_dict = rod_heights
        for rod in ['safe','shim','reg']:
            if rod not in self.rod_heights_dict.keys() or self.rod_heights_dict[rod] is None: # order matters in 'or' clause
                try:
                    self.rod_heights_dict[rod] = self.rod_heights_dict['bank']
                except:
                    print("\n   fatal. (MCNP_File.py) failed to set rod heights")
                    print("   fatal.   check input rod heights in NeutronicsEngine.py")
                    print("   fatal.   or make sure bank height is defined")
                    print("   fatal.   current self.rod_heights_dict = " + str(self.rod_heights_dict))
                    print("   fatal.   if a rod height is not defined, it is programmed to be set to bank height")
                    print("   fatal.   ex. (input in NeutronicsEngine.py) 'shim':100,'bank':50 --> (MCNP_File.py) 'safe':50,'shim':100,'reg':50,'bank':50") 
                    print("   fatal.   this makes it clear to RANE if some rods move together in a bank")
                    sys.exit()
        print(f"\n   comment. rod heights set to {self.rod_heights_dict}")

        # light water moderator properties - all mat and mt libs defined in functions below
        self.h2o_temp_K = h2o_temp_K
        self.h2o_void_percent = h2o_void_percent
        
        if not h2o_density:
            self.h2o_density = (1-0.01*self.h2o_void_percent)*find_h2o_temp_K_density(h2o_temp_K) # if h2o_density == None, calculate density from temp 
        else:
            self.h2o_density = (1-0.01*self.h2o_void_percent)*h2o_density

        # fuel properties
        self.uzrh_temp_K = uzrh_temp_K
        self.add_samarium = add_samarium
        
        # void properties
        self.ct_mat = ct_mat # default fill with 102 - light water
        self.ct_mat_density = ct_mat_density #
        self.ct_temp_K = 294 # default room temp bc ct will either be water or air
        if str(self.ct_mat) == '102':
            self.ct_temp_K = self.h2o_temp_K
        if not ct_mat_density:
            self.ct_mat_density = self.h2o_density # if ct_mat_density is not specified, use self.water density, which will be adjusted for temp


        """
        Find data libraries
        """
        self.find_mat_libs()
        self.find_mt_libs()


        # read fuel data
        self.read_core_config() # put after above parameters are defined
        try:
            self.read_fuel_data()
        except:
            print(f"\n   warning. fuel file not found or recognized at {self.read_fuel_data()}")
            print(f"   warning.   trying ./Source/Fuel/Core Burnup History 20201117.xlsx")
            try:
              self.fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx"  
              self.read_fuel_data()
            except:
              print(f"\n   fatal. fuel file not found or recognized at {self.read_fuel_data()}")
              sys.exit()

        # add tallies
        # add tally string to end of input file (to allow substitution into tally definition)
        if run_type in ['flux','powr']:
            with open(f'{self.source_folder}/tallies/{self.run_type}.tal', 'r') as tally_file:
                tally_str = tally_file.read()        
        else:
            tally_str = ''

        """
        Define and create necessary directories
        """
        if not template_filepath: 
          self.template_filepath = f"./Source/reed.template"
        else: 
          self.template_filepath = template_filepath

        if not MCNP_folder: 
          self.MCNP_folder = f'./MCNP/{run_type}'
        else: 
          self.MCNP_folder = MCNP_folder

        if not results_folder: 
          self.results_folder = f'./Results/{run_type}'
        else: 
          self.results_folder = results_folder          

        self.temp_folder = f'{self.MCNP_folder}/temp'
        self.user_temp_folder = f'{self.temp_folder}/{self.username}'
        self.inputs_folder = f"{self.MCNP_folder}/inputs"
        self.outputs_folder = f"{self.MCNP_folder}/outputs"

        self.create_paths()

        """
        Load variables into dictionary to be pasted into the template
        """
        self.parameters = {'datetime': self.datetime,
                           'run_type': self.run_type,
                           'run_desc': RUN_DESCRIPTIONS_DICT[self.run_type],
                           'core_number': self.core_number,
                           'core_config': self.core_config_dict,
                           'safe_height': self.rod_heights_dict['safe'], # 0-100, exact coords calculated in template
                           'shim_height': self.rod_heights_dict['shim'], # 0-100, exact coords calculated in template
                           'reg_height' : self.rod_heights_dict['reg'],  # 0-100, exact coords calculated in template
                           'tally' : 'c ',
                           'mode'  : ' n ',
                           'ct_mat': self.ct_mat,
                           'ct_mat_density': f'-{self.ct_mat_density}', # to fix
                           'h2o_density':    f'-{self.h2o_density}', # - for mass density, + for atom density
                           'h_mats':         self.h2o_mat_interpolated_str,
                           'o_mat_lib':      self.o_mat_lib,
                           'h2o_mt_lib':     self.h2o_mt_lib,
                           'h2o_temp_MeV':   '{:.6e}'.format(self.h2o_temp_K * MEV_PER_KELVIN),
                           'uzrh_temp_MeV':  '{:.6e}'.format(self.uzrh_temp_K * MEV_PER_KELVIN),
                           'zr_temp_MeV':    '{:.6e}'.format(self.uzrh_temp_K * MEV_PER_KELVIN),
                           'ct_temp_MeV':    '{:.6e}'.format(self.ct_temp_K * MEV_PER_KELVIN),
                           'fuel_mats'  :  self.fuel_mat_cards,
                           'n_per_cycle':    40000,
                           'discard_cycles': 15,
                           'kcode_cycles':   115,
                           }

        """
        Define input file names and paths
        """
        if not self.add_samarium:
            self.base_filename = f"{self.template_filepath.split('/')[-1].split('.')[0]}_core{self.core_number}_nosm149"
        else:
            self.base_filename = f"{self.template_filepath.split('/')[-1].split('.')[0]}_core{self.core_number}"

        if self.run_type in ['sdm', 'cxs']:
            self.input_filename = f"{self.base_filename}_{self.run_type}"\
                                  f"_{self.rod_config_id}"\
                                  f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                  f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                  f"_r{str(self.parameters['reg_height']).zfill(3)}.i"
        elif self.run_type == 'crit':
            pass
        elif self.run_type == 'prnt':
            self.input_filename = f"{self.base_filename}"\
                                  f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                  f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                  f"_r{str(self.parameters['reg_height']).zfill(3)}.i"  
        elif self.run_type.startswith('rcty'):
            if 'modr' in self.run_type:
                var = str(round(self.h2o_temp_K-273)).zfill(2) + "C" # ex: 01C, 10C, 20C, etc.
            elif 'fuel' in self.run_type:
                var = str(round(self.uzrh_temp_K)).zfill(4) + "K" # ex: 0001K, 0100K, 2720K, etc.
            elif 'void' in self.run_type:
                var = str(round(self.h2o_void_percent)).zfill(2) + "at" # ex: 00at,10at,99at, etc.
            self.input_filename = f"{self.base_filename}_{self.run_type}"\
                        f"_{var}"\
                        f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                        f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                        f"_r{str(self.parameters['reg_height']).zfill(3)}.i"

        else:
            self.input_filename = f"{self.base_filename}_{self.run_type}"\
                                  f"_a{str(self.parameters['safe_height']).zfill(3)}"\
                                  f"_h{str(self.parameters['shim_height']).zfill(3)}"\
                                  f"_r{str(self.parameters['reg_height']).zfill(3)}.i"

        self.input_filepath = f"{self.user_temp_folder}/{self.input_filename}"
        self.output_filename = f"o_{self.input_filename.split('.')[0]}.o"
        self.output_filepath = f"{self.MCNP_folder}/outputs/{self.output_filename}"

        if self.run_type == 'prnt':
            self.input_filepath = f"{self.results_folder}/{self.input_filename}"

        """
        Create input file by populating template with self.parameters dictionary
        """
        if self.print_input:
          with open(self.template_filepath, 'r') as template_file:
              template_str = template_file.read()
              template = Template(template_str+'\n'+tally_str)
              template.stream(**self.parameters).dump(self.input_filepath) 
              self.print_input = False
              print(f"\n input file created at: {self.input_filepath}")


              


    def read_core_config(self):
        """
        Reads core configs
        """
        self.core_config_dict = {}
        with open(f"{self.source_folder}/Core/{self.core_number}.core", 'r') as core_config_file:
            for line in core_config_file:
                if not line.startswith('c'):
                    pos, element = str(line.split('$')[0].split('=')[0]), int(line.split('$')[0].split('=')[-1])
                    self.core_config_dict[pos] = element



    def create_paths(self, paths_to_create=None):
        """
        Assign filepaths and create directories if they do not exist
        """
        if not paths_to_create:
            paths_to_create = [self.MCNP_folder, self.inputs_folder, self.outputs_folder, 
                               self.temp_folder, self.user_temp_folder,
                               self.results_folder] # order matters here

        if os.path.exists(self.user_temp_folder):
            shutil.rmtree(self.user_temp_folder)

        for path in paths_to_create:
            if not os.path.exists(path):
                try:
                    os.mkdir(path)
                except:
                    print(f"\n   warning. cannot make {path}")
                    print(f"   warning. It is possible that the directories above the destination do not exist.")
                    print(f"   warning. Python cannot create multiple directory levels in one command.")


    def find_mat_libs(self):

        """
        find mat libraries for fuel isotopes 
        """
        mat_list = [[None, U235_TEMPS_K_XS_DICT, 'U-235'], 
                    [None, U238_TEMPS_K_XS_DICT, 'U-238'],
                    [None, PU239_TEMPS_K_XS_DICT, 'Pu-239'],
                    [None, SM149_TEMPS_K_XS_DICT, 'Sm-149'],
                    [None, ZR_TEMPS_K_XS_DICT, 'zirconium'],
                    [None, H_TEMPS_K_XS_DICT, 'hydrogen'], # used in fuel mats, NOT when interpolating h mats
                    [None, O_TEMPS_K_XS_DICT, 'oxygen'],]  # used in light water mat, EVEN WHEN interpolating h mats
        
        for i in range(0,len(mat_list)):
          try:
            mat_list[i][0] = mat_list[i][1][self.uzrh_temp_K]
          except:
            closest_temp_K = find_closest_value(self.uzrh_temp_K,list(mat_list[i][1].keys()))
            mat_list[i][0] = mat_list[i][1][closest_temp_K]
            print(f"\n   comment. {mat_list[i][2]} cross-section (xs) data at {self.uzrh_temp_K} K does not exist")
            print(f"   comment.   using closest available xs data at temperature: {closest_temp_K} K")

        self.u235_mat_lib, self.u238_mat_lib, = mat_list[0][0], mat_list[1][0], 
        self.pu239_mat_lib, self.sm149_mat_lib = mat_list[2][0], mat_list[3][0]
        self.zr_mat_lib, self.h_mat_lib = mat_list[4][0], mat_list[5][0]
        self.o_mat_lib = mat_list[6][0] # KEEP

        """
        find mat libraries for light water isotopes
        """
        self.h2o_mat_interpolated_str = h2o_temp_K_interpolate_mat(self.h2o_temp_K) # Utilities.py
        try:
            self.o_mat_lib = O_TEMPS_K_XS_DICT[self.h2o_temp_K]
        except:
            closest_temp_K = find_closest_value(self.h2o_temp_K,list(O_TEMPS_K_XS_DICT.keys()))
            self.o_mat_lib = O_TEMPS_K_XS_DICT[closest_temp_K]
            print(f"\n   comment. oxygen cross-section (xs) data at {self.h2o_temp_K} K does not exist")
            print(f"   comment.   using closest available xs data at temperature: {closest_temp_K} K")



    def find_mt_libs(self):
        # find mt libraries
        # zr mt lib not available

        try:
          self.h2o_mt_lib = H2O_TEMPS_K_SAB_DICT[self.h2o_temp_K]
        except:
          closest_temp_K = find_closest_value(self.h2o_temp_K,list(H2O_TEMPS_K_SAB_DICT.keys()))
          self.h2o_mt_lib = H2O_TEMPS_K_SAB_DICT[closest_temp_K]
          print(f"\n   comment. light water scattering S(a,B) data at {self.h2o_temp_K} K does not exist")
          print(f"   comment.   using closest available S(a,B) data at temperature: {closest_temp_K} K")

        mt_list = [[None, ZR_H_TEMPS_K_SAB_DICT, 'zr_h'],
                   [None, H_ZR_TEMPS_K_SAB_DICT, 'h_zr']]

        for i in range(0,len(mt_list)):
          try:
            mt_list[i][0] = mt_list[i][1][self.uzrh_temp_K]
          except:
            closest_temp_K = find_closest_value(self.uzrh_temp_K,list(mt_list[i][1].keys()))
            mt_list[i][0] = mt_list[i][1][closest_temp_K]
            print(f"\n   comment. {mt_list[i][2]} scattering S(a,B) data at {self.uzrh_temp_K} does not exist")
            print(f"   comment.   using closest available S(a,B) data at temperature: {closest_temp_K} K")

        self.zr_h_mt_lib, self.h_zr_mt_lib = mt_list[0][0], mt_list[1][0]


    def move_mcnp_files(self, output_types_to_move=['.o','.r','.s','.msht']):
        """ Moves files to appropriate folder.
        """
        # move input
        shutil.move(self.input_filepath, os.path.join(self.inputs_folder, self.input_filename))

        # move outputs
        output_file = f"{self.output_filename.split('.')[0]}" # general output filename without extension
        src, dst = self.user_temp_folder, self.outputs_folder

        """ instead of programming it here, just define which outputs to move when function is called in NeutronicsEngine.py
        if self.run_type in ['banked', 'kntc', 'rodcal', 'rcty','sdm']:
            output_types_to_move = ['.o']
        elif self.run_type == 'plot':
            output_types_to_move = ['.ps']
        """ 

        print("\n\n\n test \n\n\n\n")

        if not self.mcnp_skipped or self.run_type in ['plot']:
            print("\n\n\n 1 \n\n\n\n")
            for extension in output_types_to_move:
                print("\n\n\n 2 \n\n\n\n")
                try:
                    filename = output_file+extension
                    shutil.move(os.path.join(src, filename), os.path.join(dst, filename))
                    print(f'\n   comment. moved {filename}')
                    print(f'   comment.   from {src} ')
                    print(f'   comment.   to   {dst}\n')
                    print("\n\n\n 3 \n\n\n\n")
                except:
                    print("\n\n\n 4 \n\n\n\n")
                    print(f'   warning. error moving {filename}')
                    print(f'   warning.   from {src} ')
                    print(f'   warning.   to   {dst}')



    def delete_mcnp_files(self, folder=None, extensions_to_delete=None):
        # Default args are False unless specified in command
        # NB: os.remove(f'*.r') does not work bc os.remove does not take wildcards (*)
        if not folder:
            folder = self.user_temp_folder

        if not extensions_to_delete:
            if self.run_type in ['plot']:
                extensions_to_delete = ['.c','.o','.s']
            else:
                extensions_to_delete = ['.r','.s']

        for ext in extensions_to_delete:
            for file in glob.glob(f'{folder}/*{ext}'): 
                try:
                    os.remove(file) 
                except:
                    print(f"\n   comment. did not remove {f'{target_folder_filepath}/{file}'}")
                    print(f"   comment.   because the filepath does not exist")


    def run_mcnp(self):
        """
        Runs MCNP
        """
        if self.output_filename not in os.listdir(self.outputs_folder):
            os.system(f"""mcnp6 i="{self.input_filepath}" n="{self.user_temp_folder}/{self.output_filename.split('.')[0]}." tasks {self.tasks}""")
            self.mcnp_skipped = False
        else:
            print(f'\n   comment. skipping this mcnp run since results for {self.input_filename} already exist.')
            self.mcnp_skipped = True


    def read_fuel_data(self):
        fuel_wb_name = self.fuel_filepath
        burnup_sht_name = "Core History"

        # pd.read_excel({file_name}, sheet_name= , usecols= )
        burnup_df = pd.read_excel(fuel_wb_name, sheet_name=burnup_sht_name, usecols='I,V:X', engine='openpyxl')

        # Currently, 'burnup_sht' uses the first row as column names. Rename it to the column column letters used in XLSX.
        burnup_df.columns = ['I','V','W','X']

        # Get rid of all the empty rows or rows with text in them.
        burnup_df = burnup_df[pd.to_numeric(burnup_df.iloc[:, 0], errors='coerce').notnull()]

        # Get rid of FE 101, as that is not a regular FE used in our MCNP code.
        burnup_df.drop(burnup_df.loc[burnup_df['I'] == 101].index, inplace=True)
        burnup_df.reset_index(drop=True, inplace=True)

        """ 
        df.apply(func, axis= {0 or ‘index’, 1 or ‘columns’, default 0}, result_type={‘expand’, default None}
        Notice that the get_mass_frac function actually outputs a list of 1 int and 5 floats.
        With result_type = None, the list is one entry in the new mass_fracs_df.
        With result_type = 'expand', each element of the list is separated into different columns
        """
        mass_fracs_df = burnup_df.apply(get_mass_fracs, axis=1, result_type='expand') # Utilities.py

        # Rename columns to their respective variable names
        mass_fracs_df.columns = ['fe_id', 'g_U235', 'g_U238', 'g_Pu239', 'g_Sm149', 'g_Zr', 'g_H',
                                 'a_U235', 'a_U238', 'a_Pu239', 'a_Sm149', 'a_Zr', 'a_H'] # keep order as get_mass_fracs() output in Utilities.py

        fuel_mat_cards = f"c materials auto-generated from '{fuel_wb_name}'"

        if self.add_samarium:
            for i in range(0,len(mass_fracs_df)):
                fe_id = int(str(mass_fracs_df.loc[i,'fe_id'])[:4]) # truncates '10705' to '1070'
                fuel_mat_cards += f"\nc" \
                f"\nm{fe_id}    {self.u235_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_U235'])} $ u-235 {round(mass_fracs_df.loc[i,'g_U235'],6):.6f} g" \
                f"\n         {self.u238_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_U238'])} $ u-238 {round(mass_fracs_df.loc[i,'g_U238'],6):.6f} g" \
                f"\n         {self.pu239_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_Pu239'])} $ pu-239 {round(mass_fracs_df.loc[i,'g_Pu239'],6):.6f} g" \
                f"\n         {self.sm149_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_Sm149'])} $ sm-149 {round(mass_fracs_df.loc[i,'g_Sm149'],6):.6f} g" \
                f"\n         {self.zr_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_Zr'])} $ zr {round(mass_fracs_df.loc[i,'g_Zr'],6):.6f} g" \
                f"\n          {self.h_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_H'])} $ h {round(mass_fracs_df.loc[i,'g_H'],6):.6f} g" \
                f"\nmt{fe_id} {self.h_zr_mt_lib} {self.zr_h_mt_lib}" \
                f"\nc " \
                f"\nc "
        else:
            for i in range(0,len(mass_fracs_df)):
                fe_id = int(str(mass_fracs_df.loc[i,'fe_id'])[:4]) # truncates '10705' to '1070'
                fuel_mat_cards += f"\nc" \
                f"\nm{fe_id}    {self.u235_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_U235'])} $ u-235 {round(mass_fracs_df.loc[i,'g_U235'],6):.6f} g" \
                f"\n         {self.u238_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_U238'])} $ u-238 {round(mass_fracs_df.loc[i,'g_U238'],6):.6f} g" \
                f"\n         {self.pu239_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_Pu239'])} $ pu-239 {round(mass_fracs_df.loc[i,'g_Pu239'],6):.6f} g" \
                f"\n         {self.zr_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_Zr'])} $ zr {round(mass_fracs_df.loc[i,'g_Zr'],6):.6f} g" \
                f"\n          {self.h_mat_lib} {'{:.6e}'.format(mass_fracs_df.loc[i,'a_H'])} $ h {round(mass_fracs_df.loc[i,'g_H'],6):.6f} g" \
                f"\nmt{fe_id} {self.h_zr_mt_lib} {self.zr_h_mt_lib}" \
                f"\nc " \
                f"\nc "

        self.fuel_mat_cards = fuel_mat_cards

    def extract_keff(self):
        """
        Parses output file for neutron multiplication factor, keff, and its uncertainty.
        """
        if os.path.exists(self.results_folder):
          try:
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
          except:
            print(f"\n   warning. keff not found in {self.output_filepath}")
            print(f"   warning.   skipping {self.output_filepath}")
        else:
          print(f'\n   fatal. cannot find {self.results_folder}\n')
          sys.exit(2)

    
    def run_geometry_plotter(self, debug=False):
        """
            Plots geometry to file, converts PostScript file to tiff, crops images
        """
        outputs_dir = self.outputs_folder
        results_dir = self.results_folder
        plotcom_path = f"{self.source_folder}/Plot/plotCommandsToFile"
        for filepath in [results_dir, f"{results_dir}/full", f"{results_dir}/cropped_scale", f"{results_dir}/cropped_no_scale"]:
            if not os.path.exists(filepath):
                os.mkdir(filepath)

        ps_name = f"{self.output_filename.split('.')[0]}.ps"
        tiff_name = f"{self.output_filename.split('.')[0]}.tiff"
        print(os.getcwd())

        if not debug:
            if ps_name not in os.listdir(outputs_dir):
                os.system(f'''mcnp6 ip i="{self.input_filepath}" n="{self.user_temp_folder}/{self.output_filename.split('.')[0]}." tasks {self.tasks} plotm={f"{self.user_temp_folder}/plotm"} com={plotcom_path}''')
                self.delete_mcnp_files(self.user_temp_folder, self.delete_extensions)
                os.rename(f"{self.user_temp_folder}/plotm.ps",f"{self.user_temp_folder}/{ps_name}")
                self.move_mcnp_files(output_types_to_move=['.ps'])

            # ghostscript command is 'gs' for Linux, Mac
            # and 'gswin64.exe' or 'gswin32.exe' for Windows 64 and 32
            # you may have to change the path variables to call 'gs' from cmd
            print(f" operating system identified as: {platform.system()}")
            if platform.system().lower().startswith('win32'):
                os.system(f'"C:/Program Files/gs/gs9.54.0/bin/gswin32.exe" -sDEVICE=tiff24nc -r300 -sOutputFile={results_dir}/{tiff_name} -dBATCH -dNOPAUSE {results_dir}/{ps_name}')
            elif platform.system().lower().startswith('win64') or platform.system().lower().startswith('windows'):
                print(f'""C:/Program Files/gs/gs9.54.0/bin/gswin64.exe"" -sDEVICE=tiff24nc -r300 -sOutputFile={results_dir}/{tiff_name} -dBATCH -dNOPAUSE {results_dir}/{ps_name}')
                os.system(f'""C:/Program Files/gs/gs9.54.0/bin/gswin64.exe"" -sDEVICE=tiff24nc -r300 -sOutputFile={results_dir}/{tiff_name} -dBATCH -dNOPAUSE {outputs_dir}/{ps_name}')
                # you need ""two quotes"" for a path to translate into "this" in cmd for some reason
            else:
                os.system(f'gs -sDEVICE=tiff24nc -r300 -sOutputFile={results_dir}/{tiff_name} -dBATCH -dNOPAUSE {results_dir}/{ps_name}')

            if tiff_name in os.listdir(results_dir):          
                from PIL import Image, ImageSequence, ImageDraw, ImageFont
                image_names = ['reflector_xy',
                               'reflector_yz',
                               'reflector_zoomed_xy',
                               'reflector_zoomed_yz',
                               'core_xy',
                               'core_yz',
                               'controlrod_xy',
                               'controlrod_yz',
                               'rabbit_xy',
                               'rabbit_big_yz',
                               'rabbit_small_yz',
                               'lazysusan_xy',
                               'lazysusan_yz',
                               'ambe_xy',
                               'ambe_yz',
                               'ambe_zoomed_yz',
                               'ir192_xy',
                               'ir192_yz',
                               'ir192_zoomed_yz',
                               'core_comp_xy',
                               'core_comp_yz',
                               'core_load_xy',
                               'core_load_yz',
                               'reflector_comp_xy',
                               'reflector_comp_yz',
                               'reflector_comp_zoomed_xy',
                               'reflector_comp_zoomed_yz',
                               'reflector_load_xy',
                               'reflector_load_yz',
                               'reflector_load_zoomed_xy',
                               'reflector_load_zoomed_yz',
                                ]

                with Image.open(f"{results_dir}/{tiff_name}") as im:
                    for name, frame in zip(image_names,ImageSequence.Iterator(im)):
                        frame = frame.rotate(270, expand=True)
                        # frame = frame.crop((450,780,2480,2910))
                        if '_xy' in name:
                            xlabel, ylabel = "x (cm)", "y (cm)"
                        if '_yz' in name:
                            xlabel, ylabel = "y (cm)", "z (cm)" 
                        if '_xz' in name:
                            xlabel, ylabel = "x (cm)", "z (cm)"
                        font = ImageFont.truetype(f"{self.source_folder}/Plot/NotoMono-Regular.ttf", 36)
                        ImageDraw.Draw(frame).text((1960, 2300), xlabel, fill=(0,0,0), font=font, align='center')
                        frame = frame.rotate(-90, resample=0, expand=1, center=None, translate=None, fillcolor=None)
                        ImageDraw.Draw(frame).text((1200,975), ylabel, fill=(0,0,0), font=font)
                        frame = frame.rotate(90, resample=0, expand=1, center=None, translate=None, fillcolor=None)
                        frame.save(f'{results_dir}/full/1_{name}.png')

                        # actual plot area is 1880 x 1880
                        frame = frame.crop((970,300,3000,2360)) # (left, top, right, bottom) # coordinates of cropped image
                        frame.save(f'{results_dir}/cropped_scale/2_{name}.png')

                        frame = frame.crop((115,35,1995,1915)) # (left, top, right, bottom) # coordinates of cropped image
                        frame.save(f'{results_dir}/cropped_no_scale/3_{name}.png')

        else:
            os.system(f'mcnp6 ip i="{self.input_file}" n={self.user_temp_folder}o_plot. com=./src/mcnp/plotCommands')