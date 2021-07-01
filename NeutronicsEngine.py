import os
import sys
import shutil
import argparse

sys.path.insert(0, "./Python")
from Parameters import *
from MCNP_InputFile import *
# from Coef_Mod import *
# from Coef_PNTC import *
# from Coef_Void import *
from Kinetics import *
# from FuelMaterials import *
from RodCalibration import *

from plotStyles import *

"""
This file uses PEP8 Python Style Guidelines.

Constants are in CAPS and are most likely defined in ./Python/Parameters.py

The structure of this Python file is based on a similar engine for the
National Institute of Standards and Technology, written by Dr. Danyal Turkoglu,
with whom I worked with in May-November 2020.

"""
def ReedAutomatedNeutronicsEngine(argv):
    print(RANE_INTRO)
    print(" Type 'python3 NeutronicsEngine.py -h' for help.")
    run_types = None
    tasks = None 
    cores = os.cpu_count() # number of cores available
    check_mcnp = True
    if shutil.which('mcnp6') is None: 
        print(" MCNP6 is not available on this device.")
        check_mcnp = False

    """
    Argument parsing setup

    Returns args_dict, a dictionary of arguments and their options,
    ex: args_dict = {'r': 1, 't': 12, 'm': 1}
    ex: args_dict = {'r': 1, 't': None, 'm': 1}
    with 'None' if no option is selected for that argument and a default is 
    not specified in the add_argument.
    """
    parser = argparse.ArgumentParser(description=' Description of your program')
    parser.add_argument('-r', 
                        help=" R = g \n h \n c")
    parser.add_argument('-t',
                        help=f" T = integer from 1 to {cores}. Number of CPU cores to be used for MCNP.")
    parser.add_argument('-m',
                        help=' M = 1: run mcnp, 0: do not run mcnp (default: 1)',
                        default = check_mcnp)
    args_dict = vars(parser.parse_args())
    print(os.getcwd())

    """
    Argument parsing
    """
    # -r
    if args_dict['r'] is None:
        print("   Fatal. No run types selected.")
        sys.exit()



    run_types = list(args_dict['r'].split(','))
    for run_type in run_types:
        if run_type.lower() in ['b','br','bank','banked','bankedrods']: 
            run_types = ['banked' if x==run_type else x for x in run_types]
        
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

        elif run_type.lower() in ['k', 'kntc', 'kin', 'kine', 'kinetic', 'kinetics']: 
            run_types = ['kntc' if x==run_type else x for x in run_types]
        
        elif run_type.lower() in ['pl', 'plo', 'plot']: 
            run_types = ['plot' if x==run_type else x for x in run_types]

        elif run_type.lower() in ['pd','ppf','powerpeaking','powerpeakingfactor','powerdistribution']: 
            run_types = ['power' if x==run_type else x for x in run_types]

        elif run_type.lower() in ['rod','rodcal','rodcalibration']: 
            run_types = ['rodcal' if x==run_type else x for x in run_types]

        elif run_type.lower() in ['rcty', 'rctvty', 'reactivity', 'ReactivityCoefficients']
            run_types = ['rcty' if x==run_type else x for x in run_types]
        
        else: 
            print(f"\n  Warning. Run type '{run_type}' not recognized.")
            run_types = [x for x in run_types if x != run_type]
    
    print("\n RANE will calculate the following:")
    for run_type in run_types:
        print(f"    {RUN_DESCRIPTIONS_DICT[run_type]}")
    proceed = None
    while proceed is None:
        proceed = input(f"\n Proceed (Y/N)? ")
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
        print("\n No <tasks> specified, or invalid <tasks> in '-t <tasks>'.")
        tasks = get_tasks() # Utilities.py

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
        print(f"\n Currently calculating: {RUN_DESCRIPTIONS_DICT[run_type]}.")
        if run_type == 'banked':
            # calibrate all rods as single bank
            for rod_height in ROD_CAL_HEIGHTS:
                rod_heights_dict = {'safe': rod_height, 'shim': rod_height, 'reg': rod_height, 'bank': rod_height}
                if check_mcnp:
                    current_run = MCNP_InputFile(run_type,
                                                 tasks,
                                                 template_filepath=None,
                                                 core_number=49,
                                                 delete_extensions=['.r','.s'],
                                                 rod_heights=rod_heights_dict,
                                                 fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                                 )
                    current_run.run_mcnp() 
                output_file = RodCalibration(run_type, rod_heights=rod_heights_dict, rod_being_calibrated='bank')
                output_file.process_rod_worth()
            output_file.process_rod_params()
            output_file.plot_rod_worth()

        elif run_type == 'rcty':
            # moderator (h2o) temperature coefficient
            rcty_type = 'mod'
            for h2o_temp_K in list(H2O_TEMPS_K_DICT.values()):
                if check_mcnp:
                    current_run = MCNP_InputFile(run_type,
                                                 tasks,
                                                 template_filepath=None,
                                                 core_number=49,
                                                 rod_heights=rod_heights_dict,
                                                 fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                                 h2o_temp_K=h2o_temp_K,
                                                 rcty_type=rcty_type,
                                                 )
                    current_run.run_mcnp() 
            # fuel temperature coefficient
            rcty_type = 'fuel'
            for h2o_temp_K in list(H2O_TEMPS_K_DICT.values()):
                for fuel_temp_K in list():
                    if check_mcnp:
                        current_run = MCNP_InputFile(run_type,
                                                     tasks,
                                                     template_filepath=None,
                                                     core_number=49,
                                                     rod_heights=rod_heights_dict,
                                                     fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                                     h2o_temp_K=h2o_temp_K,
                                                     rcty_type=rcty_type,
                                                     )
                        current_run.run_mcnp() 
            # void coefficient
            rcty_type = 'void'
            for h2o_density in H2O_VOID_DENSITIES:
                if check_mcnp:
                    current_run = MCNP_InputFile(run_type,
                                                 tasks,
                                                 template_filepath=None,
                                                 core_number=49,
                                                 rod_heights=rod_heights_dict,
                                                 fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                                 h2o_temp_K=h2o_temp_K,
                                                 h2o_density=h2o_density,
                                                 rcty_type=rcty_type,
                                                 )
                    current_run.run_mcnp() 
            rcty_type = 'void_ct'
            if check_mcnp:
                current_run = MCNP_InputFile(run_type,
                                             tasks,
                                             template_filepath=None,
                                             core_number=49,
                                             rod_heights=rod_heights_dict,
                                             fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                             h2o_temp_K=h2o_temp_K,
                                             h2o_density=h2o_density,
                                             rcty_type=rcty_type,
                                             ct_cell_mat=102,
                                             )
                current_run.run_mcnp() 

        elif run_type == 'CriticalLoading':
            pass
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

        elif run_type == 'kntc':
            rod_heights_dict = {'safe': 100, 'shim': 100, 'reg': 100}
            if check_mcnp:
                current_run = MCNP_InputFile(run_type,
                                             tasks,
                                             template_filepath=None,
                                             core_number=49,
                                             rod_heights=rod_heights_dict,
                                             fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                             )
                current_run.run_mcnp() 
            output_file = Kinetics(run_type, rod_heights=rod_heights_dict)
            output_file.find_kinetic_parameters()

        elif run_type == 'plot':
            # plot the geometry and save plot figures
            if check_mcnp:
                print(f' Running geometry plotter.')
                current_run = MCNP_InputFile(run_type,
                                             tasks,
                                             template_filepath=None,
                                             core_number=49,
                                             rod_heights={'safe': 0, 'shim': 0, 'reg':0}, # defaults to all rods down
                                             fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx"
                                             )
                current_run.run_geometry_plotter()
            else:
                print('\n   fatal. no plotting is available without mcnp6\n')
                sys.exit(2)


        elif run_type == 'power':
            pass

        elif run_type == 'rodcal':
            # calibrate individual rods
            for rod in RODS:   
                for rod_height in ROD_CAL_HEIGHTS:
                    rod_heights_dict = {'safe': ROD_CAL_BANK_HEIGHT, 'shim': ROD_CAL_BANK_HEIGHT, 'reg': ROD_CAL_BANK_HEIGHT}
                    rod_heights_dict[rod] = rod_height
                    if check_mcnp:
                        current_run = MCNP_InputFile(run_type,
                                                     tasks,
                                                     template_filepath=None,
                                                     core_number=49,
                                                     rod_heights=rod_heights_dict,
                                                     fuel_filepath=f"./Source/Fuel/Core Burnup History 20201117.xlsx",
                                                     )
                        current_run.run_mcnp() 
                        if not current_run.mcnp_skipped: 
                            current_run.move_mcnp_files()
                    output_file = RodCalibration(run_type, 
                                                 rod_heights=rod_heights_dict,
                                                 rod_being_calibrated=rod
                                                 )
                    output_file.process_rod_worth()
            output_file.process_rod_params()
            output_file.plot_rod_worth()




if __name__ == "__main__":
    ReedAutomatedNeutronicsEngine(sys.argv[1:])