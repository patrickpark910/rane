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
from scipy.interpolate import UnivariateSpline

from MCNP_File import *
from Utilities import *
from Parameters import *
from plotStyles import *


class ShutdownMargin(MCNP_File):

    def process_sdm(self):

        self.sdm_filename = f'{self.base_filename}_{self.run_type}.csv'
        self.sdm_filepath = f"{self.results_folder}/{self.sdm_filename}"

        if os.path.isfile(self.sdm_filepath):
            df_sdm = pd.read_csv(self.sdm_filepath) #, encoding='utf8')
            df_sdm.set_index('Config', inplace=True)
        else:
            try:
                df_sdm = pd.DataFrame(list(SDM_CONFIGS_DICT.keys()), columns=['Config'])
                df_sdm.set_index('Config', inplace=True)
            except:
                print("\n   fatal. sdm csv found but cannot be read \n")

        self.rho = (self.keff - 1) / self.keff * 100
        self.dollars = self.rho / BETA_EFF / 100

        # https://www.statisticshowto.com/error-propagation/
        self.rho_unc = self.rho * np.sqrt(2*(self.keff_unc/self.keff)**2)
        self.dollars_unc = self.rho_unc / BETA_EFF / 100
 
        df_sdm.loc[self.rod_config_id, 'keff']        = self.keff
        df_sdm.loc[self.rod_config_id, 'keff unc']    = self.keff_unc
        df_sdm.loc[self.rod_config_id, 'rho']         = self.rho
        df_sdm.loc[self.rod_config_id, 'rho unc']     = self.rho_unc
        df_sdm.loc[self.rod_config_id, 'dollars']     = self.dollars
        df_sdm.loc[self.rod_config_id, 'dollars unc'] = self.dollars_unc

        df_sdm.to_csv(self.sdm_filepath) #, encoding='utf8')