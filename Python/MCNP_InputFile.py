import matplotlib.pyplot as plt # plotting library
import numpy as np              # vector and matrix math library
import pandas as pd             # data analysis and manipulation tool
import sys                      # system-specific parameters and functions
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
from Utilities import *
from Parameters import *
from neutron_science_config import *

class MCNP_InputFile:

	def __init__(self, 
				 base_file,
				 run_type,
				 tasks,
				 core_number=49,
				 rod_heights={None:None},
				 rod_bank_height=0,
				 MCNP_files_folder=None,
				 Results_folder=None,
				 )		

		self.base_file = base_file
        self.run_type = run_type
        self.tasks = tasks
        self.core_number = core_number
        self.rod_bank_height = rod_bank_height
        self.user = getpass(user)

        if not MCNP_files_folder:
            self.MCNP_files_folder = f'./MCNP_files/{run_type}/'
        else:
            self.MCNP_files_folder = MCNP_files_folder

        if not MCNP_files_folder:
            self.MCNP_files_folder = f'./Results/{run_type}/'
        else:
            self.MCNP_files_folder = MCNP_files_folder

        self.create_paths()

        self.parameters = {'core_load'  : 49,
        				   'reg_height' : self.rod_bank_height,
                           'safe_height': self.rod_bank_height,
                           'shim_height': self.rod_bank_height,
                           'fuel'  : 'c ',
                           'tally' : 'c ',
                           'mode'  : ' n ',
                           'kcode' : None,
                           'fuel_temp': None
                           }


        self.parameters['kcode_cycles'] = {'powr':2005, 
                                           'rodcal':105, 
                                           'sdm' :105,
                                           'kntc':205, 
                                           'heat':105,
                                           'beam':55,
                                           'geom':105,
                                           'burn':55,
                                           'kcde':105,
                                           'geom_debug':25}[run_type] 
		
		"""
		'self.parameters' is configured with proper values for the run type
		"""
        if run_type == 'rodcal':
            for rod in RODS.lower():
                print(f'Setting {rod} to a height of {rod_heights[rod]} cm.')
                self.parameters[rod] = rod_heights[rod]


        """
		Create input file using 'self.parameters'
        """
        template_file = f'{base_file}_{cycle_state}_cycle{cycle_number}.inp'
        if run_type == 'rodcal':
            self.input_filename = self.tmp_directory+f'{template_file.split('.')[0]}_{run_type}_a{self.parameters['safe_height']}_h{self.parameters['shim_height']}_r{self.parameters['reg_height']}.i'
        else:
            self.input_filename = self.tmp_directory+f'{template_file.split('.')[0]}_{run_type}.i'

        self.output_basename = self.input_file.split('/')[-1].split(".")[0]
        self.output_filename = f'{self.output_folder}o_{self.outputBaseName}.o'

        # skip run if input exists
        if self.input_filename.split('/')[-1] in os.listdir(self.MCNP_files_folder + 'input'):
            return None


        # create template input file
        with open(f'./src/mcnp/{base_file}', 'r') as template_file:
            template_str = template_file.read()
        
        # add tally string to end of input file (to allow substitution into tally definition)
        if run_type not in ['rodcal']:
            with open(f'./src/tallies/{run_type}.tal', 'r') as tally_file:
                tally_str = tally_file.read()        
        else:
            tally_str = ''
        template = Template(template_str+tally_str)
        
        # read fuel file string
        fuel_file = f'./results/fuel/cycle{cycle_number}_{cycle_state}.fuel'
        if os.path.exists(fuel_file):
            with open(f'./results/fuel/cycle{cycle_number}_{cycle_state}.fuel', 'r') as fuel_file:
                fuel_and_cd_material_cards = fuel_file.read()     
        else:
            print("ERROR: fuel file doesn't exist")
            sys.exit(2)
   
        if run_type != 'geom_debug':
            # skip adding fuel to make plotting faster
            self.parameters['fuel_and_cd_material_cards'] = fuel_and_cd_material_cards
        else:
            self.parameters['fuel_and_cd_material_cards'] = 'c '


        template.stream(**self.parameters).dump(self.input_file) 


    def create_paths(self):
        """
            assign filepaths and create directories if they do not exist
        """
        self.tmp_directory = f'./tmp/{self.username}/'
        self.input_folder = self.MCNP_files_folder + 'input/'
        self.output_folder = self.MCNP_files_folder + 'output/'
        paths_to_create = [self.MCNP_files_folder, self.input_folder, self.output_folder, self.tmp_directory]

        for path in paths_to_create:
            if not os.path.exists(path):
                os.mkdir(path)



    def move_MCNP_files(self):
        """
            Moves files to appropriate folder.
        """
        input_file = self.input_file.split('/')[-1]
        src, dst = self.tmp_directory, self.input_folder
        shutil.move(os.path.join(self.input_file), os.path.join(dst, input_file))

        output_file = 'o_'+input_file.split('.')[0]+'.'
        dst = self.output_folder
        for extension in ['o','r','s','msht']:
            try:
                filename = output_file+extension
                shutil.move(os.path.join(src, filename), os.path.join(dst, filename))
                print(f' Moved {filename}')
            except:
                print(f'   Warning. Error moving {filename}')



    def delete_extra_mcnp_files(self):
        file_list = glob.glob(self.tmp_directory+'*.s')
        if not self.keep_runtape_file:
            file_list += glob.glob(self.tmp_directory+'*.r')

        for file_path in file_list:
            os.remove(file_path)


    def run_mcnp(self):
        """
            Runs MCNP
        """
        if self.input_file.split('/')[3] not in os.listdir(self.input_folder):
            os.system(f'mcnp6 i="{self.input_file}" n="{self.tmp_directory}o_{self.outputBaseName}." tasks {self.tasks} ')
            self.delete_extra_mcnp_files()
            self.move_MCNP_files()
        else:
            print(f' Results for {self.input_file} already exists.')


    def run_geometry_plotter(self, debug=False):
        """
            Plots geometry to file, converts PostScript file to tiff, crops images
        """
        results_folder = f'./results/geom/{self.cycle_state}/'
        if not os.path.exists(results_folder):
            os.mkdir(results_folder)
        ps_name = f'o_geometry_{self.cycle_state}.ps'
        tiff_name = f'o_geometry_{self.cycle_state}.tiff'
        print(os.getcwd())


        if not debug:
            print(self.cycle_state)
            if ps_name not in os.listdir(results_folder):
                os.system(f'mcnp6 ip i="{self.input_file}" n={self.tmp_directory}o_plot. tasks {self.tasks} com=./src/mcnp/plotCommandsToFile')
                os.remove(self.tmp_directory+'o_plot.c')
                os.remove(self.tmp_directory+'o_plot.o')
                os.rename('plotm.ps',ps_name)
                self.move_MCNP_files([self.input_file], src=self.tmp_directory, dst=results_folder)
                self.move_MCNP_files([], src='./', dst=results_folder)

            os.system(f'gs -sDEVICE=tiff24nc -r300 -sOutputFile={tiff_name} -dBATCH -dNOPAUSE {results_folder+ps_name}')
            if tiff_name in os.listdir(results_folder):          
                from PIL import Image, ImageSequence, ImageDraw, ImageFont
                image_names = ['d2cs_xy',
                           'd2cs_yz',
                           'tank_xy',
                           'tank_yz',
                           'tank_xz',
                           'fuel_xz',
                           'fuel_yz',
                           'core_xy',
                           'FA_xy',
                           'plate_xy',
                           'cd_xy',
                           'rod_guide_xy',
                           'rod_guide_xy',
                           'rod_guide_xz'   
                            ]

                with Image.open(results_folder+tiff_name) as im:
                    for name, frame in zip(image_names,ImageSequence.Iterator(im)):
                        frame = frame.rotate(270)
                        frame = frame.crop((450,780,2480,2910))
                        if '_xy' in name:
                            xlabel = "x (cm)"
                            ylabel = "y (cm)"
                        if '_yz' in name:
                            xlabel = "y (cm)"
                            ylabel = "z (cm)"
                        if '_xz' in name:
                            xlabel = "x (cm)"
                            ylabel = "z (cm)"
                        font = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoMono-Regular.ttf", 48)
                        ImageDraw.Draw(frame).text((1000, 2000), xlabel, fill=(0,0,0), font=font)
                        frame = frame.rotate(-90, resample=0, expand=0, center=None, translate=None, fillcolor=None)
                        ImageDraw.Draw(frame).text((1000,20), ylabel, fill=(0,0,0), font=font)
                        frame = frame.rotate(90, resample=0, expand=0, center=None, translate=None, fillcolor=None)
                        frame.save(f'{results_folder}{name}.png')
            os.remove(tiff_name)
        else:
            os.system(f'mcnp6 ip i="{self.input_file}" n={self.tmp_directory}o_plot. com=./src/mcnp/plotCommands')