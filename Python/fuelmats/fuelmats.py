import sys
from openpyxl import load_workbook
import pandas as pd

def main():
    fuel_meat_vol = 3.141592 * (1.822450**2 - 0.285750**2) * (53.45684 - 15.35684)
    fuel_wb_name = "Core Burnup History 20201117.xlsx"
    burnup_sht_name = "Core History"
    if fuel_wb_name is None: fuel_wb_name = input("Input the fuel burnup spreadsheet name, with file extension: ")

    # burnup_sht: pandas dataframe
    burnup_df = pd.read_excel(fuel_wb_name, sheet_name=burnup_sht_name, usecols='I,J,L,V:X', engine='openpyxl')

    # Currently, 'burnup_sht' uses the first row as column names. Rename it to the column letters used in the XLSX.
    burnup_df.columns = ['I','J','L','V','W','X']

    # Let's get rid of all the empty rows or rows with text in them.
    burnup_df = burnup_df[pd.to_numeric(burnup_df.iloc[:, 0], errors='coerce').notnull()]
    print(burnup_df)
    # Let's get rid of FE 101, as that is not a regular FE used in our MCNP code.
    burnup_df.drop(burnup_df.loc[burnup_df['I'] == 101].index, inplace=True)
    burnup_df.reset_index(drop=True, inplace=True)

    """ 
    df.apply(func, axis= {0 or ‘index’, 1 or ‘columns’, default 0}, result_type={‘expand’, default None}
    
    Notice that the get_mass_frac function actually outputs a list of 1 int and 5 floats.
    With result_type = None, the list is one entry in the new mass_fracs_df.
    With result_type = 'expand', each element of the list is separated into different columns
    """
    mass_fracs_df = burnup_df.apply(get_mass_fracs, axis=1, result_type='expand')
    print(mass_fracs_df)
    # Rename columns to their respective variable names
    mass_fracs_df.columns = ['fe_id', 'drawing_no', 
                             'g_U_new', 'g_U235', 'g_U238', 'g_Pu239', 'g_Zr', 'g_H', 
                             'a_U235', 'a_U238', 'a_Pu239', 'a_Zr', 'a_H']
    # Change fe_id values to integer, if they aren't already
    mass_fracs_df.astype({'fe_id':'int8'})

    # 'df.iloc[:,n]' prints the (n+1)th column of the dataframe
    cell_cards =  f"c --Begin Fuel Cells-- \
                  \nc fuel meat density auto-generated from '{fuel_wb_name}' \
                  \nc calculated fuel active section volume = {fuel_meat_vol:.6f} cm^3 "

    mat_cards = f"c --Begin Fuel Materials-- \
                \nc materials auto-generated from '{fuel_wb_name}' \
                \nc \
                \nc"

    fuel_densities_list = []
    g_U235_list, g_U238_list, g_Pu239_list, g_Zr_list, g_H_list = [], [], [], [], []
    a_U235_list, a_U238_list, a_Pu239_list, a_Zr_list, a_H_list = [], [], [], [], []

    for i in range(0,len(mass_fracs_df)):
        fuel_meat_mass_total = mass_fracs_df.loc[i,'g_U235'] + mass_fracs_df.loc[i,'g_U238'] + mass_fracs_df.loc[i,'g_Pu239'] + mass_fracs_df.loc[i,'g_Zr'] + mass_fracs_df.loc[i,'g_H']
        fuel_meat_density = round((fuel_meat_mass_total / fuel_meat_vol), 4)
        fuel_densities_list.append(float(fuel_meat_density))

        g_U235_list.append(mass_fracs_df.loc[i,'g_U235'])
        g_U238_list.append(mass_fracs_df.loc[i,'g_U238'])
        g_Pu239_list.append(mass_fracs_df.loc[i,'g_Pu239'])
        g_Zr_list.append(mass_fracs_df.loc[i,'g_Zr'])
        g_H_list.append(mass_fracs_df.loc[i,'g_H'])

        a_U235_list.append(mass_fracs_df.loc[i,'a_U235'])
        a_U238_list.append(mass_fracs_df.loc[i,'a_U238'])
        a_Pu239_list.append(mass_fracs_df.loc[i,'a_Pu239'])
        a_Zr_list.append(mass_fracs_df.loc[i,'a_Zr'])
        a_H_list.append(mass_fracs_df.loc[i,'a_H'])


    fuel_density_avg = round(sum(fuel_densities_list) / len(fuel_densities_list), 6)
    g_U235_avg = round(sum(g_U235_list) / len(g_U235_list), 12)
    g_U238_avg = round(sum(g_U238_list) / len(g_U238_list), 12)
    g_Pu239_avg = round(sum(g_Pu239_list) / len(g_Pu239_list), 12)
    g_Zr_avg = round(sum(g_Zr_list) / len(g_Zr_list), 12)
    g_H_avg = round(sum(g_H_list) / len(g_H_list), 12)

    a_U235_avg = round(sum(a_U235_list) / len(a_U235_list), 12)
    a_U238_avg = round(sum(a_U238_list) / len(a_U238_list), 12)
    a_Pu239_avg = round(sum(a_Pu239_list) / len(a_Pu239_list), 12)
    a_Zr_avg = round(sum(a_Zr_list) / len(a_Zr_list), 12)
    a_H_avg = round(sum(a_H_list) / len(a_H_list), 12)

    cell_cards += f"\nc average fuel meat density = {fuel_density_avg:.6f} g/cm^3 \
                    \nc \
                    \nc"

    mat_cards += f"\nc --- AVERAGED - SS clad fuel meat materials --- \
                   \nc mAVRG  92235.80c -{g_U235_avg:.6}    $ mass frac (g) | atom frac: {a_U235_avg:.6e} \
                   \nc        92238.80c -{g_U238_avg:.6f}   $ mass frac (g) | atom frac: {a_U238_avg:.6e} \
                   \nc        94239.80c -{g_Pu239_avg:.6f}     $ mass frac (g) | atom frac: {a_Pu239_avg:.6e} \
                   \nc        40000.66c -{g_Zr_avg:.6f}  $ mass frac (g) | atom frac: {a_Zr_avg:.6e} \
                   \nc         1001.80c -{g_H_avg:.6f}    $ mass frac (g) | atom frac: {a_H_avg:.6e} \
                   \nc \
                   \nc"

    for i in range(0,len(mass_fracs_df)):
        fe_id = mass_fracs_df.loc[i,'fe_id']

        fuel_meat_mass_total = mass_fracs_df.loc[i,'g_U235'] + mass_fracs_df.loc[i,'g_U238'] + mass_fracs_df.loc[i,'g_Pu239'] + mass_fracs_df.loc[i,'g_Zr'] + mass_fracs_df.loc[i,'g_H']
        fuel_meat_density = round((fuel_meat_mass_total / fuel_meat_vol), 6)
        
        cell_card   = f"\nc --- {fe_id} - SS clad ({mass_fracs_df.loc[i,'drawing_no']}) universe --- "

        if str(fe_id) == "10705": fe_id = "1070"

        cell_card  += f"\nc \
                        \n{fe_id}01   105 -7.85     312300 -312301 -311302          imp:n=1 u={fe_id}  $ Lower grid plate pin \
                        \n{fe_id}02   102 -1.00     312300 -312301  311302 -311306  imp:n=1 u={fe_id}  $ Water around grid plate pin  \
                        \n{fe_id}03   105 -7.85     312301 -312302 -311305          imp:n=1 u={fe_id}  $ Bottom casing  \
                        \n{fe_id}04   102 -1.00     312301 -312306  311305 -311306  imp:n=1 u={fe_id}  $ Water around fuel element \
                        \n{fe_id}05   106 -1.56     312302 -312303 -311304          imp:n=1 u={fe_id}  $ Lower graphite slug  \
                        \n{fe_id}06   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u={fe_id}  $ Fuel cladding \
                        \n{fe_id}07   108  0.042234 312303 -312304 -311301          imp:n=1 u={fe_id}  $ Zirc pin  \
                        \n{fe_id}08  {fe_id} -{fuel_meat_density} 312303 -302303  311301 -311304  imp:n=1 u={fe_id}  $ Fuel meat section 1 \
                        \n{fe_id}09  {fe_id} -{fuel_meat_density} 302303 -302306  311301 -311304  imp:n=1 u={fe_id}  $ Fuel meat section 2 \
                        \n{fe_id}10  {fe_id} -{fuel_meat_density} 302306 -302309  311301 -311304  imp:n=1 u={fe_id}  $ Fuel meat section 3 \
                        \n{fe_id}11  {fe_id} -{fuel_meat_density} 302309 -302312  311301 -311304  imp:n=1 u={fe_id}  $ Fuel meat section 4 \
                        \n{fe_id}12  {fe_id} -{fuel_meat_density} 302312 -312304  311301 -311304  imp:n=1 u={fe_id}  $ Fuel meat section 5 \
                        \n{fe_id}13   106 -1.56     312304 -312305 -311304          imp:n=1 u={fe_id}  $ Upper graphite spacer \
                        \n{fe_id}14   105 -7.85     312305 -312306 -311305          imp:n=1 u={fe_id}  $ SS top cap  \
                        \n{fe_id}15   105 -7.85     312306 -312307 -311303          imp:n=1 u={fe_id}  $ Tri-flute  \
                        \n{fe_id}16   102 -1.00     312306 -312307  311303 -311306  imp:n=1 u={fe_id}  $ Water around tri-flute  \
                        \n{fe_id}17   105 -7.85     312307 -312308 -311302          imp:n=1 u={fe_id}  $ Fuel tip \
                        \n{fe_id}18   102 -1.00     312307 -312308  311302 -311306  imp:n=1 u={fe_id}  $ Water around fuel tip \
                        \n{fe_id}19   102 -1.00     312308 -312309 -311306          imp:n=1 u={fe_id}  $ Water above fuel element \
                        \nc \
                        \nc"
        cell_cards += cell_card

        mat_card    = f"\nc --- {fe_id} - SS clad ({mass_fracs_df.loc[i,'drawing_no']}) fuel meat materials --- \
                       \nm{fe_id}  92235.80c -{'{:.6f}'.format(mass_fracs_df.loc[i,'g_U235'])}    $ mass frac (g) | atom frac: {round(mass_fracs_df.loc[i,'a_U235'],6):.6e} \
                       \n       92238.80c -{'{:.6f}'.format(mass_fracs_df.loc[i,'g_U238'])}   $ mass frac (g) | atom frac: {round(mass_fracs_df.loc[i,'a_U238'],6):.6e} \
                       \n       94239.80c -{'{:.6f}'.format(mass_fracs_df.loc[i,'g_Pu239'])}     $ mass frac (g) | atom frac: {round(mass_fracs_df.loc[i,'a_Pu239'],6):.6e} \
                       \n       40000.66c -{'{:.6f}'.format(mass_fracs_df.loc[i,'g_Zr'])}  $ mass frac (g) | atom frac: {round(mass_fracs_df.loc[i,'a_Zr'],6):.6e} \
                       \n        1001.80c -{'{:.6f}'.format(mass_fracs_df.loc[i,'g_H'])}    $ mass frac (g) | atom frac: {round(mass_fracs_df.loc[i,'a_H'],6):.6e} \
                       \nmt{fe_id} h/zr.10t zr/h.10t \
                       \nc \
                       \nc"
        mat_cards  += mat_card
    
    cell_cards += f"\nc --End Fuel Cells--"
    mat_cards += f"\nc --End Fuel Materials--"

    fuel_cell_cards_file = open("fuel_cell_cards.txt", "w")
    fuel_cell_cards_file.write(cell_cards)
    fuel_cell_cards_file.close()

    fuel_mat_cards_file = open("fuel_mat_cards.txt", "w")
    fuel_mat_cards_file.write(mat_cards)
    fuel_mat_cards_file.close()
    #print(burnup_df)
    #print(len(mass_fracs_df))
    '''
    for fe_id in burnup_sht.iloc[:, 0]:
        if type(fe_id)=="int":
            print(burnup_sht.iloc[])
            
            g_Pu239 = V
            g_U235 = X
            g_U238 = W-X
            g_U_total = g_Pu239 + g_U235 + g_U238 # should be <= 8.5% of total weight (mass) of FE
            g_ZrH_total = g_U_total/8.5*91.5
            g_Zr = 1/(1.575+1)*g_ZrH_total
            g_H = 1.575/(1.575+1)*g_ZrH_total
    '''
# Adapted from: https://stackoverflow.com/questions/27575854/vectorizing-a-function-in-pandas
def get_mass_fracs(row):
    AMU_U235 = 235.0439299
    AMU_U238 = 238.05078826
    AMU_PU239 = 239.0521634
    AMU_ZR = 91.224
    AMU_H = 1.00794
    AVO = 6.022e23
    RATIO_HZR = 1.575 # TS allows 1.55 to 1.60. This is an ATOM ratio
    
    fe_id = row['I']
    drawing_no = row['J']
    g_U_new = row['L']
    g_Pu239 = row['V']
    g_U = row['W']
    g_U235 = row['X']

    g_U238 = g_U - g_U235 # We assume all the U is either U-235 or U-238.
    g_ZrH_total = g_U_new/ 8.5 * 91.5 # Assume rest of FE mass of ZrH
    a_Pu239 = g_Pu239 / AMU_PU239 * AVO
    a_U235 = g_U235 / AMU_U235 * AVO
    a_U238 = g_U238 / AMU_U238 * AVO
    a_Zr = g_ZrH_total/(AMU_ZR/AVO + RATIO_HZR*AMU_H/AVO)
    a_H = RATIO_HZR * a_Zr
    g_Zr = a_Zr * AMU_ZR / AVO
    g_H = a_H * AMU_H / AVO

    return fe_id, drawing_no, g_U_new, g_U235, g_U238, g_Pu239, g_Zr, g_H, a_U235, a_U238, a_Pu239, a_Zr, a_H
    # This process is known as 'vectorization'


if __name__ == "__main__":
    main()
