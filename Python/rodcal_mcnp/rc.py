'''
ROD CALIBRATION (MCNP)

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu

This proejct should be available at 
https://github.com/patrickpark910/rodcal-mcnp/

Last updated Dec. 30, 2020

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

Go to GitHub link for a complete instructions.

NB: You can use this without MCNP. This repository should have the 
appropriate decks in ./inputs/ and ./outputs/ for this python program
to recognize and skip all the MCNP portions.

NB: You can also use this program plot your own worth curves (and skip all MCNP), 
if you have your own CSV of keff and uncertainty results. Change 'keff_csv_name'
to your file name and comment out the code between [START] and [END].

NB: To use this at another facility, you will have to edit find_height()
to match your MCNP deck. Namely, you will need to change (or add) a 
start marker, end marker, and adjust what surface number your rods start with. 
Reed's control rod cells start with '8', so I have hardcoded in
'line[0].startswith("8")' in the function. You will also need to edit math() to
add the right z-height that fits your core geometry.

'''

import os, sys, multiprocessing
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator, FormatStrFormatter


from mcnp_funcs import *

# Variables
cm_per_percent_height = 0.38 # Control rods have 38 cm of travel, so 0.38 cm/%
rods = ["safe", "shim", "reg"]
heights = [0, 20, 40, 50, 60, 80, 100]
# heights = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100] # % heights,
# for use in strings, use str(height).zfill(3) to pad 0s until it is 3 characters long,
# e.g. 'rc-reg-010.i'

filepath = os.path.dirname(os.path.abspath(__file__)) # do NOT include / at the end
inputs_folder_name = "inputs" # Folder for newly-generated MCNP input decks
outputs_folder_name = "outputs" # Folder for all MCNP output decks
keff_csv_name = "keff.csv" # File for keff and uncertainty values.
# NB: If you choose to load your own keff csv, 
# make sure to comment out the MCNP portions ("TO PLOT YOUR OWN KEFF") below, 
# or YOUR FILE WILL BE OVERWRITTEN.
rho_csv_name = "rho.csv" # File for rho and uncertainty values.
params_csv_name = "rod_parameters.csv"
figure_name = "results.png"

# Normal rod motion speed is about 11 inches (27.9 cm) per minute for the Shim rod, 19 inches (48.3 cm) per minute for the Safe rod, and 24 inches (61 cm) per minute for the Reg rod.

'''
Main function to be executed.

Use this 'def main(argv)' and 'if __name__ == "__main__": main(sys.argv[1:])' 
method to avoid functions from being inadvertently run if you try to
import this into another py file, e.g. 'from mcnp_funcs import *'.
'''
def main(argv):
    os.chdir(f'{filepath}')
    
    # ''' # [START] TO PLOT YOUR OWN KEFF: Remove first # to just plot rodcal data using a CSV of keff values.
    
    base_input_name = find_base_file(filepath)
    check_kcode(filepath, base_input_name)

    num_inputs_created = 0
    num_inputs_skipped = 0

    for height in heights:
        for rod in rods:
            if rod == 'reg':
                rod_heights_dict = {"safe": 100, "shim": 100, "reg": height}
                input_created = change_rod_height(filepath, 'rodcal', rod_heights_dict, base_input_name, inputs_folder_name)
                # change_rod_height(filepath, module_name, rod_heights_dict, base_input_name, inputs_folder_name)
                # Returns False if file already exists.
                # Otherwise, it finds and changes the heights and returns True.
                if input_created: num_inputs_created +=1
                if not input_created: num_inputs_skipped +=1
            if rod == 'shim':
                rod_heights_dict = {"safe": 100, "shim": height, "reg": 100}
                input_created = change_rod_height(filepath, 'rodcal', rod_heights_dict, base_input_name, inputs_folder_name)
                if input_created: num_inputs_created +=1
                if not input_created: num_inputs_skipped +=1
            elif rod == 'safe':
                rod_heights_dict = {"safe": height, "shim": 100, "reg": 100}
                input_created = change_rod_height(filepath, 'rodcal', rod_heights_dict, base_input_name, inputs_folder_name)
                if input_created: num_inputs_created +=1
                if not input_created: num_inputs_skipped +=1

    print(f"Created {num_inputs_created} new input decks.\n--Skipped {num_inputs_skipped} input decks because they already exist.")

    # Check if you want to run MCNP right now. 
    # check_run_mcnp() returns True or False. If False, quit program.
    if not check_run_mcnp(): sys.exit()

    # Run MCNP for all .i files in f".\{inputs_folder_name}".
    tasks = get_tasks()
    for file in os.listdir(f"{filepath}/{inputs_folder_name}"):
        run_mcnp(filepath,f"{filepath}/{inputs_folder_name}/{file}",outputs_folder_name,tasks)

    # Deletes MCNP runtape and source dist files.
    delete_files(f"{filepath}/{outputs_folder_name}",r=True,s=True)

    # Setup a dataframe to collect keff values
    keff_df = pd.DataFrame(columns=["height","safe", "safe unc", "shim", "shim unc", "reg", "reg unc"]) # use lower cases to match 'rods' def above
    keff_df["height"] = heights
    keff_df.set_index("height",inplace=True)

    # Add keff values to dataframe
    # NB: Use keff_df.iloc[row, column] to select by range integers, .loc[row, column] to select by row/column labels
    for height in heights:
        for rod in rods:
            if rod == 'safe':
                keff, keff_unc = extract_keff(f"{filepath}/{outputs_folder_name}/o_rodcal-a{str(height).zfill(3)}-h100-r100.o")
                keff_df.loc[height,rod] = keff
                keff_df.loc[height,f'{rod} unc'] = keff_unc
            elif rod == 'shim':
                keff, keff_unc = extract_keff(f"{filepath}/{outputs_folder_name}/o_rodcal-a100-h{str(height).zfill(3)}-r100.o")
                keff_df.loc[height,rod] = keff
                keff_df.loc[height,f'{rod} unc'] = keff_unc
            elif rod == 'reg':
                keff, keff_unc = extract_keff(f"{filepath}/{outputs_folder_name}/o_rodcal-a100-h100-r{str(height).zfill(3)}.o")
                keff_df.loc[height,rod] = keff
                keff_df.loc[height,f'{rod} unc'] = keff_unc
    
    print(f"\nDataframe of keff values and their uncertainties:\n{keff_df}\n")
    keff_df.to_csv(keff_csv_name)

    # ''' # [END] TO PLOT YOUR OWN KEFF: Remove first # to just plot rodcal data using a CSV of keff values.
    
    convert_keff_to_rho_rodcal(keff_csv_name,rho_csv_name)
    
    calc_params(rho_csv_name,params_csv_name)

    plot_rodcal_data(keff_csv_name,rho_csv_name,figure_name)

    print(f"\n************************ PROGRAM COMPLETE ************************\n")
    




'''
HELPER FUNCTIONS
'''

'''
Converts a CSV of keff and uncertainty values to a CSV of rho and uncertainty values.

keff_csv_name: str, name of CSV of keff values, including extension, "keff.csv"
rho_csv_name: str, desired name of CSV of rho values, including extension, "rho.csv"

Does not return anything. Only makes the actual file changes.
'''
def convert_keff_to_rho_rodcal(keff_csv_name,rho_csv_name):
    # Assumes the keff.csv has columns labeled "rod" and "rod unc" for keff and keff uncertainty values for a given rod
    keff_df = pd.read_csv(keff_csv_name,index_col=0)
    rods = [c for c in keff_df.columns.values.tolist() if "unc" not in c]
    heights = keff_df.index.values.tolist()

    # Setup a dataframe to collect rho values
    rho_df = pd.DataFrame(columns=keff_df.columns.values.tolist()) # use lower cases to match 'rods' def above
    rho_df["height"] = heights
    rho_df.set_index("height",inplace=True)

    '''
    ERROR PROPAGATION FORMULAE
    % Delta rho = 100* frac{k2-k1}{k2*k1}
    numerator = k2-k1
    delta num = sqrt{(delta k2)^2 + (delta k1)^2}
    denominator = k2*k1
    delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
    delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
    '''   
    for rod in rods: 
        for height in heights: 
            k1 = keff_df.loc[height,rod]
            k2 = keff_df.loc[heights[-1],rod]
            dk1 = keff_df.loc[height,f"{rod} unc"] 
            dk2 = keff_df.loc[heights[-1],f"{rod} unc"] 
            k2_minus_k1 = k2-k1
            k2_times_k1 = k2*k1
            d_k2_minus_k1 = np.sqrt(dk2**2+dk1**2)
            d_k2_times_k1 = k2*k1*np.sqrt((dk2/k2)**2+(dk1/k1)**2)
            rho = (k2-k1)/(k2*k1)*100

            rho_df.loc[height,rod] = rho
            if k2_minus_k1 != 0: 
                d_rho = rho*np.sqrt((d_k2_minus_k1/k2_minus_k1)**2+(d_k2_times_k1/k2_times_k1)**2)
                rho_df.loc[height,f"{rod} unc"] = d_rho
            else: rho_df.loc[height,f"{rod} unc"] = 0

    print(f"\nDataframe of rho values and their uncertainties:\n{rho_df}\n")
    rho_df.to_csv(f"{rho_csv_name}")



'''
Calculates a few other rod parameters.

rho_csv_name: str, name of CSV of rho values to read from, e.g. "rho.csv"
params_csv_name: str, desired name of CSV of rod parameters, e.g. "rod_parameters.csv"

Does not return anything. Only performs file creation.
'''
def calc_params(rho_csv_name,params_csv_name):
    rho_df = pd.read_csv(rho_csv_name,index_col=0)
    rods = [c for c in rho_df.columns.values.tolist() if "unc" not in c]
    heights = rho_df.index.values.tolist()
    
    beta_eff = 0.0075
    react_add_rate_limit = 0.16
    motor_speed = {"safe":19,"shim":11,"reg":24} # inches/min
    
    parameters = ["worth ($)","max worth added per % height ($/%)", "max worth added per height ($/in)", "reactivity addition rate ($/sec)","max motor speed (in/min)"]
    
    # Setup a dataframe to collect rho values
    params_df = pd.DataFrame(columns=parameters) # use lower cases to match 'rods' def above
    params_df["rod"] = rods
    params_df.set_index("rod",inplace=True)
   
    for rod in rods: # We want to sort our curves by rods
        rho = rho_df[f"{rod}"].tolist()
        # worth ($) = rho / beta_eff, rho values are in % rho per NIST standard
        worth = 0.01*float(max(rho)) / float(beta_eff) 
        params_df.loc[rod,parameters[0]] = worth
        
        int_eq = np.polyfit(heights,rho,3) # coefs of integral worth curve equation
        dif_eq = -1*np.polyder(int_eq)
        max_worth_rate_per = 0.01*max(np.polyval(dif_eq,heights)) / float(beta_eff) 
        params_df.loc[rod,parameters[1]] = max_worth_rate_per
        
        max_worth_rate_inch = float(max_worth_rate_per) / float(CM_PER_PERCENT_HEIGHT) * 2.54
        params_df.loc[rod,parameters[2]] = max_worth_rate_inch
        
        # Normal rod motion speed is about: 
        # 19 inches (48.3 cm) per minute for the Safe rod,
        # 11 inches (27.9 cm) per minute for the Shim rod, 
        # 24 inches (61.0 cm) per minute for the Reg rod.
        
        react_add_rate = motor_speed[rod]*max_worth_rate_inch/60
        params_df.loc[rod,parameters[3]] = react_add_rate
        
        max_motor_speed = 1/max_worth_rate_inch*react_add_rate_limit*60
        params_df.loc[rod,parameters[4]] = max_motor_speed

    print(f"\nVarious rod parameters:\n{params_df}")
    params_df.to_csv(params_csv_name)



'''
Plots integral and differential worths given a CSV of rho and uncertainties.

rho_csv_name: str, name of CSV of rho and uncertainties, e.g. "rho.csv"
figure_name: str, desired name of resulting figure, e.g. "figure.png"

Does not return anything. Only produces a figure.

NB: Major plot settings have been organized into variables for your personal convenience.
'''
def plot_rodcal_data(keff_csv_name,rho_csv_name,figure_name):
    keff_df = pd.read_csv(keff_csv_name,index_col=0)
    rho_df = pd.read_csv(rho_csv_name,index_col=0)
    rods = [c for c in rho_df.columns.values.tolist() if "unc" not in c]
    heights = rho_df.index.values.tolist()
    
    # Determine plot units in rho or dollars.
    rho_or_dollars = None
    while rho_or_dollars is None:
        rho_or_dollars_input = input("Would you like your plot in rho or dollars? Type 'rho' or 'dollars', or 'q' to quit: ")
        if rho_or_dollars_input.lower() in ['r','rho','p']: rho_or_dollars = 'rho'
        elif rho_or_dollars_input.lower() in ['d','dol','dollar','dollars','$']: rho_or_dollars = 'dollars'
        elif rho_or_dollars_input.lower() in ['q','quit','kill']: sys.exit()
        else: print("Units unknown. Try again.")
    
    # Personal parameters, to be used in plot settings below.
    my_dpi = 320
    x_label = "Axial height withdrawn (%)"
    y_label_keff = r"Effective multiplication factor ($k_{eff}$)"    
    
    if rho_or_dollars == 'dollars':
        y_label_int = r"Integral worth ($)"
        y_label_dif = r"Differential worth ($/%)"

    else: # Use axes labels below for units of rho
        y_label_int = r"Integral worth ($\%\Delta\rho$)"
        y_label_dif = r"Differential worth ($\%\Delta\rho$/%)"

    label_fontsize = 16
    legend_fontsize = "x-large"
    # fontsize: int or {'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large'}
    

    fig,axs = plt.subplots(3,1, figsize=(1636/96, 3*673/96), dpi=my_dpi,facecolor='w',edgecolor='k')
    ax_keff, ax_int, ax_dif = axs[0], axs[1], axs[2] # integral, differential worth on top, bottom, resp.
    color = {rods[0]:"tab:red",rods[1]:"tab:green",rods[2]:"tab:blue"}
    
    for rod in rods: # We want to sort our curves by rods
        # Plot data for keff.
        y_keff = keff_df[f"{rod}"].tolist()
        y_unc_keff = keff_df[f"{rod} unc"].tolist()
        
        ax_keff.errorbar(heights, y_keff, yerr=y_unc_keff,
                        marker="o",ls="none",
                        color=color[rod],elinewidth=2,capsize=3,capthick=2)
        
        eq_keff = np.polyfit(heights,y_keff,3) # coefs of integral worth curve equation
        x_fit = np.linspace(heights[0],heights[-1],heights[-1]-heights[0]+1)
        y_fit_keff = np.polyval(eq_keff,x_fit)
        
        ax_keff.plot(x_fit,y_fit_keff,color=color[rod],label=f'{rod.capitalize()}')
        
        # Plot data for integral worth.
        y_int = rho_df[f"{rod}"].tolist()
        y_unc_int = rho_df[f"{rod} unc"].tolist()
        
        if rho_or_dollars == 'dollars':
            y_int = [x * 0.01 / 0.0075 for x in y_int] 
            y_unc_int = [x * 0.01 / 0.0075 for x in y_unc_int] 

        int_eq = np.polyfit(heights,y_int,3) # coefs of integral worth curve equation
        x_fit = np.linspace(heights[0],heights[-1],heights[-1]-heights[0]+1)
        y_fit_int = np.polyval(int_eq,x_fit)
        
        # Data points with error bars
        ax_int.errorbar(heights, y_int, yerr=y_unc_int,
                            marker="o",ls="none",
                            color=color[rod],elinewidth=2,capsize=3,capthick=2)
        
        # The standard least squaures fit curve
        ax_int.plot(x_fit,y_fit_int,color=color[rod],label=f'{rod.capitalize()}')

        dif_eq = -1*np.polyder(int_eq) # coefs of differential worth curve equation
        y_dif_fit = np.polyval(dif_eq,x_fit)
        
        # The differentiated curve.
        # The errorbar method allows you to add errors to the differential plot too.
        ax_dif.errorbar(x_fit, y_dif_fit,
                            label=f'{rod.capitalize()}',
                            color=color[rod],linewidth=2,capsize=3,capthick=2)
    
    # Keff plot settings
    ax_keff.set_xlim([0,100])
    ax_keff.set_ylim([1.004,1.03])

    ax_keff.xaxis.set_major_locator(MultipleLocator(10))
    ax_keff.yaxis.set_major_locator(MultipleLocator(0.005))
    
    ax_keff.minorticks_on()
    ax_keff.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_keff.yaxis.set_minor_locator(MultipleLocator(0.001))
    
    ax_keff.tick_params(axis='both', which='major', labelsize=label_fontsize)
    
    ax_keff.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_keff.grid(which='minor', linestyle=':', linewidth='1', color='gray')
    
    ax_keff.set_xlabel(x_label,fontsize=label_fontsize)
    ax_keff.set_ylabel(y_label_keff,fontsize=label_fontsize)
    ax_keff.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize,loc='lower right')
    
    # Integral worth plot settings
    ax_int.set_xlim([0,100])
    ax_int.set_ylim([-0.25,3.5])

    # Overwrite set_ylim above for dollar units
    if rho_or_dollars == "dollars":
        ax_int.set_ylim([-0.25,3.5]) # Use for dollars units
        ax_int.yaxis.set_major_formatter(FormatStrFormatter('%.2f')) # Use for 2 decimal places after 0. for dollars units

    ax_int.xaxis.set_major_locator(MultipleLocator(10))
    ax_int.yaxis.set_major_locator(MultipleLocator(0.5))
    
    ax_int.minorticks_on()
    ax_int.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_int.yaxis.set_minor_locator(MultipleLocator(0.125))
    
    ax_int.tick_params(axis='both', which='major', labelsize=label_fontsize)
    
    ax_int.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_int.grid(which='minor', linestyle=':', linewidth='1', color='gray')
    
    ax_int.set_xlabel(x_label,fontsize=label_fontsize)
    ax_int.set_ylabel(y_label_int,fontsize=label_fontsize)
    ax_int.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize,loc='upper right')
    
    # Differential worth plot settings
    ax_dif.set_xlim([0,100])
    ax_dif.set_ylim([0,0.06])

    if rho_or_dollars == "dollars": 
        ax_dif.set_ylim([0,0.05]) # use for dollars/% units

    ax_dif.xaxis.set_major_locator(MultipleLocator(10))
    ax_dif.yaxis.set_major_locator(MultipleLocator(0.01))
    
    ax_dif.minorticks_on()
    ax_dif.xaxis.set_minor_locator(MultipleLocator(2.5))
    ax_dif.yaxis.set_minor_locator(MultipleLocator(0.0025))
    
    ax_dif.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_dif.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_dif.tick_params(axis='both', which='major', labelsize=label_fontsize)
    
    ax_dif.set_xlabel(x_label,fontsize=label_fontsize)
    ax_dif.set_ylabel(y_label_dif,fontsize=label_fontsize)
    #plt.title(f'Fuel Assembly B-1, {cycle_state}',fontsize=fs1)
    ax_dif.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=4, fontsize=legend_fontsize, loc='upper right')
    
    plt.savefig(f"{figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]}", bbox_inches = 'tight', pad_inches = 0.1, dpi=my_dpi)
    print(f"\nFigure '{figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]}' saved!\n") # no space near \ 
    




if __name__ == "__main__":
    main(sys.argv[1:])
        
