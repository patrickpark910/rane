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
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
import matplotlib.colors as colors
import json


from MCNP_File import *
from Utilities import *
from Parameters import *
from plotStyles import *


class Reactivity(MCNP_File):




    def process_rcty_keff(self):

        """
        Output results filepaths
        """
        self.keff_filename = f'{self.base_filename}_{self.rcty_type}_keff.csv'
        self.keff_filepath = f"{self.results_folder}/{self.keff_filename}"

        self.params_filename = f'{self.base_filename}_{self.rcty_type}_params.csv'
        self.params_filepath = f"{self.results_folder}/{self.params_filename}"

        print(f'\n processing: {self.output_filename}')

        self.extract_keff()

        """
        Define the index column and data to be used in dataframe
        """
        self.h2o_temp_C = float('{:.2f}'.format(self.h2o_temp_K - 273.15))
        if self.rcty_type == 'fuel':
            self.index_header, self.index_data = 'temp (C)', UZRH_FUEL_TEMPS_C
            self.row_val = self.h2o_temp_C
            self.row_base_val = 20 # 20 C is default fuel temp in mcnp
        elif self.rcty_type == 'mod':
            self.index_header, self.index_data = 'temp (C)', H2O_MOD_TEMPS_C
            self.keff_row, self.keff_col = self.h2o_temp_C
            self.row_val = self.h2o_temp_C
            self.row_base_val = 20 # 20 C is default h2o temp
        elif self.rcty_type == 'void':
            self.index_header, self.index_data = 'density (g/cc)', H2O_VOID_DENSITIES 
            self.row_val = self.h2o_temp_C
            self.row_base_val = 1.0 # 1.0 g/cc is default density

        """
        Setup or read keff dataframe
        """
        if self.keff_filename in os.listdir(self.results_folder):
            try:
                df_keff = pd.read_csv(self.keff_filepath, encoding='utf8')
                df_keff.set_index(self.index_header, inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.keff_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the index (first column) header is '{self.index_header}'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.keff_filepath}')
            df_keff = pd.DataFrame(self.index_data, columns=[self.index_header])
            df_keff.set_index(self.index_header, inplace=True)
            df_keff["keff"] = 0.0 
            df_keff["keff unc"] = 0.0 

        """
        Populate the dataframe with keff and unc values
        """
        df_keff.loc[self.row_val, "keff"] = self.keff
        df_keff.loc[self.row_val, "keff unc"] = self.keff_unc
        df_keff.to_csv(self.keff_filepath, encoding='utf8')


    def process_rcty_rho(self):

        self.rho_filename = f'{self.base_filename}_{self.rcty_type}_rho.csv'
        self.rho_filepath = f"{self.results_folder}/{self.rho_filename}"

        df_keff = pd.read_csv(self.keff_filepath, index_col=0)

        """
        Setup or read rho dataframe
        """
        if self.rho_filename in os.listdir(self.results_folder):
            try:
                df_rho = pd.read_csv(self.rho_filepath, encoding='utf8')
                df_rho.set_index(self.index_header, inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.rho_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the index (first column) header is '{self.index_header}'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.rho_filepath}')
            df_rho = pd.DataFrame(self.index_data, columns=[self.index_header])
            df_rho.set_index(self.index_header, inplace=True)
            df_rho["rho"] = 0.0 
            df_rho["rho unc"] = 0.0 

        '''
        ERROR PROPAGATION FORMULAE
        % Delta rho = 100* frac{k2-k1}{k2*k1}
        numerator = k2-k1
        delta num = sqrt{(delta k2)^2 + (delta k1)^2}
        denominator = k2*k1
        delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
        delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
        '''
        for x_value in self.index_data:
            k1 = df_keff.loc[x_value, 'keff']
            k2 = df_keff.loc[self.row_base_val, 'keff']
            dk1 = df_keff.loc[x_value, 'keff unc']
            dk2 = df_keff.loc[self.row_base_val, 'keff unc']
            k2_minus_k1 = k2 - k1
            k2_times_k1 = k2 * k1
            d_k2_minus_k1 = np.sqrt(dk2 ** 2 + dk1 ** 2)
            d_k2_times_k1 = k2 * k1 * np.sqrt((dk2 / k2) ** 2 + (dk1 / k1) ** 2)
            rho = -(k2 - k1) / (k2 * k1) * 100
            dollars = 0.01 * rho / BETA_EFF

            df_rho.loc[x_value, 'rho'] = rho
            df_rho.loc[x_value, 'dollars'] = dollars
            # while the 'dollars' (and 'dollars unc') columns are not in the original df_rho definition,
            # simply defining a value inside it automatically adds the column
            if k2_minus_k1 != 0:
                rho_unc = rho * np.sqrt((d_k2_minus_k1 / k2_minus_k1) ** 2 + (d_k2_times_k1 / k2_times_k1) ** 2)
                dollars_unc = rho_unc / 100 / BETA_EFF
                df_rho.loc[x_value, 'rho unc'], df_rho.loc[x_value, 'dollars unc'] = rho_unc, dollars_unc
            else:
                df_rho.loc[x_value, 'rho unc'], df_rho.loc[x_value, 'dollars unc'] = 0, 0

        print(f"\nDataframe of rho values and their uncertainties:\n{df_rho}\n")
        df_rho.to_csv(self.rho_filepath, encoding='utf8')


    def process_rcty_coef(self):

        df_keff = pd.read_csv(self.keff_filepath)
        df_rho  = pd.read_csv(self.rho_filepath)

        df_keff.set_index(self.index_header, inplace=True)
        df_rho.set_index(self.index_header, inplace=True)
    
        rods = [c for c in df_rho.columns.values.tolist() if "unc" not in c]
        heights = list(df_keff.index.values)

        if self.rcty_type == 'mod':
            self.rcty_label = 'moderator'
        else:
            self.rcty_label = self.rcty_type


        for rho_or_dollars in ['rho', 'dollars']:
            fig, axs = plt.subplots(3,1, figsize=FIGSIZE,facecolor='w',edgecolor='k')
            axs = axs.ravel()

            # linestyle = ['-': solid, '--': dashed, '-.' dashdot, ':': dot]

            for i in [0,1,2]:
                axs[i].set_xlim([0,100])
                axs[i].xaxis.set_major_locator(MultipleLocator(10))
                axs[i].autoscale(axis='y')
                axs[i].grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
            
            axs[0].set_ylabel(r'Effective multiplication factor ($k_{eff}$)')
            axs[0].tick_params(axis='both', which='major')

            axs[1].set_ylabel('Reactivity (%Δρ)')
            axs[1].tick_params(axis='both', which='major')
            if rho_or_dollars == 'dollars':
                axs[1].set_ylabel('Reactivity (Δ$)')
                axs[1].yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
            
            axs[2].set_xlabel('Temperature (°C)')
            axs[2].set_ylabel('Differential worth (%Δρ/°C)')
            axs[2].tick_params(axis='both', which='major')
            if rho_or_dollars == 'dollars':
                axs[2].set_ylabel(f'{self.rcty_label.capitalize()} temp. coef. (Δ$/°C)')
                axs[2].yaxis.set_major_formatter(FormatStrFormatter('%.4f'))


            """
            Keff plot
            """
            ax = axs[0]

            y     = df_keff[f"keff"].tolist()
            y_unc = df_keff[f"keff unc"].tolist()
            
            ax.errorbar(heights, y, yerr=y_unc,
                        marker=MARKER_STYLES[self.rcty_type], ls="none",
                        color=LINE_COLORS[self.rcty_type], elinewidth=2, capsize=3, capthick=2)
            
            eq_fit = np.polyfit(heights,y,1) # coefs of integral worth curve equation
            x_fit  = np.linspace(heights[0],heights[-1],heights[-1]-heights[0]+1)
            y_fit  = np.polyval(eq_fit,x_fit)
            
            ax.plot(x_fit, y_fit, label=f'{self.rcty_label.capitalize()}',
                    color=LINE_COLORS[self.rcty_type], linestyle=LINE_STYLES[self.rcty_type], linewidth=LINEWIDTH)
            ax.legend(ncol=3, loc='lower center')

            """
            Integral worth plot
            """
            ax = axs[1]            

            y     = df_rho[f"rho"].tolist()
            y_unc = df_rho[f"rho unc"].tolist()
            if rho_or_dollars == 'dollars':
                y     = df_rho[f"dollars"].tolist()
                y_unc = df_rho[f"dollars unc"].tolist()

            eq_fit = np.polyfit(heights,y,1) # coefs of integral worth curve equation
            y_fit  = np.polyval(eq_fit,x_fit)
            
            # Data points with error bars
            heights
            ax.errorbar(heights, y, yerr=y_unc,
                        marker=MARKER_STYLES[self.rcty_type],ls="none",
                        color=LINE_COLORS[self.rcty_type], elinewidth=2, capsize=3, capthick=2)
            
            # The standard least squaures fit curve
            ax.plot(x_fit, y_fit, label=f'{self.rcty_label.capitalize()}',
                    color=LINE_COLORS[self.rcty_type], linestyle=LINE_STYLES[self.rcty_type], linewidth=LINEWIDTH)
            ax.legend(ncol=3, loc='lower center')

            """
            Differential worth plot
            """
            ax = axs[2]
            eq_fit = np.polyder(eq_fit) # coefs of differential worth curve equation
            y_fit = np.polyval(eq_fit,x_fit)
            
            # The differentiated curve.
            # The errorbar method allows you to add errors to the differential plot too.
            ax.errorbar(x_fit, y_fit,
                        label=f'{self.rcty_label.capitalize()}',
                        color=LINE_COLORS[self.rcty_type], linestyle=LINE_STYLES[self.rcty_type], 
                        linewidth=LINEWIDTH,capsize=3,capthick=2)
            ax.legend(ncol=3, loc='lower center')

            plt.savefig(self.results_folder+f'/{self.base_filename}_{self.rcty_type}_results_{rho_or_dollars}.png', bbox_inches = 'tight', pad_inches = 0.1, dpi=320)












