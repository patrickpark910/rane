import os
import sys
import getpass
import multiprocessing

sys.path.insert(0, "./src/python/")
from Parameters import *
from MCNP_InputFunctions import *
from MCNP_OutputFunctions import *


def CalcPower(filepath, base_file_path=None):

	initialize_rane()

    """
    Ask user for base file and whether to run MCNP, if not already provided.
    """
    if base_file_path is None:
        base_file_path = find_base_file(f"{filepath}/.")  # filepath/. goes up one dir level

    base_file_name = base_file_path.split('/')[-1]
    module_name = "CalcPower"

    """
    Create the /Module/inputs folders if they do not already exist.
    """
    mcnp_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}"
    mcnp_module_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}"
    inputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{INPUTS_FOLDER_NAME}"
    outputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{OUTPUTS_FOLDER_NAME}"
    
    results_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}"
    results_module_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}/{module_name}"
    
    params_csv_name = f"{module_name}_{PARAMS_CSV_NAME}"

    paths_to_create = [mcnp_folder_path, mcnp_module_folder_path, 
    				   inputs_folder_path, outputs_folder_path, 
    				   results_folder_path, results_module_folder_path]
    
    create_paths(paths_to_create)

    core_positions_dict = read_core_loading(base_file_path)

    
