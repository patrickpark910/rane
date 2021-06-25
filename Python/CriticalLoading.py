"""
CRITICAL LOADING EXPERIMENT

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu
First published Dec 24, 2020
Last updated May 30, 2021

__________________
Default MCNP units

Length: cm
Mass: g
Energy & Temp.: MeV
Positive density (+x): atoms/barn-cm
Negative density (-x): g/cm3
Time: shakes
(1 barn = 10e-24 cm2, 1 sh = 10e-8 sec)

"""
import os, sys, multiprocessing
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator

from MCNP_InputFunctions import *
from MCNP_OutputFunctions import *
from Parameters import *


"""
Main function
"""
def CriticalLoading(filepath, base_file_path=None, check_mcnp=None, tasks=None, fuel_to_remove=[]):
    """
    Show RANE logo and any default messages.
    A big logo helps in "counting back" calculations while scrolling up in the command line window.
    """
    initialize_rane()

    """
    Set up some name constants to be used in the rest of this function.
    """
    water = "102" # m102 is the mat id for H2O in MCNP materials cards
    water_density = "-1.00" # Density of water-- needs to be specified bc it varies with temp & pressure. Negative indicates units of g/cm3 in MCNP syntax. 
    module_name = "CriticalLoading"
    base_file_name = base_file_path.split('/')[-1]

    mcnp_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}"
    mcnp_module_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}"
    inputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{INPUTS_FOLDER_NAME}"
    outputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{OUTPUTS_FOLDER_NAME}"
    
    results_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}"
    results_module_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}/{module_name}"
    
    keff_csv_name = f"{module_name}_{KEFF_CSV_NAME}"
    inv_M_csv_name = f"{module_name}_{INV_M_CSV_NAME}"
    figure_name = f"{module_name}_results.png"

    """
    Create the /Module/inputs folders if they do not already exist.
    """
    # ./MCNP
    if not os.path.isdir(f"{mcnp_folder_path}"):
        os.mkdir(f"{mcnp_folder_path}")
    # ./MCNP/ModuleName
    if not os.path.isdir(f"{mcnp_module_folder_path}"):
        os.mkdir(f"{mcnp_module_folder_path}")
    # ./MCNP/ModuleName/inputs
    if not os.path.isdir(f"{inputs_folder_path}"):
        os.mkdir(f"{inputs_folder_path}")
    # ./MCNP/ModuleName/outputs
    if not os.path.isdir(f"{outputs_folder_path}"):
        os.mkdir(f"{outputs_folder_path}")
    # ./Results
    if not os.path.isdir(f"{results_folder_path}"):
        os.mkdir(f"{results_folder_path}")
    # ./Results/ModuleName
    if not os.path.isdir(f"{results_module_folder_path}"):
        os.mkdir(f"{results_module_folder_path}")

    """
    Ask user for base file and whether to run MCNP, if not already provided.
    """
    if base_file_path is None:
        base_file_path = find_base_file(f"{filepath}/.")  # filepath/. goes up one dir level

    if check_mcnp is None:
        if shutil.which('mcnp6') is None: 
            print("\n  Warning. MCNP6 is not available on this device.")
            check_mcnp = False
        else:
            print("MCNP6 is available on this device.")
            check_mcnp = check_run_mcnp()

    """
    If check_mcnp = True, run the following.
    """
    if check_mcnp:
        """
        Ask user for number of CPU threads to use (tasks) and desired bank calibration heights.
        """
        if tasks is None:
            tasks = get_tasks()

        while len(fuel_to_remove)==0:
            user_input = input(f"Input core positions separated by a comma (ex: C1,C2,E4,F1), 'sop' to input the standard procedure for the 1/M experiment ({FUEL_REMOVED_SOP}), or 'quit' to quit: ")
            if user_input.lower() in ['s','sop']:
                user_input = FUEL_REMOVED_SOP 
            elif user_input.lower() in ['q','quit','kill']: 
                sys.exit()
            
            user_input = user_input.split(',')
            for c in user_input: 
                if c.upper() in CORE_POS: 
                    fuel_to_remove.append(c) # user_input is matched with a FE
                else: 
                    print(f"**WARNING: There is no fuel element in core position {c}!")


        """
        Check the base file has a KCODE.
        """
        check_kcode(filepath, base_file_path)

        """
        Create input file for each desired bank calibratrion height.

        Function change_rod_height returns True if input file was created and vice versa.
        It has an overwrite option to overwrite input files with the same name.        
        """
        inputs_created = change_mats(filepath, inputs_folder_path, base_deck, fuel_to_remove)
        
        num_of_fe_to_be_repl = 1

        run_mcnp(f"{filepath}/{base_deck}", outputs_folder_path, tasks) # runs base case
        
        while num_of_fe_to_be_repl <= len(opts):
            new_input_deck = 'cle-'+'-'.join(opts[:num_of_fe_to_be_repl])+'.i'
            run_mcnp(f"{inputs_folder_path}/{new_input_deck}", outputs_folder_path, tasks)
            num_of_fe_to_be_repl += 1

        print('MCNP calculations complete!')

        # Deletes MCNP runtape and source dist files.
        delete_files(f"{filepath}/{outputs_folder_name}",r=True,s=True)

        files_to_extract_keff = []
        base_output = 'o_'+base_deck.split('/')[-1].split(".")[0]+'.o'
        files_to_extract_keff.append(base_output) 
        for name in inputs_created:
            output = 'o_'+base_deck.split('/')[-1].split(".")[0]+f'-{name}'+'.o'
            files_to_extract_keff.append(output)


        # Setup a dataframe to collect keff values
        keff_df = pd.DataFrame(columns=["output file", "keff", "keff unc"])
        keff_df["output file"] = files_to_extract_keff
        keff_df.set_index("output file",inplace=True)

        for file in files_to_extract_keff:
            keff, keff_unc = extract_keff(f"{filepath}/{outputs_folder_name}/{file}")
            keff_df.loc[file,f"keff"] = keff 
            keff_df.loc[file,f"keff unc"] = keff_unc 

        # print(f"\nDataframe of keff values and their uncertainties:\n{keff_df}\n")
        keff_df.to_csv(f"{results_module_folder_path}/{keff_csv_name}", encoding='utf8')
        print(f"All {len(files_to_extract_keff)} keff values and their uncertainties have been extracted to '{keff_csv_name}'.")

    calc_inv_M(keff_csv_name)

    plot_inv_M(inv_M_csv_name)

    

#
#
# Helper Functions
#
#

def change_mats(filepath, inputs_folder_path, base_deck, opts):
    fe_id_found = {c:0 for c in opts}
    inputs_created = []

    num_of_fe_to_be_repl = 1

    while num_of_fe_to_be_repl <= len(opts):
        file = open(f"{filepath}/{base_deck}",'r') # opens MCNP input deck, must be in while loop
        fe_to_be_repl= opts[:num_of_fe_to_be_repl] 
        new_file_name = '-'.join(fe_to_be_repl)
        input_already_exists = f"cle-{new_file_name}.i" in os.listdir(f'{filepath}/{inputs_folder_path}')
        for line in file:
            entries = line.split(' ')
            entry_no = 1 
            for c in fe_to_be_repl:
                if entries[0][:4]==fe_id[c.upper()]:
                    fe_id_found[c]+=1
                    if not input_already_exists:
                        while entries[entry_no]=='': entry_no+=1
                        entries[entry_no]=water
                        entry_no+=1
                        while entries[entry_no]=='': entry_no+=1
                        entries[entry_no]=water_density
            if not input_already_exists: print(' '.join(entries),file=open(f"{filepath}/{inputs_folder_path}/cle-{new_file_name}.i",'a'),end='')
        if not input_already_exists: print(f"Created input deck 'cle-{new_file_name}.i'")    
        else: print(f"--Input deck will be skipped because 'cle-{new_file_name}.i' already exists.")
        inputs_created.append(new_file_name)
        num_of_fe_to_be_repl += 1
        
    for c in fe_id_found:
        if fe_id_found[c]==0:
            print(f"Python was unable to find any instances of the fuel element in core position {c}!")           
    
    return inputs_created


def calc_inv_M(keff_csv_name):
    inv_M_df = pd.read_csv(keff_csv_name)
    inv_M_df.columns =['output file', 'inv M', 'inv M unc']
    inv_M_df['inv M'] = 1 - inv_M_df['inv M']
    inv_M_df = inv_M_df.iloc[::-1]
    inv_M_df.to_csv(inv_M_csv_name, index=False, encoding='utf8')
    print(f"All {len(inv_M_df.index)} 1/M values have been calculated in '{inv_M_csv_name}'.")


def plot_inv_M(csv_file):
    inv_M_df = pd.read_csv(csv_file)
    
    num_fe_loaded = np.arange(0,len(inv_M_df.index))
    num_fe_added = num_fe_loaded - 8
    num_fe_added_1 = num_fe_added[:-1]
    inv_M_mcnp = inv_M_df.iloc[num_fe_loaded,1]
    inv_M_exp = [.0833,.07142,.07142,.0625,.0555,.0500,.0435,.0400]
    
    my_dpi = 320
    dot_marker_size = 2
    line_width = 0.5
    data_line_width = 0.75
    ax_label = 'x-small'
    tick_label = 'xx-small'
    
    fig, ax = plt.subplots(figsize=(1636/my_dpi, 673/my_dpi), dpi=my_dpi,facecolor='w',edgecolor='k')
    ax.plot(num_fe_added, inv_M_mcnp, '-bo', label="MCNP", markersize=dot_marker_size, linewidth=data_line_width)
    ax.plot(num_fe_added_1, inv_M_exp,'-ro', label="Experimental", markersize=dot_marker_size, linewidth=data_line_width)
      
    x1,y1,x2,y2 = num_fe_added[-2],inv_M_df.iloc[num_fe_loaded[-2],1],num_fe_added[-1],inv_M_df.iloc[num_fe_loaded[-1],1]
    line_eqn_mcnp = lambda x_mcnp : ((y2-y1)/(x2-x1)) * (x_mcnp - x1) + y1 # make use of line equation to form function line_eqn(x) that generated y
    xrange_mcnp = np.arange(num_fe_added[-1],(num_fe_added[-1]+20)) # generate range of x values based on your graph
    plt.plot(xrange_mcnp, [ line_eqn_mcnp(x_mcnp) for x_mcnp in xrange_mcnp], color='b', linestyle='--', linewidth=data_line_width) # plot the line with generate x ranges and created y ranges
    
    x3,y3,x4,y4 = num_fe_added[-3], inv_M_exp[num_fe_loaded[-3]], num_fe_added[-2], inv_M_exp[num_fe_loaded[-2]]
    line_eqn_exp = lambda x_exp : ((y4-y3)/(x4-x3)) * (x_exp - x3) + y3 
    xrange_exp = np.arange(num_fe_added_1[-1],(num_fe_added_1[-1]+20)) # generate range of x values based on your graph
    plt.plot(xrange_exp, [ line_eqn_exp(x_exp) for x_exp in xrange_exp], color='r', linestyle='--', linewidth=data_line_width) # plot the line with generate x ranges and created y ranges

    for axis in ['top','bottom','left','right']: ax.spines[axis].set_linewidth(line_width)
    
    ax.set_xlim([-8,12])
    ax.set_ylim([0,.1])

    ax.xaxis.set_major_locator(MultipleLocator(1))
    ax.yaxis.set_major_locator(MultipleLocator(0.01))
    
    ax.minorticks_on()
    ax.xaxis.set_minor_locator(MultipleLocator(1))
    ax.yaxis.set_minor_locator(MultipleLocator(0.005))
    
    ax.tick_params(axis='both', which='both', labelsize=tick_label,width=line_width)
    
    ax.grid(b=True, which='major', color='#999999', linestyle='-', linewidth=line_width)
    ax.grid(which='minor', linestyle=':', linewidth=line_width, color='gray')
    
    ax.set_xlabel(r'Fuel elements added  (0 = standard core config.)',fontsize=ax_label)
    ax.set_ylabel(r'1/M  ($1-k_{eff}$)',fontsize=ax_label)
    ax.legend(title=f'Key', title_fontsize=tick_label, ncol=1, fontsize=tick_label,loc='upper right')
    # fontsize: int or {'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large'}

    plt.savefig(f'results.png', bbox_inches = 'tight', pad_inches = 0.1, dpi=my_dpi)
    
    
if __name__ == "__main__":
    main(sys.argv[1:])