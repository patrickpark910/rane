RANE_INTRO = "\n\n      _/_/_/         _/_/_/       _/      _/     _/_/_/_/_/\n    _/     _/     _/      _/     _/_/    _/     _/\n   _/_/_/_/      _/_/_/_/_/     _/  _/  _/     _/_/_/_/_/\n  _/   _/       _/      _/     _/    _/_/     _/\n _/     _/     _/      _/     _/      _/     _/_/_/_/_/\n\n"
RANE_INSTRUCTIONS_SHORT = "Usage: NeutronicsEngine.py -r <run_type> -t <tasks> -m <run mcnp>"
RANE_INSTRUCTIONS_LONG = "Instructions for Reed Automated Neutronics Engine"
RUN_DESCRIPTIONS_DICT  = {'banked': 'banked rods', 
                          'Coef_Mod': 'moderator temperature coefficient',
                          'Coef_PNTC': 'fuel temperature coefficient (pntc)',
                          'Coef_Void': 'void coefficient',
                          'CriticalLoading': 'critical loading experiment',
                          'FuelMaterials': 'fuel material cards',
                          'kntc': 'kinetics parameters',
                          'plot': 'plot geometry and take images',
                          'PowerDistribution': 'power distribution (power peaking factors)',
                          'rodcal': 'rod calibration',
                          'rcty': 'reactivity coefficients'}

""" Constants """
AMU_U235 = 235.0439299
AMU_U238 = 238.05078826
AMU_PU239 = 239.0521634
AMU_ZR = 91.224
AMU_H = 1.00794
AVO = 6.022e23
RATIO_HZR = 1.575 # TS allows 1.55 to 1.60. This is an ATOM ratio
BETA_EFF = 0.0075
CM_PER_INCH = 2.54
CM_PER_PERCENT_HEIGHT = 0.38
MEV_PER_KELVIN = 8.617328149741e-11
REACT_ADD_RATE_LIMIT_DOLLARS = 0.16

""" SETUP """
PYTHON_FOLDER_NAME = "Python"
MCNP_FOLDER_NAME = "MCNP"
RESULTS_FOLDER_NAME = "Results"
INPUTS_FOLDER_NAME = "inputs"
OUTPUTS_FOLDER_NAME = "outputs"

F4_TALLY_ID_POWER_DENSITY = "684"
W_PER_CM3_TO_KW_PER_FUEL_ELEMENT = (3.14*381*(18.2245**2)/(1000**2)) # -2.8575**2

INV_M_CSV_NAME = "inv_M.csv"
KEFF_CSV_NAME = "keff.csv"
RHO_CSV_NAME = "rho.csv"
PARAMS_XLSX_NAME = "params.xlsx"

""" Fuel & Core """

FUEL_REMOVED_SOP = "C10,D15,D14,F20,D16,E19,C11,F21"
ROD_MOTOR_SPEEDS_INCH_PER_MIN = {"safe":19,"shim":11,"reg":24,"bank":0}
ROD_CAL_HEIGHTS = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
ROD_CAL_BANK_HEIGHT = 100


CORE_POS = ['A1', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6',
            'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12',
            'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12',
            'D13', 'D14', 'D15', 'D16', 'D17', 'D18',
            'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12',
            'E13', 'E14', 'E15', 'E16', 'E17', 'E18', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24',
            'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 
            'F13', 'F14', 'F15', 'F16', 'F17', 'F18', 'F19', 'F20', 'F21', 'F22', 'F23', 'F24', 
            'F25', 'F26', 'F27', 'F28', 'F29', 'F30']

CONTROL_ROD_POS = ['E1','C5','C9']

""" not used in v2 of RANE -- core configs moved to {core_number}.core files in ./Source/Core/

CELL_NUM_TO_CORE_RING_DICT = {2:"B",3:"C",4:"D",5:"E",6:"F"}

FE_ID = {'B1': '7202', 'B2': '9678', 'B3': '9679', 'B4': '7946', 'B5': '7945', 'B6': '8104',
         'C1': '4086', 'C2': '4070', 'C3': '8102', 'C4': '3856', 'C6': '8103',
         'C7': '4117', 'C8': '8105', 'C10': '8736', 'C11': '8735', 'C12': '1070',
         # C12 is 10705 but only 4 digit IDs are supported here
         'D1': '3679', 'D2': '8732', 'D3': '4103', 'D4': '8734', 'D5': '3685', 'D6': '4095',
         'D7': '4104', 'D8': '4054', 'D9': '4118', 'D10': '3677', 'D11': '4131', 'D12': '4065',
         'D13': '3851', 'D14': '3866', 'D15': '8733', 'D16': '4094', 'D17': '4129', 'D18': '3874',
         'E2': '3872', 'E3': '4106', 'E4': '3671', 'E5': '4062', 'E6': '4121', 'E7': '4114',
         'E8': '4077', 'E9': '3674', 'E10': '4071', 'E11': '4122', 'E12': '4083', 'E13': '3853',
         'E14': '4134', 'E15': '4133', 'E16': '4085', 'E17': '4110', 'E18': '4055', 'E19': '3862',
         'E20': '4064', 'E21': '3858', 'E22': '4053', 'E23': '3748', 'E24': '3852',
         'F1': '4057', 'F2': '4125', 'F3': '4074', 'F4': '4069', 'F5': '4088', 'F7': '3868',
         'F8': '4120', 'F14': '3810', 'F15': '4130', 'F16': '4091', 'F17': '3673', 'F18': '3682',
         'F19': '4132', 'F20': '4046', 'F21': '3865', 'F22': '3743', 'F24': '3835', 'F26': '3676',
         'F27': '3840', 'F28': '3854', 'F29': '4049', 'F30': '4127'}
"""

RODS = ["safe", "shim", "reg"]  # must be in lower case
MOTOR_SPEEDS_DICT = {"safe": 19, "shim": 11, "reg": 24}  # inches/min

H2O_VOID_DENSITIES = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
H2O_MOD_TEMPS_C = [1, 10, 20, 25, 35, 45, 50, 55, 65, 75, 80, 85, 90, 95, 99]











