

""" SETUP """
PYTHON_FOLDER_NAME = "Python"
MCNP_FOLDER_NAME = "MCNP"
RESULTS_FOLDER_NAME = "Results"
INPUTS_FOLDER_NAME = "inputs"
OUTPUTS_FOLDER_NAME = "outputs"

F4_TALLY_ID_POWER_DENSITY = "684"
W_PER_CM3_TO_KW_PER_FUEL_ELEMENT = (3.14*381*(18.2245**2)/(1000**2)) # -2.8575**2


""" Fuel & Core """

FUEL_REMOVED_SOP = ['C10','D15','D14','F20','D16','E19','C11','F21']
ROD_MOTOR_SPEEDS_INCH_PER_MIN = {"safe":19,"shim":11,"reg":24}
BANK_HEIGHTS = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100] # should be >= granular than ROD_CAL_HEIGHTS
ROD_CAL_HEIGHTS = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
ROD_CAL_BANK_HEIGHT = 100
FIVE_W_BANK_HEIGHT = 73

BANK_HEIGHTS_FLUX = [0,73,100]

HEAT_TALLIES_DICT = {}

FLUX_TALLIES_DICT = {'114':'safe rod poison (5 W)',
                     '124':'shim rod poison (5 W)',
                     '134':'reg rod poison (5 W)',
                     '204':'rabbit inner vial (5 W)',
                     '214':'ls 1 triga tube (5 W)',
                     '224':'ls 11 triga tube (5 W)',
                     '234':'ls 21 triga tube (5 W)',
                     '244':'ls 31 triga tube (5 W)',
                     '1114':'safe rod poison (250 kW)',
                     '1124':'shim rod poison (250 kW)',
                     '1134':'reg rod poison (250 kW)',
                     '1204':'rabbit inner vial (250 kW)',
                     '1214':'ls 1 triga tube (250 kW)',
                     '1224':'ls 11 triga tube (250 kW)',
                     '1234':'ls 21 triga tube (250 kW)',
                     '1244':'ls 31 triga tube (250 kW)',
                     '2114':'safe rod poison (5 W spectrum)',
                     '2124':'shim rod poison (5 W spectrum)',
                     '2134':'reg rod poison (5 W spectrum)',
                     '2204':'rabbit inner vial (5 W spectrum)',
                     '2214':'ls 1 triga tube (5 W spectrum)',
                     '2224':'ls 11 triga tube (5 W spectrum)',
                     '2234':'ls 21 triga tube (5 W spectrum)',
                     '2244':'ls 31 triga tube (5 W spectrum)',
                     '3114':'safe rod poison (250 kW spectrum)',
                     '3124':'shim rod poison (250 kW spectrum)',
                     '3134':'reg rod poison (250 kW spectrum)',
                     '3204':'rabbit inner vial (250 kW spectrum)',
                     '3214':'ls 1 triga tube (250 kW spectrum)',
                     '3224':'ls 11 triga tube (250 kW spectrum)',
                     '3234':'ls 21 triga tube (250 kW spectrum)',
                     '3244':'ls 31 triga tube (250 kW spectrum)',
                     }


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

RODS = ["safe", "shim", "reg"]  # must be in lower case
MOTOR_SPEEDS_DICT = {"safe": 19, "shim": 11, "reg": 24}  # inches/min

H2O_VOID_PERCENTS = [0,2,4,6,8,10,12,14,16,18,20] # use <=2 digits only - else, change input naming scheme
H2O_MOD_TEMPS_C = [20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 99] # MUST HAVE differences of >=1 or else input file naming will fail
UZRH_FUEL_TEMPS_K = [294, 600, 900, 1200] # [250, 294, 400, 500, 600, 700, 800, 900, 1200]
UZRH_FUEL_TEMPS_C = [x-273 for x in UZRH_FUEL_TEMPS_K]

"""
- if you add/change config key (ex:'allrodsin') then also change in ShutdownMargin.py 
- NO SPACES IN KEYS, ex: 'allrodsin', else, input file naming will fail
"""
SDM_CONFIGS_DICT = {'allrodsin':{"safe": 0, "shim": 0, "reg": 0},
                    'safeout':{"safe": 100, "shim": 0, "reg": 0},
                    'shimout':{"safe": 0, "shim": 100, "reg": 0}, 
                    'regout':{"safe": 0, "shim": 0, "reg": 100},
                    'allrodsout':{"safe": 100, "shim": 100, "reg": 100}} 










