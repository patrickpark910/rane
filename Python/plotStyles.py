import matplotlib.pyplot as plt
import numpy as np
from Parameters import *



# figure settings
FIGSIZE = (1636/96, 3*673/96)
LINEWIDTH = 2.5
SMALL_SIZE = 10
MEDIUM_SIZE = 16
LARGE_SIZE = 22
HUGE_SIZE = 28
ROD_WORTH_COLORS = {'safe': 'tab:red', 'shim':'tab:green', 'reg':'tab:blue', 'bank':'tab:purple'}
ROD_LINE_STYLES =  {'safe': '-', 'shim':'--', 'reg':':', 'bank':'-'}
# linestyle = ['-': solid, '--': dashed, '-.' dashdot, ':': dot]
ROD_MARKER_STYLES = {'safe': 'o', 'shim':'^', 'reg':'s', 'bank':'o'}
plt.rc('font', size=MEDIUM_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=LARGE_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=MEDIUM_SIZE)    # legend fontsize
plt.rc('figure', titlesize=LARGE_SIZE)  # fontsize of the figure title