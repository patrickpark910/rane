import os
import sys
import getpass
import multiprocessing

sys.path.insert(0, "./Python/")
from Parameters import *
from MCNP_File import *
from FigureGraphics import *

def PowerDistribution(filepath, base_file_path=None):

    initialize_rane()

    """
    Ask user for base file and whether to run MCNP, if not already provided.
    """
    if base_file_path is None:
        base_file_path = find_base_file(f"{filepath}/.")  # filepath/. goes up one dir level

    base_file_name = base_file_path.split('/')[-1]
    module_name = "PowerDistribution"

    """
    Create the /Module/inputs folders if they do not already exist.
    """
    mcnp_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}"
    mcnp_module_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}"
    inputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{INPUTS_FOLDER_NAME}"
    outputs_folder_path = f"{filepath}/{MCNP_FOLDER_NAME}/{module_name}/{OUTPUTS_FOLDER_NAME}"
    
    results_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}"
    results_module_folder_path = f"{filepath}/{RESULTS_FOLDER_NAME}/{module_name}"
    
    params_xlsx_name = f"{module_name}_{PARAMS_XLSX_NAME}"

    paths_to_create = [mcnp_folder_path, mcnp_module_folder_path, 
                       inputs_folder_path, outputs_folder_path, 
                       results_folder_path, results_module_folder_path]
    
    create_paths(paths_to_create)
    
    for f in os.listdir(inputs_folder_path):
        os.remove(os.path.join(inputs_folder_path, f))


    """
    Read input file to identify
    """
    core_positions_dict = read_core_loading(base_file_path)
    core_positions_dict_reversed = {value : key for (key, value) in core_positions_dict.items()}
    print(f"core_positions_dict = {core_positions_dict}")

    """
    Create input file for each desired bank calibratrion height.

    Function change_rod_height returns True if input file was created and vice versa.
    It has an overwrite option to overwrite input files with the same name.
    """
    num_inputs_created = 0
    num_inputs_skipped = 0

    rod_heights_dict = {"safe": 100, "shim": 100, "reg": 100}
    input_created = change_rod_height(inputs_folder_path, base_file_path, rod_heights_dict, overwrite=True)
    if input_created: num_inputs_created += 1
    if not input_created: num_inputs_skipped += 1
    
    print(f"Created {num_inputs_created} new input decks.")
    if num_inputs_skipped > 0:
        print(f"\n  Warning. Skipped {num_inputs_skipped} input decks because they already exist and overwriting was turned off.")


    """
    
    """
    f4_tally_id_power_density_found = False
    for file in os.listdir(f"{inputs_folder_path}"):
        for line in reversed(f"{inputs_folder_path}/{file}"):
            if line.lower().startswith(f"f{F4_TALLY_ID_POWER_DENSITY}"):
                f4_tally_id_power_density_found = True
                print(f"\nComment. Found F{F4_TALLY_ID_POWER_DENSITY} tally card for power density.")

        if not f4_tally_id_power_density_found:
            open(f"{inputs_folder_path}/{file}", "a").write("\n" + write_f4_cards_power_density(core_positions_dict))
            open(f"{inputs_folder_path}/{file}", "a").close()
            if f"f{F4_TALLY_ID_POWER_DENSITY}" not in f"{inputs_folder_path}/{file}":
                try:
                    os.rename(f"{inputs_folder_path}/{file}", f"{inputs_folder_path}/{file.split('.')[0]}-f{F4_TALLY_ID_POWER_DENSITY}.i") 
                except:
                    print(f"\n  Warning. Renaming {inputs_folder_path}/{file} to {inputs_folder_path}/{file.split('.')[0]}-f{F4_TALLY_ID_POWER_DENSITY}.i failed.")

    """
    Run MCNP for every input file in the ./module_name/inputs folder.
    """
    tasks = os.cpu_count()
    for file in os.listdir(f"{inputs_folder_path}"):
        run_mcnp(f"{inputs_folder_path}/{file}", f"{outputs_folder_path}", tasks)
    delete_files(f"{outputs_folder_path}", r=True, s=True)



    """
    """
    file_count = 0
    for file in os.listdir(outputs_folder_path):
        """
        Setup a dataframe to collect keff values
        """
        ppf_df = pd.DataFrame(columns=["Core Position", "Element", "Power Density (W/cm^3)", "Power Density Unc (W/cm^3)", "Power (kW)", "Power Unc (kW)", "Avg Power (kW)", "Min Power (kW)", "Max Power (kW)"]) 
        ppf_df["Core Position"] = core_positions_dict.keys()
        ppf_df.set_index("Core Position", inplace=True)
        for core_pos in core_positions_dict:
            if core_positions_dict[core_pos] == '60':
                ppf_df.loc[core_pos, "Element"] = "AmBe"
            elif core_positions_dict[core_pos] == '70':
                ppf_df.loc[core_pos, "Element"] = "Ir-192"
            elif core_positions_dict[core_pos] == '80':
                ppf_df.loc[core_pos, "Element"] = "GRPH"
            else:
                ppf_df.loc[core_pos, "Element"] = core_positions_dict[core_pos]
        

        core_positions_dict = read_core_loading(f"{inputs_folder_path}/{file.split('_')[-1].split('.')[0]}.i")
        core_positions_dict_reversed = {value : key for (key, value) in core_positions_dict.items()}
        print(f"core_positions_dict = {core_positions_dict}")

        ppf_data = extract_power_density(f"{outputs_folder_path}/{file}", tally_id=F4_TALLY_ID_POWER_DENSITY)
        total_power, total_power_unc = 0, 0

        for tuples in ppf_data:
            fe_id = tuples[0].split('.')[0] 
            core_pos = core_positions_dict_reversed[fe_id]
            total_power += tuples[1]*W_PER_CM3_TO_KW_PER_FUEL_ELEMENT
            total_power_unc += tuples[2]*W_PER_CM3_TO_KW_PER_FUEL_ELEMENT
            ppf_df.loc[core_pos, "Element"] = tuples[0]
            ppf_df.loc[core_pos, "Power Density (W/cm^3)"] = tuples[1]
            ppf_df.loc[core_pos, "Power Density Unc (W/cm^3)"] = tuples[2]
            ppf_df.loc[core_pos, "Power (kW)"] = tuples[1]*W_PER_CM3_TO_KW_PER_FUEL_ELEMENT
            ppf_df.loc[core_pos, "Power Unc (kW)"] = tuples[2]*W_PER_CM3_TO_KW_PER_FUEL_ELEMENT
        
        """

        """
        avg_power, avg_power_unc = total_power/len(ppf_data), total_power_unc/len(ppf_data)
        
        for tuples in ppf_data:
            fe_id = tuples[0].split('.')[0] 
            core_pos = core_positions_dict_reversed[fe_id]
            ppf_df.loc[core_pos, "Percent of Total Power"] = (ppf_df.loc[core_pos, "Power (kW)"])/total_power*100
            ppf_df.loc[core_pos, "Avg Power (kW)"] = avg_power
            ppf_df.loc[core_pos, "Min Power (kW)"] = min(ppf_df["Power (kW)"].dropna().tolist())
            ppf_df.loc[core_pos, "Max Power (kW)"] = max(ppf_df["Power (kW)"].dropna().tolist())
            ppf_df.loc[core_pos, "Total Power (kW)"] = total_power
            ppf_df.loc[core_pos, "Total Power Unc (kW)"] = total_power_unc
            ppf_df.loc[core_pos, "PPF"] = (ppf_df.loc[core_pos, "Power (kW)"])/avg_power
            
        # ppf_df = ppf_df.fillna("NA") # use df.dropna() instead!
        avg_ppf = sum(ppf_df["PPF"].dropna().tolist())/len(ppf_df["PPF"].dropna().tolist())
        min_ppf, max_ppf = min(ppf_df["PPF"].dropna().tolist()),  max(ppf_df["PPF"].dropna().tolist())

        for tuples in ppf_data:
            fe_id = tuples[0].split('.')[0] 
            core_pos = core_positions_dict_reversed[fe_id]
            ppf_df.loc[core_pos, "Avg PPF"] = avg_ppf
            ppf_df.loc[core_pos, "Min PPF"] = min_ppf
            ppf_df.loc[core_pos, "Max PPF"] = max_ppf

        """
        Print results
        """
        print(ppf_df)
        print("\n =====> total core thermal power +/- 1 standev   = {:0.2f} +/- {:0.2f}   kW \n".format(total_power, total_power_unc))
        print(" =====> average core thermal power +/- 1 standev = {:0.4f} +/- {:0.4f} kW \n".format(avg_power, avg_power_unc))

        """
        Save results
        """
        # Create a Pandas Excel writer using XlsxWriter as the engine.
        if file_count == 0:
            xlsx_name = pd.ExcelWriter(f"{results_module_folder_path}/{params_xlsx_name}", engine='xlsxwriter')
            # Convert the dataframe to an XlsxWriter Excel object.
            ppf_df.to_excel(xlsx_name, sheet_name=file.split('o_')[-1].split('.')[0][0:30], index=True)
        else: 
            ppf_df.to_excel(xlsx_name, sheet_name=file.split('o_')[-1].split('.')[0][0:28]+f"_{file_count}", index=True)
        
        # Close the Pandas Excel writer and output the Excel file.
        xlsx_name.save()
        file_count += 1

        """
        Draw core diagram
        """
        draw_core_diagram_ppf(xlsx_filepath=f"{results_module_folder_path}/{params_xlsx_name}")


if __name__ == '__main__':
    PowerDistribution("C:/MCNP6/facilities/reed/rane", base_file_path="ReedCore49.i")



