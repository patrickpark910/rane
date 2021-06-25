def extract_keff(target_filepath):
    # target_outputs: list of output file names from which to read keff values
    # keff_file_name: string with desired file name of collected keffs + .csv
    get_keff, found_keff = False, False
    keff, keff_unc = None, None

    for line in open(target_filepath):
        if not found_keff:
            if line.startswith(" the estimated average keffs"):
                get_keff = True
            elif get_keff and line.startswith("       col/abs/trk len"):
                keff, keff_unc = float(line.split()[2]), float(line.split()[3])
                # print(f"{target_filepath.split('/')[-1]}: keff = {keff} +/- {keff_unc}")
                found_keff = True
    if not found_keff: print("--Error: keff cannot be found")
    return keff, keff_unc


def extract_power_density(target_filepath, tally_id=None):
    found_tally = False
    pd, pd_unc = None, None
    pd_list = []

    if tally_id is None:
        tally_id = F4_TALLY_ID_POWER_DENSITY

    for line in open(target_filepath):
        if "multiplier bin" in line and "-6" in line and "-8" in line: # all([x in line for x in ["multiplier", "-6", "-8"]]):
            found_tally = True
        
        elif len(line.split()) >= 2 and not found_tally:
            fe_id = ''.join(f for f in line.split()[1] if f.isdigit())[:-2]

        elif found_tally:
            pd, pd_unc = float(line.split()[0]), float(line.split()[1])
            pd_list.append([fe_id, pd, pd_unc])
            found_tally = False

    return pd_list

'''
Calculates a few other rod parameters.

rho_csv_name: str, name of CSV of rho values to read from, e.g. "rho.csv"
params_csv_name: str, desired name of CSV of rod parameters, e.g. "rod_parameters.csv"

Does not return anything. Only performs file creation.
'''


def calc_params_coef(rho_csv_name, params_csv_name, module_name):
    rho_df = pd.read_csv(rho_csv_name, index_col=0)
    original_x_value = rho_df.index[abs(rho_df['rho']) == 0].tolist()[0]
    parameters = ['x', 'D x', 'D rho', 'rho unc', 'D dollars', 'dollars unc',
                  'coef rho', 'coef rho avg', 'coef rho unc', 'coef dollars', 'coef dollars avg', 'coef dollars unc']

    # Setup a dataframe to collect rho values
    # Here, 'D' stands for $\Delta$, i.e., macroscopic change
    params_df = pd.DataFrame(columns=parameters)  # use lower cases to match 'rods' def above
    params_df['x'] = rho_df.index.values.tolist()
    params_df.set_index('x', inplace=True)
    params_df['D rho'] = rho_df['rho']
    params_df['rho unc'] = rho_df['rho unc']
    params_df['D dollars'] = rho_df['dollars']
    params_df['dollars unc'] = rho_df['dollars unc']

    for x_value in params_df.index.values.tolist():
        if x_value == original_x_value:
            params_df.loc[x_value, 'D x'] = 0
            params_df.loc[x_value, 'coef rho'], params_df.loc[x_value, 'coef rho unc'], \
            params_df.loc[x_value, 'coef dollars'], params_df.loc[x_value, 'coef dollars unc'], \
            params_df.loc[x_value, 'coef rho avg'], params_df.loc[x_value, 'coef dollars avg'] = 0, 0, 0, 0, 0, 0
        else:
            if module_name == 'coef_void':
                params_df.loc[x_value, 'D x'] = -100 * round(x_value - original_x_value, 1)
            elif module_name == 'coef_pntc':
                params_df.loc[x_value, 'D x'] = round(x_value - original_x_value, 1)
            elif module_name == 'coef_mod':
                params_df.loc[x_value, 'D x'] = round(x_value - original_x_value, 1)

            params_df.loc[x_value, 'coef rho'] = params_df.loc[x_value, 'D rho'] / params_df.loc[x_value, 'D x']
            params_df.loc[x_value, 'coef dollars'] = params_df.loc[x_value, 'D dollars'] / params_df.loc[x_value, 'D x']

            if module_name == 'coef_void' or 'coef_pntc' or 'coef_mod':
                params_df.loc[x_value, 'coef rho unc'] = params_df.loc[x_value, 'rho unc'] / 100
                params_df.loc[x_value, 'coef dollars unc'] = params_df.loc[x_value, 'dollars unc'] / 100

        if module_name == 'coef_mod':
            params_df.loc[x_value, 'density'] = find_water_density(x_value)

    for x_value in params_df.index.values.tolist():
        x = []
        if str(module_name).lower() == 'coef_void':
            x = [i for i in params_df.index.values.tolist() if x_value <= i <= original_x_value]
        elif str(module_name).lower() == 'coef_pntc' or 'coef_mod':
            x = [i for i in params_df.index.values.tolist() if original_x_value <= i <= x_value]
        if len(x) > 1:
            y_rho = params_df.loc[x, 'coef rho'].tolist()
            params_df.loc[x_value, 'coef rho avg'] = np.mean(np.polyval(np.polyfit(x, y_rho, 1), x))
            y_dollars = params_df.loc[x, 'coef dollars'].tolist()
            params_df.loc[x_value, 'coef dollars avg'] = np.mean(np.polyval(np.polyfit(x, y_dollars, 1), x))

    print(f"\nVarious {module_name} parameters:\n{params_df}")
    params_df.to_csv(params_csv_name)


"""
prints dictionary of 'polynomial' and 'r-squared'
e.g., {'polynomial': [-0.0894, 0.234, 0.8843], 'r-squared': 0.960}
"""


def find_poly_reg(x, y, degree):
    results = {}
    coeffs = np.polyfit(x, y, degree)
    # Polynomial Coefficients
    results['polynomial'] = coeffs.tolist()
    # r-squared
    p = np.poly1d(coeffs)
    # fit values, and mean
    yhat = p(x)  # or [p(z) for z in x]
    ybar = np.sum(y) / len(y)  # or sum(y)/len(y)
    ssreg = np.sum((yhat - ybar) ** 2)  # or sum([ (yihat - ybar)**2 for yihat in yhat])
    sstot = np.sum((y - ybar) ** 2)  # or sum([ (yi - ybar)**2 for yi in y])
    results['r-squared'] = ssreg / sstot
    return results


def convert_keff_to_rho(keff_csv_name, rho_csv_name):
    # Assumes the keff.csv has columns labeled "rod" and "rod unc" for keff and keff uncertainty values for a given rod
    keff_df = pd.read_csv(keff_csv_name, index_col=0)
    rods = [c for c in keff_df.columns.values.tolist() if "unc" not in c]
    heights = keff_df.index.values.tolist()

    # Setup a dataframe to collect rho values
    rho_df = pd.DataFrame(columns=keff_df.columns.values.tolist())  # use lower cases to match 'rods' def above
    rho_df["height"] = heights
    rho_df.set_index("height", inplace=True)

    '''
    ERROR PROPAGATION FORMULAE
    % Delta rho = 100* frac{k2-k1}{k2*k1}
    numerator = k2-k1
    delta num = sqrt{(delta k2)^2 + (delta k1)^2}
    denominator = k2*k1
    delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
    delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
    '''
    for rod in rods:
        for height in heights:
            k1 = keff_df.loc[height, rod]
            k2 = keff_df.loc[heights[-1], rod]
            dk1 = keff_df.loc[height, f"{rod} unc"]
            dk2 = keff_df.loc[heights[-1], f"{rod} unc"]
            k2_minus_k1 = k2 - k1
            k2_times_k1 = k2 * k1
            d_k2_minus_k1 = np.sqrt(dk2 ** 2 + dk1 ** 2)
            d_k2_times_k1 = k2 * k1 * np.sqrt((dk2 / k2) ** 2 + (dk1 / k1) ** 2)
            rho = (k2 - k1) / (k2 * k1) * 100

            rho_df.loc[height, rod] = rho
            if k2_minus_k1 != 0:
                d_rho = rho * np.sqrt((d_k2_minus_k1 / k2_minus_k1) ** 2 + (d_k2_times_k1 / k2_times_k1) ** 2)
                rho_df.loc[height, f"{rod} unc"] = d_rho
            else:
                rho_df.loc[height, f"{rod} unc"] = 0

    print(f"\nDataframe of rho values and their uncertainties:\n{rho_df}\n")
    rho_df.to_csv(f"{rho_csv_name}")


'''
Converts a CSV of keff and uncertainty values to a CSV of rho and uncertainty values.

keff_csv_name: str, name of CSV of keff values, including extension, "keff.csv"
rho_csv_name: str, desired name of CSV of rho values, including extension, "rho.csv"

Does not return anything. Only makes the actual file changes.
'''


def convert_keff_to_rho_coef(original_x_value, keff_csv_name, rho_csv_name):
    # Assumes the keff.csv has columns labeled "rod" and "rod unc" for keff and keff uncertainty values for a given rod
    keff_df = pd.read_csv(keff_csv_name, index_col=0)
    x_values = keff_df.index.values.tolist()

    # Setup a dataframe to collect rho values
    rho_df = pd.DataFrame(columns=keff_df.columns.values.tolist())  # use lower cases to match 'rods' def above
    rho_df.columns = ['rho', 'rho unc']
    rho_df["x"] = x_values
    rho_df.set_index("x", inplace=True)

    '''
    ERROR PROPAGATION FORMULAE
    % Delta rho = 100* frac{k2-k1}{k2*k1}
    numerator = k2-k1
    delta num = sqrt{(delta k2)^2 + (delta k1)^2}
    denominator = k2*k1
    delta denom = k2*k1*sqrt{(frac{delta k2}{k2})^2 + (frac{delta k1}{k1})^2}
    delta % Delta rho = 100*sqrt{(frac{delta num}{num})^2 + (frac{delta denom}{denom})^2}
    '''

    for x_value in x_values:
        k1 = keff_df.loc[x_value, 'keff']
        k2 = keff_df.loc[original_x_value, 'keff']
        dk1 = keff_df.loc[x_value, 'keff unc']
        dk2 = keff_df.loc[original_x_value, 'keff unc']
        k2_minus_k1 = k2 - k1
        k2_times_k1 = k2 * k1
        d_k2_minus_k1 = np.sqrt(dk2 ** 2 + dk1 ** 2)
        d_k2_times_k1 = k2 * k1 * np.sqrt((dk2 / k2) ** 2 + (dk1 / k1) ** 2)
        rho = -(k2 - k1) / (k2 * k1) * 100
        dollars = 0.01 * rho / BETA_EFF

        rho_df.loc[x_value, 'rho'] = rho
        rho_df.loc[x_value, 'dollars'] = dollars
        # while the 'dollars' (and 'dollars unc') columns are not in the original rho_df definition,
        # simply defining a value inside it automatically adds the column
        if k2_minus_k1 != 0:
            rho_unc = rho * np.sqrt((d_k2_minus_k1 / k2_minus_k1) ** 2 + (d_k2_times_k1 / k2_times_k1) ** 2)
            dollars_unc = rho_unc / 100 / BETA_EFF
            rho_df.loc[x_value, 'rho unc'], rho_df.loc[x_value, 'dollars unc'] = rho_unc, dollars_unc
        else:
            rho_df.loc[x_value, 'rho unc'], rho_df.loc[x_value, 'dollars unc'] = 0, 0

    print(f"\nDataframe of rho values and their uncertainties:\n{rho_df}\n")
    rho_df.to_csv(f"{rho_csv_name}")