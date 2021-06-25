"""
FUEL TEMPERATURE COEFFICIENT (MCNP)

Written by Patrick Park (RO, Physics '22)
ppark@reed.edu

This project should be available at
https://github.com/patrickpark910/pntc/

First written Feb. 16, 2021
Last updated Feb. 17, 2021

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

To fully calculate fuel temp coef, you need to change the TMP= value on each cell with a fuel mat,
AND switch out the S(a,b) cross section library (e.g., 92235.80c <-- ) for the right TMP.
Look up the right S(a,b) library names in LA-UR-13-21822.

mcnp_funcs only has TEMP_DICTS using ENDF VII libraries, as ENDF VI do not all have DN/UR calculations
Look up DN and UR here: https://mcnp.lanl.gov/pdf_files/la-ur-13-21822v4.pdf

MCNP6.2 does not support all cross-section (xs) libraries.
If the xs library is unsupported, a fatal error will occur.
./MCNP_DATA/xsdir_mcnp6.2 contains a list of all the xs libraries supported by MCNP6.2.

"""

import os, sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from num2tex import num2tex

from mcnp_funcs import *

FILEPATH = os.path.dirname(os.path.abspath(__file__))
WATER_MAT_CARD = '102'
FUEL_TEMPS = list(U235_TEMP_DICT.keys())
# [200,250,300,350,400,450,500,650,700,750,800,850,900,950,1000,1050,1100,1150,1200,1250,1300,1350,1400]
# Prefer hardcoded lists rather than np.arange, which produces imprecise floating points, e.g., 0.7000000...003
# Select temperature range that covers all study ranges:
# https://mcnp.lanl.gov/pdf_files/la-ur-12-20338.pdf (slide 9)
INPUTS_FOLDER_NAME = 'inputs'
OUTPUTS_FOLDER_NAME = 'outputs'
MODULE_NAME = 'pntc'
KEFF_CSV_NAME = f'{MODULE_NAME}_keff.csv'
RHO_CSV_NAME = f'{MODULE_NAME}_rho.csv'
PARAMS_CSV_NAME = f'{MODULE_NAME}_parameters.csv'
FIGURE_NAME = f'{MODULE_NAME}_results.png'


def main():
    initialize_rane()

    BASE_INPUT_NAME = 'pntc-a100-h100-r100.i'  # find_base_file(FILEPATH)
    check_kcode(FILEPATH, BASE_INPUT_NAME)

    num_inputs_created = 0
    num_inputs_skipped = 0
    for i in range(0, len(FUEL_TEMPS)):
        cell_temps_dict = {}
        for fe_id in list(FE_ID.values()): cell_temps_dict[fe_id] = FUEL_TEMPS[i]
        input_created = change_cell_and_mat_temps(FILEPATH, MODULE_NAME, cell_temps_dict, BASE_INPUT_NAME,
                                                  INPUTS_FOLDER_NAME)
        if input_created: num_inputs_created += 1
        if not input_created: num_inputs_skipped += 1

    print(f"Created {num_inputs_created} new input decks.\n"
          f"--Skipped {num_inputs_skipped} input decks because they already exist.")

    if not check_run_mcnp(): sys.exit()

    # Run MCNP for all .i files in f".\{inputs_folder_name}".
    tasks = get_tasks()
    for file in os.listdir(f"{FILEPATH}/{INPUTS_FOLDER_NAME}"):
        run_mcnp(FILEPATH, f"{FILEPATH}/{INPUTS_FOLDER_NAME}/{file}", OUTPUTS_FOLDER_NAME, tasks)

    # Deletes MCNP runtape and source dist files.
    delete_files(f"{FILEPATH}/{OUTPUTS_FOLDER_NAME}", r=True, s=True)

    # Setup a dataframe to collect keff values
    keff_df = pd.DataFrame(columns=["x", "keff", "keff unc"])  # use lower cases to match 'rods' def above
    keff_df["x"] = FUEL_TEMPS
    keff_df.set_index("x", inplace=True)

    for fuel_temp in FUEL_TEMPS:
        keff, keff_unc = extract_keff(
            f"{FILEPATH}/{OUTPUTS_FOLDER_NAME}/o_{MODULE_NAME}-temp-{str(int(fuel_temp)).zfill(4)}.o")
        keff_df.loc[fuel_temp, 'keff'] = keff
        keff_df.loc[fuel_temp, 'keff unc'] = keff_unc

    print(f"\nDataframe of keff values and their uncertainties:\n{keff_df}\n")
    keff_df.to_csv(KEFF_CSV_NAME)

    convert_keff_to_rho_coef(float(0.1), KEFF_CSV_NAME, RHO_CSV_NAME)
    calc_params_coef(RHO_CSV_NAME, PARAMS_CSV_NAME, MODULE_NAME)

    for rho_or_dollars in ['rho', 'dollars']: plot_data_pntc(KEFF_CSV_NAME, RHO_CSV_NAME, PARAMS_CSV_NAME, FIGURE_NAME,
                                                             rho_or_dollars)

    print(f"\n************************ PROGRAM COMPLETE ************************\n")


'''
Plots integral and differential worths given a CSV of rho and uncertainties.

rho_csv_name: str, name of CSV of rho and uncertainties, e.g. "rho.csv"
figure_name: str, desired name of resulting figure, e.g. "figure.png"

Does not return anything. Only produces a figure.

NB: Major plot settings have been organized into variables for your personal convenience.
'''


def plot_data_pntc(keff_csv_name, rho_csv_name, params_csv_name, figure_name, rho_or_dollars):
    if rho_or_dollars.lower() in ['r', 'p', 'rho']:
        rho_or_dollars = 'rho'
    elif rho_or_dollars.lower() in ['d', 'dollar', 'dollars']:
        rho_or_dollars = 'dollars'

    keff_df = pd.read_csv(keff_csv_name, index_col=0)
    rho_df = pd.read_csv(rho_csv_name, index_col=0)
    params_df = pd.read_csv(params_csv_name, index_col=0)
    x_values_list = rho_df.index.values.tolist()

    # Personal parameters, to be used in plot settings below.
    sigma_error = 3 # 1-sigma (68%) errors are usually too small to be discernable, so I (and USGS) likes to use 3-sigma
    label_fontsize = 16
    legend_fontsize = "x-large"
    # fontsize: int or {'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large'}
    my_dpi = 320
    x_label = r"Fuel temperature (K) "
    y_label_keff, y_label_rho, y_label_coef = r"Effective multiplication factor ($k_{eff}$)", \
                                              r"Reactivity ($\%\Delta k/k$)", \
                                              r"Fuel temperature coefficient ((%$\Delta k/k$)/$\degree$C)"
    if rho_or_dollars == 'dollars':
        y_label_rho, y_label_coef = r"Reactivity ($\Delta$\$)", r"Fuel temperature coefficient ($\Delta$\$/$\degree$C)"

    plot_color = ["tab:red", "tab:blue", "tab:green"]

    ax_x_min, ax_x_max = 0, 3250
    ax_x_major_ticks_interval, ax_x_minor_ticks_interval = 500, 100

    ax_keff_y_min, ax_keff_y_max = 0.85, 1.1
    ax_keff_y_major_ticks_interval, ax_keff_y_minor_ticks_interval = 0.05, 0.01

    ax_rho_y_min, ax_rho_y_max = -14, 2
    ax_rho_y_major_ticks_interval, ax_rho_y_minor_ticks_interval = 2, 1
    if rho_or_dollars == 'dollars':
        ax_rho_y_min, ax_rho_y_max = -20, 1.5
        ax_rho_y_major_ticks_interval, ax_rho_y_minor_ticks_interval = 5, 1

    ax_pntc_y_min, ax_pntc_y_max = -0.024,0.004
    ax_pntc_y_major_ticks_interval, ax_pntc_y_minor_ticks_interval = 0.01, 0.002
    if rho_or_dollars == 'dollars':
        ax_pntc_y_min, ax_pntc_y_max = -0.02,0.004
        ax_pntc_y_major_ticks_interval, ax_pntc_y_minor_ticks_interval = 0.004, 0.002

    fig, axs = plt.subplots(3, 1, figsize=(1636 / 96, 3 * 673 / 96), dpi=my_dpi, facecolor='w', edgecolor='k')
    ax_keff, ax_rho, ax_coef = axs[0], axs[1], axs[2]  # integral, differential worth on top, bottom, resp.

    # Plot data for keff.
    x = x_values_list
    x_fit = np.linspace(min(x), max(x), 100*len(x_values_list))
    y_keff, y_keff_unc = [], []
    for value in x:
        y_keff.append(keff_df.loc[value, 'keff']), y_keff_unc.append(sigma_error*keff_df.loc[value, 'keff unc'])

    ax_keff.errorbar(x, y_keff, yerr=y_keff_unc,
                     marker="o", ls="none",
                     color=plot_color[0], elinewidth=2, capsize=3, capthick=2)

    eq_keff = find_poly_reg(x, y_keff, 2)['polynomial']  # n=2 order fit
    r2_keff = find_poly_reg(x, y_keff, 2)['r-squared']
    sd_keff = np.average(np.abs(np.polyval(np.polyfit(x, y_keff, 2), x) - y_keff))
    # for this plot, the (x,y) must be sorted
    # list.sort() sorts the list itself in place, so use sorted(list)
    y_fit_keff = np.polyval(eq_keff, x_fit)

    # for exponential strings (:.Xe) use num2tex(eq_keff[i]) to convert it into TeX exponential string
    # but that also kinda looks ugly ngl
    ax_keff.plot(x_fit, y_fit_keff, color=plot_color[0],
                 label=r'y= {:.2e} $x^2$ {:.2e} $x$ +{:.2f},  $R^2$= {:.2f},  $\Sigma$= {:.2e}'.format(
                     eq_keff[0], eq_keff[1], eq_keff[2], r2_keff, sd_keff))

    # Plot data for reactivity
    y_rho, y_rho_unc = [], []
    for value in x:
        if rho_or_dollars == 'rho': y_rho.append(rho_df.loc[value, 'rho']), y_rho_unc.append(
            sigma_error*rho_df.loc[value, 'rho unc'])
        if rho_or_dollars == 'dollars': y_rho.append(rho_df.loc[value, 'dollars']), y_rho_unc.append(
            sigma_error*rho_df.loc[value, 'dollars unc'])
    ax_rho.errorbar(x, y_rho, yerr=y_rho_unc,
                    marker="o", ls="none",
                    color=plot_color[1], elinewidth=2, capsize=3, capthick=2)

    eq_rho = find_poly_reg(x, y_rho, 2)['polynomial']  # n=2 order fit
    r2_rho = find_poly_reg(x, y_rho, 2)['r-squared']
    sd_rho = np.average(np.abs(np.polyval(np.polyfit(x, y_rho, 2), x) - y_rho))
    y_fit_rho = np.polyval(eq_rho, x_fit)

    ax_rho.plot(x_fit, y_fit_rho, color=plot_color[1],
                label=r'y= {:.2e} $x^2$ {:.2e} $x$ +{:.2f},  $R^2$= {:.2f},  $\Sigma$= {:.2f}'.format(
                    eq_rho[0], eq_rho[1], eq_rho[2], r2_rho, sd_rho))

    # Plot data for coef
    y_coef, y_coef_unc = [], []
    for value in x:
        if rho_or_dollars == 'rho':
            y_coef.append(params_df.loc[value, 'coef rho']), y_coef_unc.append(
                sigma_error*params_df.loc[value, 'coef rho unc'])
        else:
            y_coef.append(params_df.loc[value, 'coef dollars']), y_coef_unc.append(
                sigma_error*params_df.loc[value, 'coef dollars unc'])

    ax_coef.errorbar(x, y_coef, yerr=y_coef_unc,
                     marker="o", ls="none",
                     color=plot_color[2], elinewidth=2, capsize=3, capthick=2)

    eq_coef = find_poly_reg(x, y_coef, 1)['polynomial']
    r2_coef = find_poly_reg(x, y_coef, 1)['r-squared']
    sd_coef = np.average(np.abs(np.polyval(np.polyfit(x, y_coef, 1), x) - y_coef))
    y_fit_coef = np.polyval(eq_coef, x_fit)

    ax_coef.plot(x_fit, y_fit_coef, color=plot_color[2],
                 label=r'y= {:.2e} $x$ {:.2e},  $\bar x$$\pm\Sigma$= {:.2e}$\pm${:.2e}'.format(
                     eq_coef[0], eq_coef[1], np.mean(y_fit_coef), sd_coef))

    eq_coef_der = np.polyder(eq_rho)  # n=2 order fit
    y_fit_coef_der = np.polyval(eq_coef_der, x_fit)

    ax_coef.plot(x_fit, y_fit_coef_der, color=plot_color[2], linestyle='dashed',
                 label=r'y= {:.2e} $x$ {:.2e},  $\bar x$= {:.2e}'.format(
                     eq_coef_der[0], eq_coef_der[1], np.mean(y_fit_coef_der)))

    # Keff plot settings
    ax_keff.set_xlim([ax_x_min, ax_x_max])
    ax_keff.set_ylim([ax_keff_y_min, ax_keff_y_max])
    ax_keff.xaxis.set_major_locator(MultipleLocator(ax_x_major_ticks_interval))
    ax_keff.yaxis.set_major_locator(MultipleLocator(ax_keff_y_major_ticks_interval))
    ax_keff.minorticks_on()
    ax_keff.xaxis.set_minor_locator(MultipleLocator(ax_x_minor_ticks_interval))
    ax_keff.yaxis.set_minor_locator(MultipleLocator(ax_keff_y_minor_ticks_interval))

    ax_keff.tick_params(axis='both', which='major', labelsize=label_fontsize)
    ax_keff.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_keff.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_keff.set_xlabel(x_label, fontsize=label_fontsize)
    ax_keff.set_ylabel(y_label_keff, fontsize=label_fontsize)
    ax_keff.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=1, fontsize=legend_fontsize, loc='upper right')

    # Reactivity worth plot settings
    ax_rho.set_xlim([ax_x_min, ax_x_max])
    ax_rho.set_ylim([ax_rho_y_min, ax_rho_y_max])
    ax_rho.xaxis.set_major_locator(MultipleLocator(ax_x_major_ticks_interval))
    ax_rho.yaxis.set_major_locator(MultipleLocator(ax_rho_y_major_ticks_interval))
    ax_rho.minorticks_on()
    ax_rho.xaxis.set_minor_locator(MultipleLocator(ax_x_minor_ticks_interval))
    ax_rho.yaxis.set_minor_locator(MultipleLocator(ax_rho_y_minor_ticks_interval))

    # Use for 2 decimal places after 0. for dollars units
    if rho_or_dollars == "dollars": ax_rho.yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

    ax_rho.tick_params(axis='both', which='major', labelsize=label_fontsize)
    ax_rho.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_rho.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_rho.set_xlabel(x_label, fontsize=label_fontsize)
    ax_rho.set_ylabel(y_label_rho, fontsize=label_fontsize)
    ax_rho.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=1, fontsize=legend_fontsize, loc='upper right')

    # Coef worth plot settings
    ax_coef.set_xlim([ax_x_min, ax_x_max])
    ax_coef.set_ylim([ax_pntc_y_min, ax_pntc_y_max])
    ax_coef.xaxis.set_major_locator(MultipleLocator(ax_x_major_ticks_interval))
    ax_coef.yaxis.set_major_locator(MultipleLocator(ax_pntc_y_major_ticks_interval))
    ax_coef.minorticks_on()
    ax_coef.xaxis.set_minor_locator(MultipleLocator(ax_x_minor_ticks_interval))
    ax_coef.yaxis.set_minor_locator(MultipleLocator(ax_pntc_y_minor_ticks_interval))

    # Use for 2 decimal places after 0. for dollars units
    # Overwritten to 3 decimal places for PNTC
    if rho_or_dollars == "dollars": ax_coef.yaxis.set_major_formatter(FormatStrFormatter('%.3f'))

    ax_coef.tick_params(axis='both', which='major', labelsize=label_fontsize)
    ax_coef.grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
    ax_coef.grid(which='minor', linestyle=':', linewidth='1', color='gray')

    ax_coef.set_xlabel(x_label, fontsize=label_fontsize)
    ax_coef.set_ylabel(y_label_coef, fontsize=label_fontsize)
    ax_coef.legend(title=f'Key', title_fontsize=legend_fontsize, ncol=1, fontsize=legend_fontsize, loc='lower right')

    plt.savefig(f"{figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]}", bbox_inches='tight',
                pad_inches=0.1, dpi=my_dpi)
    print(
        f"\nFigure '{figure_name.split('.')[0]}_{rho_or_dollars}.{figure_name.split('.')[-1]}' saved!\n")  # no space near \


if __name__ == '__main__':
    main()
