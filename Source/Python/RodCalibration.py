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
from matplotlib.ticker import MultipleLocator, FormatStrFormatter

import json


from MCNP_File import *
from Utilities import *
from Parameters import *
from plotStyles import *


class RodCalibration(MCNP_File):

    def process_rod_worth(self):

        self.keff_filename = f'{self.base_filename}_{self.run_type}_keff.csv'
        self.keff_filepath = f"{self.results_folder}/{self.keff_filename}"

        self.rho_filename = f'{self.base_filename}_{self.run_type}_rho.csv'
        self.rho_filepath = f"{self.results_folder}/{self.rho_filename}"

        if self.run_type in ['bank']:
            # self.index_header = header of index column, self.index_data = your domain
            self.index_header, self.index_data = 'height (%)', BANK_HEIGHTS
        elif self.run_type in ['rodcal']:
            self.index_header, self.index_data = 'height (%)', ROD_CAL_HEIGHTS

        print(f'\n processing: {self.output_filename}')
        
        self.extract_keff()

        if self.keff_filename in os.listdir(self.results_folder):
            try:
                df_keff = pd.read_csv(self.keff_filepath, encoding='utf8')
                df_keff.set_index(self.index_header, inplace=True)
            except:
                print(f"\n   fatal. Cannot read {self.keff_filename}")
                print(f"   fatal.   Ensure that:")
                print(f"   fatal.     - the file is a .csv")
                print(f"   fatal.     - the first column header is 'height (%)', followed by rod names 'safe', 'shim', 'reg'")
                sys.exit(2)
        else:
            print(f'\n   comment. creating new results file {self.keff_filepath}')
            df_keff = pd.DataFrame(self.index_data, columns=[self.index_header])
            df_keff.set_index(self.index_header, inplace=True)
             
        df_keff.loc[self.rod_heights_dict[self.rod_config_id], self.rod_config_id] = self.keff
        df_keff.loc[self.rod_heights_dict[self.rod_config_id], self.rod_config_id+" unc"] = self.keff_unc
        
        ''' Drop rows if index is not in self.index_data
        - Necessary if 'fuel_temperatures_C' or 'h2o_tempeartures_C' or 'h2o_void_percents' is redefined in a new run,
        as this code overwrites existing keff csv instead of creating new file, so old list values will otherwise stay on the df
        '''
        for idx in list(df_keff.index.values):
            if idx not in self.index_data:
                df_keff = df_keff.drop([idx])

        # to put df in increasing order based on the index column, USE inplace=False
        df_keff = df_keff.sort_values(by=self.index_header, ascending=True,inplace=False) 
        df_keff.to_csv(self.keff_filepath, encoding='utf8')


       
        df_rho = df_keff.copy()
        heights = list(df_rho.index.values)
        """
        ERROR PROPAGATION FORMULAE
        % Delta rho = 100* frac{k2-k1}{k2*k1}
        numerator = k2-k1
        delta num = sqrt{(delta k2)^2 + (delta k1)^2}
        denominator = k2*k1
        delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
        delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
        """   
        rods = [c for c in df_rho.columns.values.tolist() if "unc" not in c]
        for rod in rods: 
            for height in heights: 
                k1, k2 = df_rho.loc[height,rod], df_rho.loc[heights[-1],rod]
                dk1, dk2 = df_rho.loc[height,f"{rod} unc"], df_rho.loc[heights[-1],f"{rod} unc"] 
                k2_minus_k1, k2_times_k1 = k2-k1, k2*k1
                d_k2_minus_k1 = np.sqrt(dk2**2+dk1**2)
                d_k2_times_k1 = k2*k1*np.sqrt((dk2/k2)**2+(dk1/k1)**2)
                rho = (k2-k1)/(k2*k1)*100

                df_rho.loc[height,rod] = rho
                if k2_minus_k1 != 0: 
                    d_rho = rho*np.sqrt((d_k2_minus_k1/k2_minus_k1)**2+(d_k2_times_k1/k2_times_k1)**2)
                    df_rho.loc[height,f"{rod} unc"] = d_rho
                else: df_rho.loc[height,f"{rod} unc"] = 0

        df_rho.to_csv(self.rho_filepath, encoding='utf8')

    def process_rod_params(self):

        self.params_filename = f'{self.base_filename}_{self.run_type}_params.csv'
        self.params_filepath = f"{self.results_folder}/{self.params_filename}"

        df_keff = pd.read_csv(self.keff_filepath,index_col=0)
        df_rho = pd.read_csv(self.rho_filepath,index_col=0)
        rods = [c for c in df_rho.columns.values.tolist() if "unc" not in c]
        heights = df_rho.index.values.tolist()
                
        parameters = ["worth ($)","max worth added per % height ($/%)", "max worth added per height ($/in)"]
        
        # Setup a dataframe to collect rho values
        df_params = pd.DataFrame(columns=parameters) # use lower cases to match 'rods' def above
        df_params["rod"] = rods
        df_params.set_index("rod",inplace=True)
       
        for rod in rods: # We want to sort our curves by rods
            
            rho = df_rho[f"{rod}"].tolist()
            # worth ($) = rho / BETA_EFF, rho values are in % rho per NIST standard
            worth = 0.01*float(max(rho)) / float(BETA_EFF) 
            df_params.loc[rod,"worth ($)"] = worth
            
            int_eq = np.polyfit(heights,rho,3) # coefs of integral worth curve equation
            dif_eq = -1*np.polyder(int_eq)
            max_worth_rate_percent = 0.01*max(np.polyval(dif_eq,heights)) / float(BETA_EFF) 
            df_params.loc[rod,"max worth added per % height ($/%)"] = max_worth_rate_percent
            
            max_worth_rate_inch = float(max_worth_rate_percent) / float(CM_PER_PERCENT_HEIGHT) * 2.54
            df_params.loc[rod,"max worth added per height ($/in)"] = max_worth_rate_inch
            
            if self.run_type in ['bank']:
                keff = df_keff[f"{rod}"].tolist() 
                keff_unc = df_keff[f"{rod} unc"].tolist() 
                keff_eq = np.polyfit(heights,keff,3)
                unc = max(keff_unc)
                target_keff = 1.0 # + 3 * unc
                p = np.poly1d(keff_eq)
                x = (p - target_keff).roots # type(x) = 'numpy.ndarray'
                ecp = [h for h in x.tolist() if 0<=h<=100]
                if len(ecp) > 1:
                    print("\n   fatal. (RodCalibration.py) More than one estimated critical position (ecp) found, check cubic fit to banked keff eq.")
                    print(f"   fatal. ECPs found: {ecp}")
                    sys.exit()
                else:   
                    ecp = ecp[0]
                    cxs_ecp = 0.01 * np.polyval(int_eq, ecp) / float(BETA_EFF)
                    cxs_5W = 0.01 * np.polyval(int_eq, FIVE_W_BANK_HEIGHT) / float(BETA_EFF)
                    print(f"\n bank estimated critical position: {ecp}")
                    print(f"\n ecp target keff: {target_keff}")
                    print(f"\n ecp excess reactivity ($): {cxs_ecp}")
                    print(f"\n user input 5 W bank height: {FIVE_W_BANK_HEIGHT}")
                    print(f"\n 5 W excess reactivity ($): {cxs_5W}")
                    df_params.loc[rod,"estimated critical position (ecp)"] = ecp
                    df_params.loc[rod,"ecp target keff"] = target_keff
                    df_params.loc[rod,"ecp cxs"] =  cxs_ecp
                    df_params.loc[rod,"input 5W bank height"] = FIVE_W_BANK_HEIGHT # Parameters.py
                    df_params.loc[rod,"5W cxs"] = cxs_5W

            elif self.run_type in ['rodcal']:
                # Normal rod motion speed is about: 
                # 19 inches (48.3 cm) per minute for the Safe rod,
                # 11 inches (27.9 cm) per minute for the Shim rod, 
                # 24 inches (61.0 cm) per minute for the Reg rod.
                react_add_rate = ROD_MOTOR_SPEEDS_INCH_PER_MIN[rod]*max_worth_rate_inch/60
                df_params.loc[rod,"reactivity addition rate ($/sec)"] = react_add_rate
                max_ROD_MOTOR_SPEEDS_INCH_PER_MIN = 1/max_worth_rate_inch*REACT_ADD_RATE_LIMIT_DOLLARS*60
                df_params.loc[rod,"max motor speed (in/min)"] = max_ROD_MOTOR_SPEEDS_INCH_PER_MIN

        print(f"\n Various rod parameters:\n {df_params}")
        df_params.to_csv(self.params_filepath)


    def plot_rod_worth(self):

        df_keff = pd.read_csv(self.keff_filepath)
        df_rho  = pd.read_csv(self.rho_filepath)

        df_keff.set_index('height (%)', inplace=True)
        df_rho.set_index('height (%)', inplace=True)

        rods = [c for c in df_rho.columns.values.tolist() if "unc" not in c]
        heights = list(df_keff.index.values)

        for rho_or_dollars in ['rho', 'dollars']:
            fig, axs = plt.subplots(3,1, figsize=FIGSIZE,facecolor='w',edgecolor='k')
            axs = axs.ravel()

            # linestyle = ['-': solid, '--': dashed, '-.' dashdot, ':': dot]

            for i in [0,1,2]:
                axs[i].set_xlim([0,100])
                axs[i].set_xlabel(r'Height withdrawn [%]')
                axs[i].xaxis.set_major_locator(MultipleLocator(10))
                axs[i].autoscale(axis='y')
                axs[i].tick_params(axis='both', which='major', length=10, direction='in', bottom=True, top=True, left=True, right=True)
                # axs[i].grid(b=True, which='major', color='#999999', linestyle='-', linewidth='1')
            
            axs[0].set_ylabel(r'Eff. multiplication factor [$k_{eff}\pm 3\sigma$]')
            axs[1].set_ylabel(r'Integral worth [$\%\Delta\rho\pm 3\sigma$]')
            axs[2].set_ylabel(r'Differential worth [$\%\Delta\rho$]')
            if rho_or_dollars == 'dollars':
                axs[1].set_ylabel(r'Integral worth [$\$\pm 3\sigma$]')
                axs[1].yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
                axs[2].set_ylabel(r'Differential worth [$\$/\%$]')
                axs[2].yaxis.set_major_formatter(FormatStrFormatter('%.2f'))


            for rod in rods:
                """
                Keff plot
                """
                ax = axs[0]

                y     = df_keff[f"{rod}"].tolist()
                y_unc = df_keff[f"{rod} unc"].tolist()
                
                ax.errorbar(heights, y, yerr=y_unc,
                            marker=MARKER_STYLES[rod], ls="none",
                            color=LINE_COLORS[rod], elinewidth=2, capsize=3, capthick=2)
                
                eq_fit = np.polyfit(heights,y,3) # coefs of integral worth curve equation
                x_fit  = np.linspace(heights[0],heights[-1],heights[-1]-heights[0]+1)
                y_fit  = np.polyval(eq_fit,x_fit)
                
                ax.plot(x_fit, y_fit, label=f'{rod.capitalize()}',
                        color=LINE_COLORS[rod], linestyle=LINE_STYLES[rod], linewidth=LINEWIDTH)
                ax.legend(ncol=3, loc='lower right')

                """
                Integral worth plot
                """
                ax = axs[1]            

                y     = df_rho[f"{rod}"].tolist()
                y_unc = df_rho[f"{rod} unc"].tolist()
                if rho_or_dollars == 'dollars':
                    y     = [i * 0.01 / 0.0075 for i in y] 
                    y_unc = [j * 0.01 / 0.0075 for j in y_unc] 

                eq_fit = np.polyfit(heights,y,3) # coefs of integral worth curve equation
                y_fit  = np.polyval(eq_fit,x_fit)
                
                # Data points with error bars
                heights
                ax.errorbar(heights, y, yerr=y_unc,
                            marker=MARKER_STYLES[rod],ls="none",
                            color=LINE_COLORS[rod], elinewidth=2, capsize=3, capthick=2)
                
                # The standard least squaures fit curve
                ax.plot(x_fit, y_fit, label=f'{rod.capitalize()}',
                        color=LINE_COLORS[rod], linestyle=LINE_STYLES[rod], linewidth=LINEWIDTH)
                ax.legend(ncol=3, loc='upper right')

                """
                Differential worth plot
                """
                ax = axs[2]
                eq_fit = -1*np.polyder(eq_fit) # coefs of differential worth curve equation
                y_fit = np.polyval(eq_fit,x_fit)
                
                # The differentiated curve.
                # The errorbar method allows you to add errors to the differential plot too.
                ax.errorbar(x_fit, y_fit,
                            label=f'{rod.capitalize()}',
                            color=LINE_COLORS[rod], linestyle=LINE_STYLES[rod], 
                            linewidth=LINEWIDTH,capsize=3,capthick=2)
                ax.legend(ncol=3, loc='lower center')

            try:
                plt.savefig(self.results_folder+f'/{self.base_filename}_results_{rho_or_dollars}.png', bbox_inches = 'tight', pad_inches = 0.1, dpi=320)
            except:
                print("\n   fatal. (RodCalibration.py) Cannot save figure, check if you have the file open.")
        