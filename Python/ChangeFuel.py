import os
import sys
import getpass
import multiprocessing

sys.path.insert(0, "./src/python/")
from Parameters import *
from MCNP_InputFunctions import *
from MCNP_OutputFunctions import *

"""
Change Fuel

Assumptions:
- cell cards for core positions are denoted by 3-digits
- Ambe and Ir-192 sources are "623##" and "6235##"

"""

def ChangeFuel(filepath, base_file_path=None):
    
    initialize_rane()

    """
    Ask user for base file and whether to run MCNP, if not already provided.
    """
    if base_file_path is None:
        base_file_path = find_base_file(f"{filepath}/.")  # filepath/. goes up one dir level

    base_file_name = base_file_path.split('/')[-1]
    module_name = "ChangeFuel"


    # ./Results
    results_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}"
    # ./Results/ModuleName
    results_module_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}/{module_name}"
    
    keff_csv_name = f"{module_name}_{KEFF_CSV_NAME}"
    rho_csv_name = f"{module_name}_{RHO_CSV_NAME}"
    params_csv_name = f"{module_name}_{PARAMS_CSV_NAME}"
    figure_name = f"{module_name}_results.png"

    """
    Create the /Module/inputs folders if they do not already exist.
    """
    paths_to_create = [results_folder_path, results_module_folder_path]

    create_paths(paths_to_create)



    core_positions_dict = read_core_loading(base_file_path)

    print(f"\nThe core loading in {base_file_name} is:\n")
    print(core_positions_dict)

    """
    Guidance
    """
    print("\nNow I will guide you ")


    

if __name__ == '__main__':
    ChangeFuel(os.getcwd(), base_file_path="ReedCore49_test.i")