import os
import sys
import shutil
import argparse

sys.path.insert(0, "./Python")
from Parameters import *
from MCNP_InputFunctions import *
from MCNP_OutputFunctions import *
from BankedRods import *
# from Coef_Mod import *
# from Coef_PNTC import *
# from Coef_Void import *
from CriticalLoading import *
# from FuelMaterials import *
# from RodCalibration import *

"""
This file uses PEP8 Python Style Guidelines.

Constants are in CAPS and are most likely defined in ./Python/Parameters.py

The structure of this Python file is based on a similar engine for the
National Institute of Standards and Technology, written by Dr. Danyal Turkoglu,
with whom I worked with in May-November 2020.

"""
def ReedAutomatedNeutronicsEngine(argv):
    print(RANE_INTRO)
    print("Type 'python NeutronicsEngine.py -h' for help.")
    run_types = None
    tasks = None 
    cores = os.cpu_count() # number of cores available
    check_mcnp = True
    if shutil.which('mcnp6') is None: 
        print("MCNP6 is not available on this device.")
        check_mcnp = False

    """
    Argument parsing setup

    Returns args_dict, a dictionary of arguments and their options,
    ex: args_dict = {'r': 1, 't': 12, 'm': 1}
    ex: args_dict = {'r': 1, 't': None, 'm': 1}
    with 'None' if no option is selected for that argument and a default is 
    not specified in the add_argument.
    """
    parser = argparse.ArgumentParser(description='Description of your program')
    parser.add_argument('-r', 
                        help="R = g \n h \n c")
    parser.add_argument('-t',
                        help=f"T = integer from 1 to {cores}. Number of CPU cores to be used for MCNP.")
    parser.add_argument('-m',
                        help='M = 1: run mcnp, 0: do not run mcnp (default: 1)',
                        default = check_mcnp)
    args_dict = vars(parser.parse_args())
    print(os.getcwd())

    """
    Argument parsing
    """
    # -r
    if args_dict['r'] is None:
        print("No run types selected.")
        sys.exit()

    run_types_dict = {'BankedRods': 'banked rods', 
                      'Coef_Mod': 'moderator temperature coefficient',
                      'Coef_PNTC': 'fuel temperature coefficient (pntc)',
                      'Coef_Void': 'void coefficient',
                      'CriticalLoading': 'critical loading experiment',
                      'FuelMaterials': 'fuel material cards',
                      'PowerDistribution': 'power distribution (power peaking factors)',
                      'RodCalibration': 'rod calibration'}

    run_types = list(args_dict['r'].split(','))
    for run_type in run_types:
        if run_type.lower() in ['b','br','banked','bankedrods']: 
            run_types = ['BankedRods' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['cm','mod','coef_mod']: 
            run_types = ['Coef_Mod' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['cp','pntc','coef_pntc']: 
            run_types = ['Coef_PNTC' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['cv','void','coef_void']: 
            run_types = ['Coef_Void' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['cl','cle','critical','criticalload']: 
            run_types = ['CriticalLoading' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['f','fm','fuel','fuelmats','fuelmaterials']: 
            run_types = ['FuelMaterials' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['p','pd','ppf','powerpeaking','powerpeakingfactor','powerdistribution']: 
            run_types = ['PowerDistribution' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['r','rc','rodcal','rodcalibration']: 
            run_types = ['RodCalibration' if x==run_type else x for x in run_types]
        
        else: 
            print(f"\n  Warning. Run type '{run_type}' not recognized.")
            run_types = [x for x in run_types if x != run_type]
    
    print("\nRANE will calculate the following:")
    for run_type in run_types:
        print(f"    {run_types_dict[run_type]}")
    proceed = None
    while proceed is None:
        proceed = input(f"\nProceed (Y/N)? ")
        if proceed.lower() == "y":
            pass
        elif proceed.lower() == "n":
            sys.exit()
        else:
            proceed = None


    # -t
    if isinstance(args_dict['t'], int) and int(args_dict['t']) <= cores:
        pass
    else:
        print("\nNo <tasks> specified, or invalid <tasks> in '-t <tasks>'.")
        tasks = get_tasks() # MCNP_Functions.py

    # -m
    if args_dict['m'] in [1, '1', 't', 'T', "true", "True"] and shutil.which('mcnp6') is None:
        print("\n  Warning. You have specified to run MCNP6, but MCNP6 is not available on this device.")
        check_mcnp = False
    elif args_dict['m'] in [0, '0', 'f', 'F', "false", "False"]:
        print("\n  Warning. You have specified to not run MCNP6. Data will be processed from existing output files.")
        check_mcnp = False
    else:
        check_mcnp = True

    """
    Make sure the right directories exist
    """
    for folder in ["MCNP", "Results"]:
        if not os.path.exists('./'+folder): os.mkdir(folder)

    """
    Execute run types
    """
    rane_cwd = os.getcwd()
    base_file_name = "ReedCore49.i" #find_base_file(rane_cwd)
    for run_type in run_types:
        print(f"\nCurrently calculating: {run_types_dict[run_type]}.")
        if run_type == 'BankedRods':
            BankedRods(rane_cwd, base_file_path=base_file_name, check_mcnp=check_mcnp, tasks=tasks, heights=[0,33,66,100])

        elif run_type == 'Coef_Mod':
            pass

        elif run_type == 'Coef_PNTC':
            pass

        elif run_type == 'Coef_Void':
            pass

        elif run_type == 'CriticalLoading':
            fuel_to_remove = [] 
            while len(fuel_to_remove)==0:
                user_input = input(f"Input core positions separated by a comma (ex: C1,C2,E4,F1), 'sop' to input the standard procedure for the 1/M experiment ({FUEL_REMOVED_SOP}), or 'quit' to quit: ")
                if user_input.lower() in ['s','sop']:
                    user_input = FUEL_REMOVED_SOP 
                elif user_input.lower() in ['q','quit','kill']: 
                    sys.exit()
                
                user_input = user_input.split(',')
                for c in user_input: 
                    if c.upper() in CORE_POS: 
                        fuel_to_remove.append(c) # user_input is matched with a FE
                    else: 
                        print(f"\n  Warning. There is no fuel element in core position {c}.")

            CriticalLoading(rane_cwd, base_file_path=base_file_name, check_mcnp=check_mcnp, tasks=tasks, fuel_to_remove=fuel_to_remove)

        elif run_type == 'FuelMaterials':
            pass

        elif run_type == 'PowerDistribution':
            pass

        elif run_type == 'RodCalibration':
            pass




if __name__ == "__main__":
    ReedAutomatedNeutronicsEngine(sys.argv[1:])