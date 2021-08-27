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
import json


from MCNP_File import *
from Utilities import *
from Parameters import *
from plotStyles import *


class Kinetics(MCNP_File):


    def find_kinetic_parameters(self):

        print(f'\n extracting data from: {self.output_filename}')

        self.kntc_filepath = f"{self.results_folder}/{self.base_filename}_kntc_results.csv"
        self.index_header = 'Bank Height (%)'

        print(f'  Processing: {self.output_filepath}')
        if os.path.exists(self.kntc_filepath):
            print(' * loading existing results file')
            df_kntc = pd.read_csv(self.kntc_filepath, encoding='utf8')
            df_kntc.set_index(self.index_header, inplace=True)
        else:
            print(' * creating new results file')
            df_kntc = pd.DataFrame(self.index_data, columns=[self.index_header]) # first arg must be list
            df_kntc.set_index(self.index_header, inplace=True)
            cols = ['keff','keff unc']+\
                   ['Lifetime (us)','Lifetime unc (us)']+\
                   ['Beff','Beff unc']+\
                   [f'B_{i}' for i in range(1,7)]+\
                   [f'L_{i}' for i in range(1,7)]+\
                   ['half life (s)'] +\
                   [f'E_{i}' for i in range(1,7)]+\
                   [f'E_{i} unc' for i in range(1,7)]
            for col in cols:
                df_kntc[col] = 0.0 
        
        """ Example section of the MCNP output to extract data from:

                            estimate      std. dev.
 
           gen. time        53.11160        0.93066    (usec)
         rossi-alpha    -1.22730E-04    1.15456E-05    (/usec)
            beta-eff         0.00652        0.00060
 
 effective delayed neutron fraction, average emission energy, and decay constants by precursor group:
 
         precursor    beta-eff   std. dev.      energy   std. dev.    lambda-i   std. dev.    half-life
                                                 (MeV)                  (/sec)                    (sec)
 
             1         0.00041     0.00014     0.39992     0.01034     0.01334     0.00000     51.97561
             2         0.00105     0.00022     0.47347     0.00487     0.03271     0.00000     21.18895
             3         0.00116     0.00025     0.43722     0.00467     0.12075     0.00001      5.74031
             4         0.00232     0.00038     0.55492     0.00430     0.30289     0.00002      2.28847
             5         0.00113     0.00025     0.50433     0.00672     0.85057     0.00012      0.81492
             6         0.00045     0.00016     0.54803     0.01194     2.85505     0.00053      0.24278
        """
        with open(self.output_filepath) as f:
            print(f' * seaching {self.output_filepath} for kinetics parameters')
            get_precursors = False

            self.extract_keff() # gets self.keff, self.keff_unc or raises warnings if not found
            df_kntc.loc[self.rod_heights_dict['bank'],'keff'] = self.keff
            df_kntc.loc[self.rod_heights_dict['bank'],'keff unc'] = self.keff_unc

            for line in f:
                if len(line.split()) >= 1:
                    if line.split()[0] == 'gen.':
                        df_kntc.loc[self.rod_heights_dict['bank'],'Lifetime (us)'] = float(line.split()[2])
                        df_kntc.loc[self.rod_heights_dict['bank'],'Lifetime unc (us)'] = float(line.split()[3])
                    elif line.split()[0] == 'beta-eff':
                        df_kntc.loc[self.rod_heights_dict['bank'],'Beff'] = float(line.split()[1])
                        df_kntc.loc[self.rod_heights_dict['bank'],'Beff unc'] = float(line.split()[2])
                        get_precursors, lines_skipped = True, 0
                    elif get_precursors:
                        lines_skipped += 1 
                        if lines_skipped >= 1 and line.split()[0].isdigit():
                            # print(line)
                            group = line.split()[0]
                            beta, beta_unc, E, E_unc, Lambda, Lambda_unc, HL = [float(value) for value in line.split()[1:]]
                            # print(group, beta, beta_unc, E, E_unc, Lambda, Lambda_unc, HL)
                            df_kntc.loc[self.rod_heights_dict['bank'],f'B_{group}'] = beta
                            df_kntc.loc[self.rod_heights_dict['bank'],f'B_{group} unc'] = beta_unc
                            df_kntc.loc[self.rod_heights_dict['bank'],f'L_{group}'] = Lambda
                            df_kntc.loc[self.rod_heights_dict['bank'],f'L_{group} unc'] = Lambda_unc
                            df_kntc.loc[self.rod_heights_dict['bank'],f'E_{group}'] = E
                            df_kntc.loc[self.rod_heights_dict['bank'],f'E_{group} unc'] = E_unc
                            df_kntc.loc[self.rod_heights_dict['bank'],'half life (s)'] = HL
                            if group == '6':
                                df_kntc.to_csv(self.kntc_filepath, encoding='ascii')
                                print(f'   Updated: {self.kntc_filepath}')
                                return True


    def plot_kinetic_parameters(self):
        pass
'''
        df_kntc = pd.read_csv(self.kntc_filepath)
        df_kntc.set_index(self.index_header, inplace=True)



        df_keff = pd.read_csv(self.keff_filepath)
        df_rho  = pd.read_csv(self.rho_filepath)

        df_keff.set_index('height (%)', inplace=True)
        df_rho.set_index('height (%)', inplace=True)

        rods = [c for c in df_rho.columns.values.tolist() if "unc" not in c]
        heights = list(df_keff.index.values)

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
            
            axs[0].set_ylabel(r'Effective multiplication factor [$k_{eff}\pm 3\sigma$]')
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
'''