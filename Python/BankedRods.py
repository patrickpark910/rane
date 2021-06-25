'''
BANKED RODS

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu

This project should be available at 
https://github.com/patrickpark910/banked/

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

_______________
Technical Notes

This program calculates Keff as banked rods in user-defined intervals.

'''

import os
import sys
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator, FormatStrFormatter

from MCNP_InputFunctions import *
from MCNP_OutputFunctions import *
from Parameters import *

"""
Variables
"""

heights = np.arange(0,100,5)# [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]  # % heights,
# for use in strings, use str(height).zfill(3) to pad 0s until it is 3 characters long,
# e.g. 'bankedrods-010.i'



'''
Main function to be executed.
'''

def BankedRods(filepath, base_file_path=None, check_mcnp=None, tasks=None, heights=None):
    """
    Show RANE logo and any default messages.
    A big logo helps in "counting back" calculations while scrolling up in the command line window.
    """
    initialize_rane()

    """
    Set up some name constants to be used in the rest of this function.
    """
    base_file_name = base_file_path.split('/')[-1]
    module_name = "BankedRods"  # os.path.basename(__file__).split('.')[0] # ex: for 'banked.py' returns "banked"
    
    mcnp_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}"
    mcnp_module_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}"
    inputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{INPUTS_FOLDER_NAME}"
    outputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{OUTPUTS_FOLDER_NAME}"
    
    results_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}"
    results_module_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}/{module_name}"
    
    keff_csv_name = f"{module_name}_{KEFF_CSV_NAME}"
    rho_csv_name = f"{module_name}_{RHO_CSV_NAME}"
    params_csv_name = f"{module_name}_{PARAMS_CSV_NAME}"
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

        if heights is None:
            heights = np.arange(0,100,50)  
            #ex: np.arange(0,100,5) = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]

        """
        Check the base file has a KCODE.
        """
        check_kcode(filepath, base_file_path)

        """
        Create input file for each desired bank calibratrion height.

        Function change_rod_height returns True if input file was created and vice versa.
        It has an overwrite option to overwrite input files with the same name.
        """
        num_inputs_created = 0
        num_inputs_skipped = 0
        for height in heights:
            rod_heights_dict = {"safe": height, "shim": height, "reg": height}
            input_created = change_rod_height(inputs_folder_path, base_file_path, rod_heights_dict, overwrite=True)
            if input_created: num_inputs_created += 1
            if not input_created: num_inputs_skipped += 1
        
        print(f"Created {num_inputs_created} new input decks.")
        if num_inputs_skipped > 1:
            print(f"\n  Warning. Skipped {num_inputs_skipped} input decks because they already exist and overwriting was turned off.")

        """
        Run MCNP for every input file in the ./module_name/inputs folder.
        """
        for file in os.listdir(f"{inputs_folder_path}"):
            run_mcnp(f"{inputs_folder_path}/{file}", f"{outputs_folder_path}", tasks)
        delete_files(f"{outputs_folder_path}", r=True, s=True)

        # Setup a dataframe to collect keff values
        keff_df = pd.DataFrame(columns=["height", "bank", "bank unc"])  # use lower cases to match 'rods' def above
        keff_df["height"] = heights
        keff_df.set_index("height", inplace=True)

        # Add keff values to dataframe
        # NB: Use keff_df.iloc[row, column] to select by range integers, .loc[row, column] to select by row/column labels
        rods = ["bank"]
        for rod in rods:
            for height in heights:
                keff, keff_unc = extract_keff(
                    f"{outputs_folder_path}/o_{base_file_name.split('.')[0]}-a{str(height).zfill(3)}-h{str(height).zfill(3)}-r{str(height).zfill(3)}.o")
                keff_df.loc[height, rod] = keff
                keff_df.loc[height, f'{rod} unc'] = keff_unc

        print(f"\nDataframe of keff values and their uncertainties:\n{keff_df}\n")
        keff_df.to_csv(f"{results_module_folder_path}/{keff_csv_name}", encoding='utf8')

    convert_keff_to_rho(f"{results_module_folder_path}/{keff_csv_name}", 
                        f"{results_module_folder_path}", 
                        rho_csv_name)
    calc_bank_params(f"{results_module_folder_path}/{rho_csv_name}", 
                     f"{results_module_folder_path}", 
                     params_csv_name)
    
    for rho_or_dollars in ['rho','dollars']:
        plot_bank_data(f"{results_module_folder_path}/{keff_csv_name}", 
                       f"{results_module_folder_path}/{rho_csv_name}", 
                       f"{results_module_folder_path}",
                       figure_name, 
                       rho_or_dollars=rho_or_dollars)

    print(f"\n************************ BANKED RODS CALCULATION COMPLETE ************************\n")


'''
HELPER FUNCTIONS
'''

'''
Converts a CSV of keff and uncertainty values to a CSV of rho and uncertainty values.

keff_csv_name: str, name of CSV of keff values, including extension, "keff.csv"
rho_csv_name: str, desired name of CSV of rho values, including extension, "rho.csv"

Does not return anything. Only makes the actual file changes.
'''

def convert_keff_to_rho(keff_csv_path, rho_target_folder_path, rho_csv_name):
    # Assumes the keff.csv has columns labeled "rod" and "rod unc" for keff and keff uncertainty values for a given rod
    try:
        keff_df = pd.read_csv(keff_csv_path, index_col=0)
    except:
        print(f"\n  Warning. The keff csv could not be found at {keff_csv_path}.")
        keff_csv_path = None
        while keff_csv_path is None:
            keff_csv_path = input(f"\nCurrent working directory: {os.getcwd()}\nInput filepath to keff csv (ex: C:/MCNP6/reed/keff.csv) here, or type 'quit' to quit: ")
            if keff_csv_path in ['q', 'quit', 'kill']:
                sys.exit()
            elif os.path.exists(f"{keff_csv_path}") and keff_csv_path.split('.')[-1].lower() == "csv":
                print(f"The keff was found at {keff_csv_path}.")
                keff_df = pd.read_csv(keff_csv_path, index_col=0)
            else:
                print(f"\n  Warning. The keff csv cannot be found at {keff_csv_path}. Try again, or type 'quit' to quit.")
                keff_csv_path = None


    rods = [c for c in keff_df.columns.values.tolist() if "unc" not in c]
    heights = keff_df.index.values.tolist()

    # Setup a dataframe to collect rho values
    rho_df = pd.DataFrame(columns=keff_df.columns.values.tolist())  # use lower cases to match 'rods' def above
    rho_df["height"] = heights
    rho_df.set_index("height", inplace=True)

    '''
	ERROR PROPAGATION FORMULAE
	% Delta rho = 100* frac{k2-k1}{k2*k1}
	numerator = k2-k1
	delta num = sqrt{(delta k2)^2 + (delta k1)^2}
	denominator = k2*k1
	delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
	delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
	'''

    for height in heights:
        k1 = keff_df.loc[height, "bank"]
        k2 = keff_df.loc[heights[-1], "bank"]
        dk1 = keff_df.loc[height, "bank unc"]
        dk2 = keff_df.loc[heights[-1], "bank unc"]
        k2_minus_k1 = k2 - k1
        k2_times_k1 = k2 * k1
        d_k2_minus_k1 = np.sqrt(dk2 ** 2 + dk1 ** 2)
        d_k2_times_k1 = k2 * k1 * np.sqrt((dk2 / k2) ** 2 + (dk1 / k1) ** 2)
        rho = (k2 - k1) / (k2 * k1) * 100

        rho_df.loc[height, "bank"] = rho
        if k2_minus_k1 != 0:
            d_rho = rho * np.sqrt((d_k2_minus_k1 / k2_minus_k1) ** 2 + (d_k2_times_k1 / k2_times_k1) ** 2)
            rho_df.loc[height, f"bank unc"] = d_rho
        else:
            rho_df.loc[height, f"bank unc"] = 0

    print(f"\nDataframe of rho values and their uncertainties:\n{rho_df}\n")
    rho_df.to_csv(f"{rho_target_folder_path}/{rho_csv_name}")


'''
Calculates a few other rod parameters.

rho_csv_name: str, name of CSV of rho values to read from, e.g. "rho.csv"
params_csv_name: str, desired name of CSV of rod parameters, e.g. "rod_parameters.csv"

Does not return anything. Only performs file creation.
'''
def calc_bank_params(rho_csv_path, params_target_folder_path, params_csv_name):
    rho_df = pd.read_csv(rho_csv_path, index_col=0)
    banks = [c for c in rho_df.columns.values.tolist() if "unc" not in c]
    heights = rho_df.index.values.tolist()

    parameters = ["worth ($)", "max worth added per % height ($/%)", "max worth added per height ($/in)"]

    # Setup a dataframe to collect rho values
    params_df = pd.DataFrame(columns=parameters)  # use lower cases
    params_df["bank"] = banks
    params_df.set_index("bank", inplace=True)

    for bank in banks:
        rho = rho_df[f"{bank}"].tolist()
        worth = 0.01 * float(max(rho)) / float(BETA_EFF)
        params_df.loc[bank, "worth ($)"] = worth

        int_eq = np.polyfit(heights, rho, 3)  # coefs of integral worth curve equation
        dif_eq = -1 * np.polyder(int_eq)
        max_worth_rate_per = 0.01 * max(np.polyval(dif_eq, heights)) / float(BETA_EFF)
        params_df.loc[bank, parameters[1]] = max_worth_rate_per

        max_worth_rate_inch = float(max_worth_rate_per) / float(CM_PER_PERCENT_HEIGHT) * CM_PER_INCH
        params_df.loc[bank, parameters[2]] = max_worth_rate_inch

    print(f"\nVarious bank parameters:\n{params_df}")
    params_df.to_csv(f"{params_target_folder_path}/{params_csv_name}")


'''
Plots integral and differential worths given a CSV of rho and uncertainties.

rho_csv_name: str, name of CSV of rho and uncertainties, e.g. "rho.csv"
figure_name: str, desired name of resulting figure, e.g. "figure.png"

Does not return anything. Only produces a figure.

NB: Major plot settings have been organized into variables for your personal convenience.
'''
def plot_bank_data(keff_csv_path, rho_csv_path, figure_target_folder_path, figure_name, rho_or_dollars=None):
    try:
        keff_df = pd.read_csv(keff_csv_path, index_col=0)
    except:
        print(f"\n  Warning. The keff csv could not be found at {keff_csv_path}.")
        keff_csv_path = None
        while keff_csv_path is None:
            keff_csv_path = input(f"\nCurrent working directory: {os.getcwd()}\nInput filepath to keff csv (ex: C:/MCNP6/reed/keff.csv) here, or type 'quit' to quit: ")
            if keff_csv_path in ['q', 'quit', 'kill']:
                sys.exit()
            elif os.path.exists(f"{keff_csv_path}") and keff_csv_path.split('.')[-1].lower() == "csv":
                print(f"The keff was found at {keff_csv_path}.")
                keff_df = pd.read_csv(keff_csv_path, index_col=0)
            else:
                print(f"\n  Warning. The keff csv cannot be found at {keff_csv_path}. Try again, or type 'quit' to quit.")
                keff_csv_path = None

    try:
        rho_df = pd.read_csv(rho_csv_path, index_col=0)
    except:
        print(f"\n  Warning. The rho csv could not be found at {rho_csv_path}.")
        rho_csv_path = None
        while rho_csv_path is None:
            rho_csv_path = input(f"\nCurrent working directory: {os.getcwd()}\nInput filepath to rho csv (ex: C:/MCNP6/reed/rho.csv) here, or type 'quit' to quit: ")
            if rho_csv_path in ['q', 'quit', 'kill']:
                sys.exit()
            elif os.path.exists(f"{rho_csv_path}") and rho_csv_path.split('.')[-1].lower() == "csv":
                print(f"The rho csv was found at {rho_csv_path}.")
                rho_df = pd.read_csv(rho_csv_path, index_col=0)
            else:
                print(f"\n  Warning. The rho csv cannot be found at {rho_csv_path}. Try again, or type 'quit' to quit.")
                rho_csv_path = None

    rods = [c for c in rho_df.columns.values.tolist() if "unc" not in c]
    heights = rho_df.index.values.tolist()

    sigma_error = 3

    # Determine plot units in rho or dollars.
    while rho_or_dollars is None:
        rho_or_dollars_input = input(
            "Would you like your plot in rho or dollars? Type 'rho' or 'dollars', or 'q' to quit: ")
        if rho_or_dollars_input.lower() in ['r', 'rho', 'p']:
            rho_or_dollars = 'rho'
        elif rho_or_dollars_input.lower() in ['d', 'dol', 'dollar', 'dollars', '$']:
            rho_or_dollars = 'dollars'
        elif rho_or_dollars_input.lower() in ['q', 'quit', 'kill']:
            sys.exit()
        else:
            print("Units unknown. Try again.")

    # Personal parameters, to be used in plot settings below.
    my_dpi = 320
    x_label = "Axial height withdrawn (%)"
    y_label_keff = r"Effective multiplication factor ($k_{eff}$)"

    if rho_or_dollars == 'dollars':
        y_label_int = r"Integral worth ($)"
        y_label_dif = r"Differential worth ($/%)"

    else:  # Use axes labels below for units of rho
        y_label_int = r"Integral worth ($\%\Delta\rho$)"
        y_label_dif = r"Differential worth ($\%\Delta\rho$/%)"

    label_fontsize = 16
    legend_fontsize = "x-large"
    # fontsize: int or {'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large'}

    fig, axs = plt.subplots(3, 1, figsize=(1636 / 96, 3 * 673 / 96), dpi=my_dpi, facecolor='w', edgecolor='k')
    ax_keff, ax_int, ax_dif = axs[0], axs[1], axs[2]  # integral, differential worth on top, bottom, resp.
    color = {rods[0]: "tab:purple"}  # ,rods[1]:"tab:green",rods[2]:"tab:blue"}

    for rod in rods:  # We want to sort our curves by rods
        # Plot data for keff.
        y_keff = keff_df[f"{rod}"].tolist()
        y_unc_keff = keff_df[f"{rod} unc"].tolist()

        ax_keff.errorbar(heights, y_keff, yerr=y_unc_keff,
                         marker="o", ls="none",
                         color=color[rod], elinewidth=2, capsize=3, capthick=2)

        eq_keff = np.polyfit(heights, y_keff, 3)  # coefs of integral worth curve equation
        x_fit = np.linspace(heights[0], heights[-1], heights[-1] - heights[0] + 1)
        y_fit_keff = np.polyval(eq_keff, x_fit)

        ax_keff.plot(x_fit, y_fit_keff, color=color[rod], label=f'{rod.capitalize()}')

        # Plot data for integral worth.
        y_int = rho_df[f"{rod}"].tolist()
        y_unc_int = rho_df[f"{rod} unc"].tolist()

        if rho_or_dollars == 'dollars':
            y_int = [x * 0.01 / BETA_EFF for x in y_int]
            y_unc_int = [x * 0.01 / BETA_EFF for x in y_unc_int]

        int_eq = np.polyfit(heights, y_int, 3)  # coefs of integral worth curve equation
        x_fit = np.linspace(heights[0], heights[-1], heights[-1] - heights[0] + 1)
        y_fit_int = np.polyval(int_eq, x_fit)

        # Data points with error bars
        ax_int.errorbar(heights, y_int, yerr=y_unc_int,
                        marker="o", ls="none",
                        color=color[rod], elinewidth=2, capsize=3, capthick=2)

        # The standard least squaures fit curve
        ax_int.plot(x_fit, y_fit_int, color=color[rod], label=f'{rod.capitalize()}')

        dif_eq = -1 * np.polyder(int_eq)  # coefs of differential worth curve equation
        y_dif_fit = np.polyval(dif_eq, x_fit)

        # The differentiated curve.
        # The errorbar method allows you to add errors to the differential plot too.
        ax_dif.errorbar(x_fit, y_dif_fit,
                        label=f'{rod.capitalize()}',
                        color=color[rod], linewidth=2, capsize=3, capthick=2)

    # Keff plot settings
    ax_keff.set_xlim([0, 100])
    ax_keff.set_ylim([0.9675, 1.03])

    ax_keff.xaxis.set_major_locator(MultipleLocator(10))
    ax_keff.yaxis.set_major_locator(MultipleLocator(0.01))

    ax_keff.minorticks_on()
    ax_keff.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_keff.yaxis.set_minor_locator(MultipleLocator(0.0025))

    ax_keff.tick_params(axis='both', which='major', labelsize=label_fontsize)

    ax_keff.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_keff.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_keff.set_xlabel(x_label, fontsize=label_fontsize)
    ax_keff.set_ylabel(y_label_keff, fontsize=label_fontsize)
    ax_keff.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize, loc='lower right')

    # Integral worth plot settings
    ax_int.set_xlim([0, 100])
    ax_int.set_ylim([-0.25, 3.5])

    # Overwrite set_ylim above for dollar units
    if rho_or_dollars == "dollars":
        ax_int.set_ylim([-0.25, 8.0])  # Use for dollars units
        ax_int.yaxis.set_major_formatter(
            FormatStrFormatter('%.2f'))  # Use for 2 decimal places after 0. for dollars units

    ax_int.xaxis.set_major_locator(MultipleLocator(10))
    ax_int.yaxis.set_major_locator(MultipleLocator(1))

    ax_int.minorticks_on()
    ax_int.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_int.yaxis.set_minor_locator(MultipleLocator(0.25))

    ax_int.tick_params(axis='both', which='major', labelsize=label_fontsize)

    ax_int.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_int.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_int.set_xlabel(x_label, fontsize=label_fontsize)
    ax_int.set_ylabel(y_label_int, fontsize=label_fontsize)
    ax_int.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize, loc='upper right')

    # Differential worth plot settings
    ax_dif.set_xlim([0, 100])
    ax_dif.set_ylim([0, 0.12])

    if rho_or_dollars == "dollars":
        ax_dif.set_ylim([0, 0.12])  # use for dollars/% units

    ax_dif.xaxis.set_major_locator(MultipleLocator(10))
    ax_dif.yaxis.set_major_locator(MultipleLocator(0.01))

    ax_dif.minorticks_on()
    ax_dif.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_dif.yaxis.set_minor_locator(MultipleLocator(0.0025))

    ax_dif.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_dif.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_dif.tick_params(axis='both', which='major', labelsize=label_fontsize)

    ax_dif.set_xlabel(x_label, fontsize=label_fontsize)
    ax_dif.set_ylabel(y_label_dif, fontsize=label_fontsize)
    # plt.title(f'Fuel Assembly B-1, {cycle_state}',fontsize=fs1)
    ax_dif.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize, loc='upper right')

    ax_keff.autoscale(enable=True, axis='y', tight=None)
    ax_dif.autoscale(enable=True, axis='y', tight=None)
    ax_int.autoscale(enable=True, axis='y', tight=None)


    plt.savefig(f"{figure_target_folder_path}/{figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]}", bbox_inches='tight',
                pad_inches=0.1, dpi=my_dpi)
    print(
        f"\nFigure {figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]} saved in {figure_target_folder_path}!\n")  # no space near \


if __name__ == "__main__":
    BankedRods(sys.argv[1:])
