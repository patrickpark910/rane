'''
AUXILLIARY MCNP FUNCTIONS

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu
First published: Dec. 30, 2020
Last updated: Jan. 16, 2021

__________________
Default MCNP units

Length: cm
Mass: g
Energy & Temp.: MeV
Positive density (+x): atoms/barn-cm
Negative density (-x): g/cm3
Time: shakes
(1 barn = 10e-24 cm2, 1 sh = 10e-8 sec)

'''

import os, sys, multiprocessing, glob
import numpy as np
import pandas as pd

CORE_POS = {'B1', 'B2', 'B3', 'B4', 'B5', 'B6',
            'C1','C2','C3','C4','C6','C7','C8','C10','C11','C12',
            'D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12',
            'D13','D14','D15','D16','D17','D18',
            'E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12',
            'E13','E14','E15','E16','E17','E18','E19','E20','E21','E22','E23','E24',
            'F1','F2','F3','F4','F5','F7','F8','F14','F15','F16','F17','F18',
            'F19','F20','F21','F22','F24','F26','F27','F28','F29','F30'}

CM_PER_PERCENT_HEIGHT = 0.38

FE_ID = {'B1': '7202', 'B2': '9678', 'B3': '9679', 'B4': '7946', 'B5': '7945', 'B6': '8104',
         'C1':'4086','C2':'4070','C3':'8102','C4':'3856','C6':'8103',
         'C7':'4117','C8':'8105','C10':'8736','C11':'8735','C12':'1070',  #C12 is 10705 but only 4 digit IDs are supported here
         'D1':'3679','D2':'8732','D3':'4103','D4':'8734','D5':'3685','D6':'4095',
         'D7':'4104','D8':'4054','D9':'4118','D10':'3677','D11':'4131','D12':'4065',
         'D13':'3851','D14':'3866','D15':'8733','D16':'4094','D17':'4129','D18':'3874',
         'E2':'3872','E3':'4106','E4':'3671','E5':'4062','E6':'4121','E7':'4114',
         'E8':'4077','E9':'3674','E10':'4071','E11':'4122','E12':'4083','E13':'3853',
         'E14':'4134','E15':'4133','E16':'4085','E17':'4110','E18':'4055','E19':'3862',
         'E20':'4064','E21':'3858','E22':'4053','E23':'3748','E24':'3852',
         'F1':'4057','F2':'4125','F3':'4074','F4':'4069','F5':'4088','F7':'3868',
         'F8':'4120', 'F14':'3810', 'F15':'4130', 'F16':'4091', 'F17':'3673', 'F18':'3682',
         'F19':'4132', 'F20':'4046', 'F21':'3865', 'F22':'3743', 'F24':'3835', 'F26':'3676',
         'F27':'3840', 'F28':'3854', 'F29':'4049', 'F30':'4127'}

RODS = ["safe", "shim", "reg"] # must be in lower case

def initialize_rane():
    print("\n\n      _/_/_/         _/_/_/       _/      _/     _/_/_/_/_/\n    _/     _/     _/      _/     _/_/    _/     _/\n   _/_/_/_/      _/_/_/_/_/     _/  _/  _/     _/_/_/_/_/\n  _/   _/       _/      _/     _/    _/_/     _/\n _/     _/     _/      _/     _/      _/     _/_/_/_/_/\n\n")

def find_base_file(filepath):
    # filepath: string with current folder directory name, e.g. "C:/MCNP6/facilities/reed/rodcal-mcnp"
    base_input_name = None
    while base_input_name == None:
        potential_base_input_name = input('Input base MCNP file name, including extension: ')
        if potential_base_input_name in ['q','quit','kill']: sys.exit()
        elif potential_base_input_name in os.listdir(f'{filepath}'):
            base_input_name = potential_base_input_name
        else: print(f"'{potential_base_input_name}' cannot be found. Try again, or type 'quit' to quit.")
    return base_input_name # Name of the base input deck as string

def check_kcode(filepath,file):
    kcode_checked = False
    for line in reversed(list(open(f'{filepath}/{file}','r'))):
        entries = line.split(' ')
        if entries[0] == 'kcode': 
            kcode_checked=True
    if kcode_checked == True:
        print(f"Checked that '{file}' contains kcode card.")
    else:
        print('The kcode card could not be found in the base deck. The following input decks will be produced without a kcode card, which is necessary for keff calculations in MCNP.')
            
        '''
        kcode_card = input(f"The kcode card could not be found in '{base_file}'. It needs to be added if you want to calculate keff with MCNP. Would you like to add it now? ")
        if kcode_card in ['y','yes']: add_kcode()
        else: sys.exit()
        '''
            
    return kcode_checked # True or False

def add_kcode(): # for now, kcode must be added manually
    pass

def check_run_mcnp():
    ask_to_run_mcnp = input("Would you like to run MCNP now? Type 'yes' to run or 'no' to quit: ")
    if ask_to_run_mcnp.lower() in ['y','yes']: return True
    elif ask_to_run_mcnp.lower() in ['n','no','q','quit','kill']: return False
    else: return check_run_mcnp()
    # Loops until it returns True or False on whether to go ahead and run MCNP.

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
    return tasks # Integer between 1 and total number of cores available.
    
def run_mcnp(filepath, input_deck_filepath, outputs_folder_name, tasks_to_use):
    if not os.path.isdir(f"{filepath}/{outputs_folder_name}"): os.mkdir(f"{filepath}/{outputs_folder_name}")
    if 'o_'+input_deck_filepath.split('/')[-1].split(".")[0]+'.o' not in os.listdir(f"{filepath}/{outputs_folder_name}"):
        print('Running MCNP...')
        output_deck_filepath = f"{filepath}/{outputs_folder_name}/o_{input_deck_filepath.split('/')[-1].split('.')[0]}"
        os.system(f"mcnp6 i={input_deck_filepath} n={output_deck_filepath}. tasks {tasks_to_use}")
    else: 
        print(f"--This MCNP run will be skipped because the output for {input_deck_filepath.split('/')[-1]} already exists.")
 
def delete_files(target_folder_filepath,o=False, r=False, s=False):
    # Default args are False unless specified in command
    # NB: os.remove(f'*.r') does not work bc os.remove does not take wildcards (*)
    # if o: 
    #    for file in glob.glob(f'{target_folder_filepath}/*.o'): os.remove(file) 
    if r: 
        for file in glob.glob(f'{target_folder_filepath}/*.r'): os.remove(file) 
    if s: 
        for file in glob.glob(f'{target_folder_filepath}/*.s'): os.remove(file)

def extract_keff(target_filepath):
    # target_outputs: list of output file names from which to read keff values
    # keff_file_name: string with desired file name of collected keffs + .csv
    get_keff = False
    found_keff = False

    for line in open(target_filepath):
        if not found_keff:
            if line.startswith(" the estimated average keffs"):
                get_keff = True
            elif get_keff and line.startswith("       col/abs/trk len"):
                keff, keff_unc = float(line.split()[2]), float(line.split()[3])
                # print(f"{target_filepath.split('/')[-1]}: keff = {keff} +/- {keff_unc}")
                found_keff = True
    if not found_keff: print("--Error: keff cannot be found")
    return keff, keff_unc


'''
Finds the desired set of parameters to change for a given rod.

rod: str, name of rod, e.g. "shim"
height: float, percent rod height, e.g. 10
base_input_name: str, name of base deck with extension, e.g. "rc.i"
inputs_folder_name: str, name of input folder, e.g. "inputs"

Returns 'True' when new input deck is completed, or 'False' if the input deck already exists.

NB: This is the function you will change the most for use with a different facility's MCNP deck.
'''


def change_rod_height(filepath, module_name, rod_heights_dict, base_input_name, inputs_folder_name):
    if rod_heights_dict is None or len(rod_heights_dict) == 0:
        heights_list = list(input(
            'Input desired integer heights of the safe, shim, and reg rods, in order, separated by commas, e.g., 100, 20, 30: ').split(
            ","))
        rod_heights_dict = {RODS[0]: heights_list[0], RODS[1]: heights_list[1], RODS[2]: heights_list[2]}

    base_input_deck = open(base_input_name, 'r')
    # Encode new input name with rod heights: "input-a100-h20-r55.i" means safe 100, shim 20, reg 55, etc.

    new_input_name = f'{filepath}/{inputs_folder_name}/{module_name}-a{str(rod_heights_dict["safe"]).zfill(3)}-h{str(rod_heights_dict["shim"]).zfill(3)}-r{str(rod_heights_dict["reg"]).zfill(3)}.i'  # careful not to mix up ' ' and " " here

    # If the inputs folder doesn't exist, create it
    if not os.path.isdir(inputs_folder_name):
        os.mkdir(inputs_folder_name)

    # If the input deck exists, skip
    if os.path.isfile(new_input_name):
        # print(f"--The input deck '{new_input_name}' will be skipped because it already exists.")
        return False

    new_input_deck = open(new_input_name, 'w+')

    rods = [*rod_heights_dict]  # The * operator unpacks the dictionary, e.g., {"safe":1,shim":2,"reg":3} --> ["safe","shim","reg"], just in case it gets redefined elsewhere.

    start_marker_safe = "Safe Rod ("
    end_marker_safe = f"End of Safe Rod"
    start_marker_shim = "Shim Rod ("
    end_marker_shim = f"End of Shim Rod"
    start_marker_reg = "Reg Rod ("
    end_marker_reg = f"End of Reg Rod"

    # Indicates if we are between 'start_marker' and 'end_marker'
    inside_block_safe = False
    inside_block_shim = False
    inside_block_reg = False

    '''
    'start_marker' and 'end_marker' are what you're searching for in each 
    line of the whole input deck to indicate start and end of rod parameters. 
    Thus it needs to be unique, like "Safe Rod (0% Withdrawn)" and "End of Safe Rod".
    Make sure the input deck contains these markers EXACTLY as they are defined here,
    e.g. watch for capitalizations or extra spaces between words.
    '''

    # Now, we're reading the base input deck ('rc.i') line-by-line.
    for line in base_input_deck:

        # print("here1")
        # If we're not inside the block, just copy the line to a new file
        if inside_block_safe == False and inside_block_shim == False and inside_block_reg == False:
            # If this is the line with the 'start_marker', rewrite it to the new file with required changes
            if start_marker_safe in line:
                # print("checkA")
                inside_block_safe = True
                new_input_deck.write(f'c {"Safe"} Rod ({rod_heights_dict["safe"]}% withdrawn)\n')
                continue

            if start_marker_shim in line:
                # print("checkH")
                inside_block_shim = True
                new_input_deck.write(f'c {"Shim"} Rod ({rod_heights_dict["shim"]}% withdrawn)\n')
                continue

            if start_marker_reg in line:
                # print("checkR")
                inside_block_reg = True
                new_input_deck.write(f'c {"Reg"} Rod ({rod_heights_dict["reg"]}% withdrawn)\n')
                continue
            # print("checkSkip")
            new_input_deck.write(line)
            continue
        # print("here2")
        # Logic for what to do when we're inside the block
        if inside_block_safe == True:
            # print("check1")
            # If the line starts with a 'c'
            if line[0] == 'c':
                # If this is the line with the 'end_marker', it means we're outside the block now
                if end_marker_safe in line:
                    inside_block_safe = False
                    new_input_deck.write(line)
                    continue
                # If not, just write the line to new file
                else:
                    new_input_deck.write(line)
                    continue

            # We're now making the actual changes to the rod geometry
            if 'pz' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('pz', line, rod_heights_dict["safe"]) + '\n')
                # print(f'{new_input_name} pz change')
                continue
            if 'k/z' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('k/z', line, rod_heights_dict["safe"]) + '\n')
                # print(f'{new_input_name} k/z change')
                continue
            # If not, just write the line to the new file
            else:
                new_input_deck.write(line)
                continue

        if inside_block_shim == True:
            # If the line starts with a 'c'
            if line[0] == 'c':
                # If this is the line with the 'end_marker', it means we're outside the block now
                if end_marker_shim in line:
                    inside_block_shim = False
                    new_input_deck.write(line)
                    continue
                # If not, just write the line to new file
                else:
                    new_input_deck.write(line)
                    continue

            # We're now making the actual changes to the rod geometry
            if 'pz' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('pz', line, rod_heights_dict["shim"]) + '\n')
                # print(f'{new_input_name} pz change')
                continue
            if 'k/z' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('k/z', line, rod_heights_dict["shim"]) + '\n')
                # print(f'{new_input_name} k/z change')
                continue
            # If not, just write the line to the new file
            else:
                new_input_deck.write(line)
                continue

        if inside_block_reg == True:
            # If the line starts with a 'c'
            if line[0] == 'c':
                # If this is the line with the 'end_marker', it means we're outside the block now
                if end_marker_reg in line:
                    inside_block_reg = False
                    new_input_deck.write(line)
                    continue
                # If not, just write the line to new file
                else:
                    new_input_deck.write(line)
                    continue

            # We're now making the actual changes to the rod geometry
            if 'pz' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('pz', line, rod_heights_dict["reg"]) + '\n')
                # print(f'{new_input_name} pz change')
                continue
            if 'k/z' in line and line[0].startswith('8'):
                new_input_deck.write(edit_rod_height_code('k/z', line, rod_heights_dict["reg"]) + '\n')
                # print(f'{new_input_name} k/z change')
                continue
            # If not, just write the line to the new file
            else:
                new_input_deck.write(line)
                continue

    base_input_deck.close()
    new_input_deck.close()
    return True


'''
Performs the necessary changes on the values

value: str, MCNP geometry mnemonic, e.g. "pz"
line: str, line read from input deck
height: float, desired rod height, e.g. 10

NB: Bottom of rod is 5.120640 at 0% and 53.2694 at 100%. 
Use +/- 4.81488 to 'z_coordinate' for a 1% height change. 
'''
def edit_rod_height_code(geometry, line, height):
    entries = line.split() # use empty line.split() argument to split on any whitespace
    
    # For loop not recommended here, as entries are formatted differently between geometries
    if geometry == 'pz':
        entries[2] = str(round(float(entries[2]) + height * CM_PER_PERCENT_HEIGHT, 5))
        new_line = '   '.join(entries[0:4]) + ' '
        new_line += ' '.join(entries[4:])

    if geometry == 'k/z':
        entries[4] = str(round(float(entries[4]) + height * CM_PER_PERCENT_HEIGHT, 5))
        new_line = '   '.join(entries[0:7]) + ' '
        new_line += ' '.join(entries[7:])

    return new_line

def get_core_pos_to_vacate(): pass