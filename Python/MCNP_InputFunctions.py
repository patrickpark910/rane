'''
AUXILLIARY MCNP FUNCTIONS

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu
First published: Dec. 30, 2020
Last updated: Feb. 17, 2021

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

from Parameters import *

def find_water_density(temp, units='Kelvin'):
    temp = float(temp)
    while units.lower() != 'c':
        if units.lower() in ['c', 'cel', 'celsius']: units = 'c'
        elif units.lower() in ['f', 'fahren', 'fahrenheit']: temp, units = ((temp-32)*0.556), 'c'
        elif units.lower() in ['k','kelvin','kelvins']: temp, units = (temp-273.15), 'c'
        elif units.lower() in ['q', 'quit', 'kill']: sys.exit()
        else:
            user_input = input("Units not recognized. Input units ['f','c','k'] or 'q' to quit: ")
            temp, units = user_input[0], user_input[1]
    # Equation for water density given temperature in C, works for 0 to 150 C at 1 atm
    # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4909168/
    density = round((999.83952+16.945176*temp-7.9870401e-3*temp**2-46.170461e-6*temp**3+105.56302e-9-280.54253e-12*temp**5)/(1+16.897850e-3*temp)/1000, 6)
    print(f"At {round(temp,6)} {units.upper()}, water density was calculated to be {density} g/cc.")
    if temp < 0 or temp > 150: print(f"--Warning. The given {temp} {units.upper()} is outside of the limits [0, 150] C of the used density equation.")
    return density

def initialize_rane():
    print(
        "\n\n      _/_/_/         _/_/_/       _/      _/     _/_/_/_/_/\n    _/     _/     _/      _/     _/_/    _/     _/\n   _/_/_/_/      _/_/_/_/_/     _/  _/  _/     _/_/_/_/_/\n  _/   _/       _/      _/     _/    _/_/     _/\n _/     _/     _/      _/     _/      _/     _/_/_/_/_/\n\n")


def find_base_file(filepath):
    # filepath: string with current folder directory name, e.g. "C:/MCNP6/facilities/reed/rodcal_mcnp"
    base_file_path = None
    while base_file_path is None:
        base_file_path = input(f"\n Current working directory: {filepath}\n Input base MCNP file name, including extension: ")
        if base_file_path in ['q', 'quit', 'kill']:
            sys.exit()
        elif base_file_path in os.listdir(f'{filepath}'):
            pass
        else:
            print(f"\n  Warning. Input deck {base_file_path} cannot be found. Try again, or type 'quit' to quit.")
            base_file_path = None
    return str(base_file_path)  # Name of the base input deck as string


def check_kcode(filepath, file):
    kcode_checked = False
    for line in reversed(list(open(f'{filepath}/{file}', 'r'))):
        entries = line.split(' ')
        if entries[0] == 'kcode':
            kcode_checked = True
    if kcode_checked == True:
        print(f"Checked that {file} contains kcode card.")
    else:
        print(
            'The kcode card could not be found in the base deck. The following input decks will be produced without a kcode card, which is necessary for keff calculations in MCNP.')

        '''
        kcode_card = input(f"The kcode card could not be found in '{base_file}'. It needs to be added if you want to calculate keff with MCNP. Would you like to add it now? ")
        if kcode_card in ['y','yes']: add_kcode()
        else: sys.exit()
        '''

    return kcode_checked  # True or False


def add_kcode():  # for now, kcode must be added manually
    pass


def check_run_mcnp():
    ask_to_run_mcnp = input("Would you like to run MCNP now? Type 'yes' to run or 'no' to quit: ")
    if ask_to_run_mcnp.lower() in ['y', 'yes']:
        return True
    elif ask_to_run_mcnp.lower() in ['n', 'no', 'q', 'quit', 'kill']:
        return False
    else:
        return check_mcnp()
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
    return tasks  # Integer between 1 and total number of cores available.


def run_mcnp(input_deck_filepath, outputs_folder_path, tasks_to_use):
    if not os.path.isdir(f"{outputs_folder_path}"): 
        os.mkdir(f"{outputs_folder_path}")
    if 'o_' + input_deck_filepath.split('/')[-1].split(".")[0] + '.o' not in os.listdir(
            f"{outputs_folder_path}"):
        print('Running MCNP...')
        output_deck_filepath = f"{outputs_folder_path}/o_{input_deck_filepath.split('/')[-1].split('.')[0]}"
        os.system(f"mcnp6 i={input_deck_filepath} n={output_deck_filepath}. tasks {tasks_to_use}")
    else:
        print(
            f"\n  Warning. This MCNP run will be skipped because the output for {input_deck_filepath.split('/')[-1]} already exists.\n")


def delete_files(target_folder_filepath, o=False, r=False, s=False):
    # Default args are False unless specified in command
    # NB: os.remove(f'*.r') does not work bc os.remove does not take wildcards (*)
    # if o:
    #    for file in glob.glob(f'{target_folder_filepath}/*.o'): os.remove(file)
    if r:
        for file in glob.glob(f'{target_folder_filepath}/*.r'): os.remove(file)
    if s:
        for file in glob.glob(f'{target_folder_filepath}/*.s'): os.remove(file)



"""
core_positions_dict = {'E1': 'REG', 'C5': 'SAFE', 'C9': 'SHIM', 'F9': 'RABBIT', 
'B1': '7202', 'B2': '9678', 'B3': '9679', 'B4': '7946', 'B5': '7945', 'B6': '8104', 
'C1': '4086', 'C2': '4070', 'C3': '8102', 'C4': '3856', 'C6': '8103', 
'C7': '4117', 'C8': '8105', 'C10': '8736', 'C11': '8735', 'C12': '1070', 
'D1': '3679', 'D2': '8732', 'D3': '4103', 'D4': '8734', 'D5': '3685', 'D6': '4095', 
'D7': '4104', 'D8': '4054', 'D9': '4118', 'D10': '3677', 'D11': '4131', 'D12': '4065', 
'D13': '3851', 'D14': '3866', 'D15': '8733', 'D16': '4094', 'D17': '4129', 'D18': '3874', 
'E2': '3872', 'E3': '4106', 'E4': '3671', 'E5': '4062', 'E6': '4121', 
'E7': '4114', 'E8': '4077', 'E9': '3674', 'E10': '4071', 'E11': '4122', 'E12': '4083', 
'E13': '3853', 'E14': '4134', 'E15': '4133', 'E16': '4085', 'E17': '4110', 'E18': '4055', 
'E19': '3862', 'E20': '4064', 'E21': '3858', 'E22': '4053', 'E23': '3748', 'E24': '3852', 
'F1': '4057', 'F2': '4125', 'F3': '4074', 'F4': '4069', 'F5': '4088', 'F6': '80', 
'F7': '3868', 'F8': '4120', 'F10': '80', 'F11': '80', 'F12': '80', 
'F13': '80', 'F14': '3810', 'F15': '4130', 'F16': '4091', 'F17': '3673', 'F18': '3682', 
'F19': '4132', 'F20': '4046', 'F21': '3865', 'F22': '3743', 'F23': '60', 'F24': '3835', 
'F25': '70', 'F26': '3676', 'F27': '3840', 'F28': '3854', 'F29': '4049', 'F30': '4127'}
"""
def read_core_loading(base_file_path):
    base_file = open(base_file_path)
    
    inside_cell_cards = False
    inside_surf_cards = False
    inside_opt_cards = False
    core_positions_dict = {'A1': 'CT', 'E1': 'REG', 'C5':'SAFE', 'C9':'SHIM', 'F9':'RABBIT'}
    
    for line in base_file:
        line_entries = line.split()

        if "--begin cells--" in line.lower():
            inside_cell_cards = True
        elif "--begin surfaces--" in line.lower():
            inside_cell_cards = False
            inside_surf_cards = True
        elif "--begin options--" in line.lower():
            inside_surf_cards = False
            inside_opt_cards = True

        # print(len(line), line_count)
        if inside_cell_cards and len(line) > 1:
            if len(line_entries[0]) == 3: # and list(line_entries[0])[0] in CELL_NUM_TO_CORE_RING_DICT.keys(): #
                core_position = list(line_entries[0])
                
                if core_position[1] == '0':
                    core_position = f"{CELL_NUM_TO_CORE_RING_DICT[int(core_position[0])]}{core_position[2]}"
                else:
                    core_position = f"{CELL_NUM_TO_CORE_RING_DICT[int(core_position[0])]}{core_position[1]}{core_position[2]}"

                position_fill = [x for x in line_entries if x.startswith("fill=")][0].split("=")[-1]
                core_positions_dict.update({core_position: position_fill})
                # print({core_position: position_fill})

    return core_positions_dict  


def update_core_loading(base_file_path, core_pos_dict):
    pass


def create_paths(paths_to_create):
    for path in paths_to_create:
        if not os.path.isdir(path):
            os.mkdir(path)



'''
Finds the desired set of parameters to change for a given rod.

rod: str, name of rod, e.g. "shim"
height: float, percent rod height, e.g. 10
base_input_name: str, name of base deck with extension, e.g. "rc.i"
inputs_folder_name: str, name of input folder, e.g. "inputs"

Returns 'True' when new input deck is completed, or 'False' if the input deck already exists.

NB: This is the function you will change the most for use with a different facility's MCNP deck.
'''


def change_rod_height(filepath, base_file_path, rod_heights_dict, overwrite=True):
    '''
    if rod_heights_dict is None or len(rod_heights_dict) == 0:
        heights_list = list(input(
            '\nInput desired integer heights of the safe, shim, and reg rods, in order, separated by commas, ex: 100, 20, 30: ').split(
            ","))
        rod_heights_dict = {RODS[0]: heights_list[0], RODS[1]: heights_list[1], RODS[2]: heights_list[2]}
    '''
    base_input_name = base_file_path.split("/")[-1]
    base_input_deck = open(base_file_path, 'r')
    
    # Encode new input name with rod heights: "input-a100-h20-r55.i" means safe 100, shim 20, reg 55, etc.
    new_input_name = f'{filepath}/{base_input_name.split(".")[0]}-a{str(rod_heights_dict["safe"]).zfill(3)}-h{str(rod_heights_dict["shim"]).zfill(3)}-r{str(rod_heights_dict["reg"]).zfill(3)}.i'  # careful not to mix up ' ' and " " here

    # If the input deck exists, skip
    if not overwrite:
        if os.path.isfile(new_input_name):
            print(f"\n  Warning. The input deck '{new_input_name}' will be skipped because it already exists.")
            return False

    new_input_deck = open(new_input_name, 'w+')

    rods = [*rod_heights_dict]  
    # The * operator unpacks the dictionary, e.g., {"safe":1,shim":2,"reg":3} --> ["safe","shim","reg"], just in case it gets redefined elsewhere.

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


def change_cell_densities(filepath, module_name, cell_densities_dict, base_input_name, inputs_folder_name):
    base_input_deck = open(base_input_name, 'r')
    # Encode new input name with rod heights: "input-a100-h20-r55.i" means safe 100, shim 20, reg 55, etc.

    new_input_name = f'{filepath}/{inputs_folder_name}/{module_name}.i'  # careful not to mix up ' ' and " " here

    # print(cell_densities_dict)

    for key, value in cell_densities_dict.items():
        new_input_name = new_input_name.split('.')[0] + f"-m{key}-{''.join(c for c in str(value) if c not in '.')}.i"

    # If the inputs folder doesn't exist, create it
    if not os.path.isdir(inputs_folder_name):
        os.mkdir(inputs_folder_name)

    # If the input deck exists, skip
    if os.path.isfile(new_input_name): return False

    new_input_deck = open(new_input_name, 'w+')

    mats_to_change_str = [str(m) for m in cell_densities_dict.keys()]
    # The * operator unpacks the dictionary, e.g., {"safe":1,shim":2,"reg":3} --> ["safe","shim","reg"], just in case it gets redefined elsewhere.

    start_marker_cells = "Begin Cells"
    start_marker_surfs = "Begin Surfaces"

    # Indicates if we are between 'start_marker' and 'end_marker'
    inside_block_cells = False

    '''
    'start_marker' and 'end_marker' are what you're searching for in each 
    line of the whole input deck to indicate start and end of rod parameters. 
    Thus it needs to be unique, like "Safe Rod (0% Withdrawn)" and "End of Safe Rod".
    Make sure the input deck contains these markers EXACTLY as they are defined here,
    e.g. watch for capitalizations or extra spaces between words.
    '''

    # Now, we're reading the base input deck ('rc.i') line-by-line.
    for line in base_input_deck:
        # If we're not inside the block, just copy the line to a new file
        if inside_block_cells == False:
            # If this is the line with the 'start_marker', rewrite it to the new file with required changes
            if start_marker_cells in line:
                inside_block_cells = True
                new_input_deck.write(line)
                continue
            if start_marker_surfs in line:
                inside_block_cells = False
                new_input_deck.write(line)
                continue
            new_input_deck.write(line)
            continue
        # Logic for what to do when we're inside the block
        if inside_block_cells == True:
            # We're now making the actual changes to the cell density
            # 'line' already has \n at the end, but anything else doesn't
            if len(line.split()) > 0 and line.split()[0] != 'c' and line.split()[1] in mats_to_change_str:
                new_input_deck.write(f"c {line}")
                new_input_deck.write(
                    f"{edit_cell_density_code(line, line.split()[1], cell_densities_dict[float(line.split()[1])])}\n")
                continue
            elif len(line.split()) > 0 and line.split()[0] == 'c':
                new_input_deck.write(line)
                continue
            else:
                new_input_deck.write(line)
                # new_input_deck.write(f"{' '.join(line.split())}\n") # removes multi-spaces for proper MCNP syntax highlighting
                # ^that causes way too many issues for multi-line arguments
                continue

    base_input_deck.close()
    new_input_deck.close()
    return True


def change_cell_and_mat_temps(filepath, module_name, cell_temps_dict, base_input_name, inputs_folder_name):
    base_input_deck = open(base_input_name, 'r')

    # Encode new input name with rod heights: "coef_mod-temp-294.i" means moderator (water) at 294 K.
    new_input_name = f'{filepath}/{inputs_folder_name}/{module_name}-temp-{str(int(list(cell_temps_dict.values())[0])).zfill(4)}.i'
    # careful not to mix up ' ' and " " here

    # If the inputs folder doesn't exist, create it
    if not os.path.isdir(inputs_folder_name):
        os.mkdir(inputs_folder_name)

    # If the input deck exists, skip
    if os.path.isfile(new_input_name): return False # quits this function right here

    new_input_deck = open(new_input_name, 'w+')

    start_marker_cells = "Begin Cells"
    start_marker_water_cells = "Begin Core Water Cells"
    start_marker_surfs = "Begin Surfaces"
    start_marker_mats = "Begin Materials"
    end_marker_water_cells = "End Core Water Cells"
    end_marker_mats = "End Materials"

    # Indicates if we are between 'start_marker' and 'end_marker'
    inside_block_cells, inside_block_surfs, inside_block_mats, inside_block_water_cells = False, False, False, False
    mat_id = 0

    '''
    'start_marker' and 'end_marker' are what you're searching for in each 
    line of the whole input deck to indicate start and end of rod parameters. 
    Thus it needs to be unique, like "Safe Rod (0% Withdrawn)" and "End of Safe Rod".
    Make sure the input deck contains these markers EXACTLY as they are defined here,
    e.g. watch for capitalizations or extra spaces between words.
    '''

    # Now, we're reading the base input deck ('rc.i') line-by-line.
    for line in base_input_deck:
        # If this is the line with the 'start_marker', rewrite it to the new file with required changes
        if start_marker_cells in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = True, False, False, False
            new_input_deck.write(line)
            continue
        if start_marker_water_cells in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = False, True, False, False
            new_input_deck.write(line)
            continue
        if start_marker_surfs in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = False, False, True, False
            new_input_deck.write(line)
            continue
        if start_marker_mats in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = False, False, False, True
            new_input_deck.write(line)
            continue
        if end_marker_mats in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = False, False, False, False
            new_input_deck.write(line)
            continue
        if end_marker_water_cells in line:
            inside_block_cells, inside_block_water_cells, inside_block_surfs, inside_block_mats = True, False, False, False
            new_input_deck.write(line)
            continue
        if not inside_block_cells and not inside_block_surfs and not inside_block_mats and not inside_block_water_cells:
            new_input_deck.write(line)
            continue
        # Logic for what to do when we're inside the block
        if inside_block_cells:
            # We're now making the actual changes to the cell density
            # 'line' already has \n at the end, but anything else doesn't
            if len(line.split()) > 0 and line.split()[0] != 'c' and line.split()[1] in [str(m) for m in list(cell_temps_dict.keys())]:
                new_input_deck.write(f"c {line}")
                new_input_deck.write(
                    f"{edit_cell_temp_code(line, line.split()[1], cell_temps_dict[int(line.split()[1])])}\n")
                continue
            elif len(line.split()) > 0 and line.split()[0] == 'c':
                new_input_deck.write(line)
                continue
            else:
                new_input_deck.write(line)
                continue
        if inside_block_water_cells:
            if len(line.split()) > 0 and line.split()[0] != 'c' and 'imp:' in line:
                new_input_deck.write(f"c {line}")
                new_input_deck.write(line.replace('imp:n=1', f'imp:n=1 tmp={round(cell_temps_dict[102] * MEV_PER_KELVIN, 8)}'))
                continue
            else:
                new_input_deck.write(line)
                continue
        if inside_block_surfs:
            new_input_deck.write(line)
            continue
        if inside_block_mats:
            if len(line.split()) > 0 and line.split()[0] != 'c':
                if line.startswith('m'):
                    mat_id = int(''.join(filter(lambda i: i.isdigit(), line.split()[0])))
                if mat_id in list(cell_temps_dict.keys()):
                    # print(mat_id, mat_id in list(cell_temps_dict.keys()))
                    new_input_deck.write(f"c {line}")
                    new_input_deck.write(f"{edit_mat_temp_code(line, cell_temps_dict[mat_id])}\n")
                    # print(f"{edit_mat_temp_code(line, cell_temps_dict[mat_id])}\n")
                    continue
                else:
                    new_input_deck.write(line)
                    continue
            elif len(line.split()) > 0 and line.split()[0] == 'c':
                new_input_deck.write(line)
                continue
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
    entries = line.split()  # use empty line.split() argument to split on any whitespace

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


def edit_cell_density_code(line, mat_card, new_density):
    entries = line.split()  # use empty line.split() argument to split on any whitespace
    if entries[1] == str(mat_card):
        entries[2] = str(-new_density)
        new_line = ' '.join(entries)
        return new_line
    else:
        return line


def edit_cell_temp_code(line, mat_card, new_temp):
    new_temp, entries = float(new_temp), line.split()
    if entries[1] == str(mat_card):  # use empty line.split() argument to split on any whitespace
        if '$' in entries:
            entries.insert(entries.index('$'), f"tmp={new_temp * MEV_PER_KELVIN}")
            new_line = ' '.join(entries)
            return new_line
        else:
            entries.append(f"tmp={new_temp * MEV_PER_KELVIN}")
            new_line = ' '.join(entries)
            return new_line
    else:
        return line


def edit_mat_temp_code(line, new_temp):
    # print('edit mat temp code engaged')
    entries = line.split('$')[0].split()  # only counts entries before the Fortran in-line comment marker $
    for entry in entries:
        if entry in list(U235_TEMP_DICT.values()):
            # print([int(i) for i in list(U235_TEMP_DICT.keys())])
            new_temp = find_closest_value(list(U235_TEMP_DICT.keys()), new_temp)
            return line.replace(entry, U235_TEMP_DICT[new_temp]).rstrip()
        # by default, the original line has a trailing \n, so we need to get rid of it in the new_line
        # because the change_cell_and_mat_temps() function already adds a \n to each new line
        elif entry in list(U238_TEMP_DICT.values()):
            new_temp = find_closest_value(list(U238_TEMP_DICT.keys()), new_temp)
            return line.replace(entry, U238_TEMP_DICT[new_temp]).rstrip()
        elif entry in list(PU239_TEMP_DICT.values()):
            new_temp = find_closest_value(list(PU239_TEMP_DICT.keys()), new_temp)
            return line.replace(entry, PU239_TEMP_DICT[new_temp]).rstrip()
        elif entry in list(ZR_TEMP_DICT.values()):
            new_temp = find_closest_value(list(ZR_TEMP_DICT.keys()), new_temp)
            return line.replace(entry, ZR_TEMP_DICT[new_temp]).rstrip()
        elif entry in list(H1_TEMP_DICT.values()):
            new_temp = find_closest_value(list(H1_TEMP_DICT.keys()), new_temp)
            return line.replace(entry, H1_TEMP_DICT[new_temp]).rstrip()
    if entries[0].startswith('mt'):
        for i in range(0, len(entries)):
            if entries[i].startswith('h/zr'):
                new_temp = find_closest_value(list(HZR_TEMP_DICT.keys()), new_temp)
                entries[i] = HZR_TEMP_DICT[new_temp]
            elif entries[i].startswith('zr/h'):
                new_temp = find_closest_value(list(ZRH_TEMP_DICT.keys()), new_temp)
                entries[i] = ZRH_TEMP_DICT[new_temp]
        return f"{' '.join(entries)} $ {' '.join(line.split('$')[-1:1])}".rstrip()


def find_closest_value(lst, K):
    return lst[min(range(len(lst)), key=lambda i: abs(lst[i] - K))]


def write_f4_cards_power_density(core_positions_dict):
    fe_count = 0

    f4_cards = f"fc{F4_TALLY_ID_POWER_DENSITY} Cell flux tally for each fuel element\nf{F4_TALLY_ID_POWER_DENSITY}:n  "
    fe_list = [x for x in list(core_positions_dict.values()) if len(x) >= 4 and x.isdigit()]
    fm_card = f"fm{F4_TALLY_ID_POWER_DENSITY}:n (-3088 {fe_list[0]} -6 -8)"
    
    for fe in fe_list:
        f4_card  = f"\n       ({fe}08 {fe}09 {fe}10 {fe}11 {fe}12)"
        f4_cards += f4_card
        fe_count += 1
    
    f4_cards += f"\nc {fe_count} cell bins added to f{F4_TALLY_ID_POWER_DENSITY} tally\nc"
    f4_cards += f"\nc Arguments for f{F4_TALLY_ID_POWER_DENSITY}"
    f4_cards += f"\n{fm_card}"
    f4_cards += f"\nc -3088: multiplier for n/cm^2/fission_neutron --> Watts/cm^3"
    f4_cards += f"\nc  {fe_list[0]}: sample material in cell"
    f4_cards += f"\nc    -6: identifier for mascroscopic fission cross-section (barns*fissions/neutrons/atom)"
    f4_cards += f"\nc    -8: identifier for fission energy (MeV/fission)"
    # print(f4_cards)
    
    return f4_cards