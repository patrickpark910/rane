import os
import sys
import numpy as np
import pandas as pd
from PIL import Image, ImageFont, ImageDraw, ImageEnhance

def draw_core_diagram_ppf(xlsx_filepath=None):
    """
    Load power spreadsheet

    Make sure:
    - spreadsheet has top-row columns headers "Core Position", "Element", "Power (kW)", "PPF"!
    - "Core Position" orders fuel elements in order from bottom right of core, reading left and up
    - "Element" has FE ID or "GRPH", "Core Component Name", "EMPTY", etc.
    - Only numbers are in "Power (kW)" and "PPF"
    """


    """
    Read spreadsheet into a Python dataframe
    """
    try:
        ppf_df = pd.read_excel(xlsx_filepath, engine='openpyxl') # need to specify openpyxl engine to read xlsx
    except:
        xlsx_filepath = None
        while xlsx_filepath is None:
            filepath = os.getcwd()
            xlsx_filepath = input(f"\n Current working directory: {filepath}\n Input spreadsheet file path and name, including extension: ")
            if xlsx_filepath in ['q', 'quit', 'kill']:
                sys.exit()
            elif xlsx_filepath in os.listdir(f'{filepath}'):
                pass
            else:
                print(f"\n  Warning. Spreadsheet {xlsx_filepath} cannot be found. Try again, or type 'quit' to quit.")
                xlsx_filepath = None
    ppf_df.set_index("Core Position", inplace=True)
    print(ppf_df)

    CORE_POS_MUTR = [int(i) for i in ppf_df.index.dropna().values.tolist()]
    
    """ 
    Setup coordinates of center of each core position.
    """
    # y-length, x-length of core
    H_core = 1600
    W_core = 12/10*H_core # pick core height and make other dimensions relative to it

    # number of rows of positions in core, number of positions per row
    num_rows, num_pos_per_row = 10, 12 # 
    
    # overall image width and height
    w, h = round(1.8*H_core), round(1.3*H_core) # play with these to get image dimensions you like

    core_offset_x, core_offset_y = (w-W_core)/3, (h-H_core)/2
    
    # core position box dimensions
    core_pos_box_w  = H_core/num_rows
    core_pos_box_h  = core_pos_box_w
    core_pos_box_w_half, core_pos_box_h_half = core_pos_box_w/2, core_pos_box_h/2 # for convenience

    """
    Produce 'coords_boxes_list' that is a list of lists of core position coordinates in each ring.
    These are relative coordinates with (0, 0) being top-left core position.
    coords_boxes_list = [[(1920.0, 1600.0), (1745.454545, 1600.0), (1570.909091, 1600.0), (1396.363636, 1600.0), (1221.818182, 1600.0), (1047.272727, 1600.0), (872.727273, 1600.0), (698.181818, 1600.0), (523.636364, 1600.0), (349.090909, 1600.0), (174.545455, 1600.0), (0.0, 1600.0)], [(1920.0, 1422.222222), (1745.454545, 1422.222222), (1570.909091, 1422.222222), (1396.363636, 1422.222222), (1221.818182, 1422.222222), (1047.272727, 1422.222222), (872.727273, 1422.222222), (698.181818, 1422.222222), (523.636364, 1422.222222), (349.090909, 1422.222222), (174.545455, 1422.222222), (0.0, 1422.222222)], [(1920.0, 1244.444444), (1745.454545, 1244.444444), (1570.909091, 1244.444444), (1396.363636, 1244.444444), (1221.818182, 1244.444444), (1047.272727, 1244.444444), (872.727273, 1244.444444), (698.181818, 1244.444444), (523.636364, 1244.444444), (349.090909, 1244.444444), (174.545455, 1244.444444), (0.0, 1244.444444)], [(1920.0, 1066.666667), (1745.454545, 1066.666667), (1570.909091, 1066.666667), (1396.363636, 1066.666667), (1221.818182, 1066.666667), (1047.272727, 1066.666667), (872.727273, 1066.666667), (698.181818, 1066.666667), (523.636364, 1066.666667), (349.090909, 1066.666667), (174.545455, 1066.666667), (0.0, 1066.666667)], [(1920.0, 888.888889), (1745.454545, 888.888889), (1570.909091, 888.888889), (1396.363636, 888.888889), (1221.818182, 888.888889), (1047.272727, 888.888889), (872.727273, 888.888889), (698.181818, 888.888889), (523.636364, 888.888889), (349.090909, 888.888889), (174.545455, 888.888889), (0.0, 888.888889)], [(1920.0, 711.111111), (1745.454545, 711.111111), (1570.909091, 711.111111), (1396.363636, 711.111111), (1221.818182, 711.111111), (1047.272727, 711.111111), (872.727273, 711.111111), (698.181818, 711.111111), (523.636364, 711.111111), (349.090909, 711.111111), (174.545455, 711.111111), (0.0, 711.111111)], [(1920.0, 533.333333), (1745.454545, 533.333333), (1570.909091, 533.333333), (1396.363636, 533.333333), (1221.818182, 533.333333), (1047.272727, 533.333333), (872.727273, 533.333333), (698.181818, 533.333333), (523.636364, 533.333333), (349.090909, 533.333333), (174.545455, 533.333333), (0.0, 533.333333)], [(1920.0, 355.555556), (1745.454545, 355.555556), (1570.909091, 355.555556), (1396.363636, 355.555556), (1221.818182, 355.555556), (1047.272727, 355.555556), (872.727273, 355.555556), (698.181818, 355.555556), (523.636364, 355.555556), (349.090909, 355.555556), (174.545455, 355.555556), (0.0, 355.555556)], [(1920.0, 177.777778), (1745.454545, 177.777778), (1570.909091, 177.777778), (1396.363636, 177.777778), (1221.818182, 177.777778), (1047.272727, 177.777778), (872.727273, 177.777778), (698.181818, 177.777778), (523.636364, 177.777778), (349.090909, 177.777778), (174.545455, 177.777778), (0.0, 177.777778)], [(1920.0, 0.0), (1745.454545, 0.0), (1570.909091, 0.0), (1396.363636, 0.0), (1221.818182, 0.0), (1047.272727, 0.0), (872.727273, 0.0), (698.181818, 0.0), (523.636364, 0.0), (349.090909, 0.0), (174.545455, 0.0), (0.0, 0.0)]]
    """
    # list of lists of core pos coords in each
    coords_boxes_list = []

    for j in range(0, num_rows):
        coords_list_row = []
        for i in range(0, num_pos_per_row):
            x = float('{:.6f}'.format( W_core - i * (W_core/(num_pos_per_row-1)) ))
            y = float('{:.6f}'.format( H_core - j * (H_core/(num_rows-1)) ))
            coords_list_row.append((x,y))
        coords_boxes_list.append(coords_list_row)

    print(f"coords_boxes_list = {coords_boxes_list}")

    """
    Produce relative coordinates for column headers
    """
    coords_cols_dict = {}
    cols = ['3', '4', '5', '6', '7', '8']
    k = 0
    
    for i in range(0, len(cols)):
        x = float('{:.6f}'.format( W_core - (2*i + 0.5) * (W_core/(num_pos_per_row-1)) ))
        y = -1 * core_pos_box_w 
        coords_cols_dict.update( {cols[k] : (x, y)} )
        k += 1

    """
    Produce relative coordinates for row headers
    """
    coords_rows_dict = {}
    rows = ['B', 'C', 'D', 'E', 'F']
    k = 0
    
    for j in range(0, len(rows)):
        x = -1 * core_pos_box_h
        y = float('{:.6f}'.format( H_core - (2*j + 0.5) * (H_core/(num_rows-1)) ))
        coords_rows_dict.update( {rows[k] : (x, y)} )
        k += 1

    
    """
    Setup colors & font
    """    
    # make the power or ppf data heat colors as purple, blue, green, yellow, orange, red
    # ppf_fill_colors = ["purple", "blue", "green", "yellow", "orange", "red"] # RGB colors
    ppf_fill_colors = ["#CC99C9", "#9EC1CF", "#9EE09E", "#FDFD97", "#FEB144", "#FF6663"] # pastel colors
    grph_fill_color = "#CFCFC4" # pastel gray
    core_comp_fill_color = "white"
    empty_fill_color = "black"

    # font
    font = ImageFont.truetype("arial", size=40) # play with size

    """
    Analyze dataframe and fill in core positions
    """
    for plot_type in ["Power (kW)", "PPF"]: 
        core_pos_counter = 0

        """
        Initialize the canvas object
        """
        core_diagram = Image.new("RGB", (w, h), "white")
        core_pos_img = ImageDraw.Draw(core_diagram)

        for coords_list_row in coords_boxes_list:
            for coords in coords_list_row:
                if core_pos_counter <= len(CORE_POS_MUTR)-1:

                    x, y = coords[0], coords[1]
                    core_pos_text = int(CORE_POS_MUTR[core_pos_counter])
                    fe_id_text = str(ppf_df.loc[core_pos_text, "Element"]).split('.')[0]
                    ppf_text = " "
                    fill_color = core_comp_fill_color

                    if str(ppf_df.loc[core_pos_text, "Element"]).upper() == "GRPH":
                        fill_color = grph_fill_color
                    elif str(ppf_df.loc[core_pos_text, "Element"]).upper() == "EMPTY":
                        fill_color = empty_fill_color
                    elif ppf_df.loc[core_pos_text, plot_type] >= 0:
                        ppf_text = str('{:.2f}'.format(ppf_df.loc[core_pos_text, plot_type]))

                        ppf_range_increment = (max(ppf_df[plot_type].dropna().tolist()) - min(ppf_df[plot_type].dropna().tolist())) / 6
                        ppf_min = float('{:.2f}'.format(min(ppf_df[plot_type].dropna().tolist())))
                        ppf_max = float('{:.2f}'.format(max(ppf_df[plot_type].dropna().tolist())))
                        ppf_heat_ranges = [ppf_min, ppf_min + ppf_range_increment, ppf_min + 2 * ppf_range_increment, ppf_min + 3 * ppf_range_increment, 
                                      ppf_min + 4 * ppf_range_increment, ppf_min + 5 * ppf_range_increment, ppf_max]

                        for i in range(0, len(ppf_heat_ranges)-1):
                            if ppf_heat_ranges[i] <= float(ppf_text) <= ppf_heat_ranges[i+1]: # a <= b <= c gets expanded to a <= b and b <= c
                                fill_color = ppf_fill_colors[i]
                        
                    core_pos_text_w, core_pos_text_h = core_pos_img.textsize(str(core_pos_text), font=font)
                    fe_id_text_w, fe_id_text_h = core_pos_img.textsize(fe_id_text, font=font)
                    ppf_text_w, ppf_text_h = core_pos_img.textsize(ppf_text, font=font)

                    # Draw the core position box
                    # use .rectangle() to make box or .ellipse() to make circle
                    core_pos_img.ellipse([(core_offset_x + x - core_pos_box_w_half, core_offset_y + y - core_pos_box_h_half),
                                            (core_offset_x + x + core_pos_box_w_half, core_offset_y + y + core_pos_box_h_half)], 
                                            fill=fill_color, outline = "black", width=2)

                    # Print Core Position ('C14')
                    # core_pos_img.text((w/2.5 + x - core_pos_text_w/2, h/2 + y - core_pos_box_h_half/2 - core_pos_text_h/2), core_pos_text, font=font, fill="black")
                    # Print Element ID
                    # change the (-a*core_pos_box_h_half/b) value to adjust vertical positioning of text in box
                    core_pos_img.text((core_offset_x + x - fe_id_text_w/2, core_offset_y + y - (4*core_pos_box_h_half/12) - fe_id_text_h/2),          fe_id_text, font=font, fill="black")
                    # Print Power or PPF Value
                    # change the (+a*core_pos_box_h_half/b) value to adjust vertical positioning of text in box
                    core_pos_img.text((core_offset_x + x - ppf_text_w/2,   core_offset_y + y + (4*core_pos_box_h_half/12) - ppf_text_h/2),      ppf_text, font=font, fill="black")
                    # origin is top left corner, y-coords is positive as it goes down

                    core_pos_counter += 1

        """
        Draw column headers
        """
        core_col_img = ImageDraw.Draw(core_diagram)
        for col_name in coords_cols_dict.keys():
            core_col_text_w, core_col_text_h = core_pos_img.textsize(str(col_name), font=font)
            core_col_x, core_col_y = coords_cols_dict[col_name][0], coords_cols_dict[col_name][1]
            core_col_img.rectangle([(core_offset_x + core_col_x - 2.1*core_pos_box_w_half, core_offset_y + core_col_y - core_pos_box_h_half/3),
                                    (core_offset_x + core_col_x + 2.1*core_pos_box_w_half, core_offset_y + core_col_y + core_pos_box_h_half/3)], 
                                   fill="white", outline = "black", width=2)
            core_col_img.text((core_offset_x + core_col_x - core_col_text_w/2, core_offset_y + core_col_y - core_col_text_h/2), 
                              col_name, font=font, fill="black")

        """
        Draw row headers
        """
        core_row_img = ImageDraw.Draw(core_diagram)
        for row_name in coords_rows_dict.keys():
            core_row_text_w, core_row_text_h = core_pos_img.textsize(str(row_name), font=font)
            core_row_x, core_row_y = coords_rows_dict[row_name][0], coords_rows_dict[row_name][1]
            core_row_img.rectangle([(core_offset_x + core_row_x - core_pos_box_w_half/3, core_offset_y + core_row_y - 2.1*core_pos_box_h_half),
                                    (core_offset_x + core_row_x + core_pos_box_w_half/3, core_offset_y + core_row_y + 2.1*core_pos_box_h_half)], 
                                   fill="white", outline = "black", width=2)
            core_row_img.text((core_offset_x + core_row_x - core_row_text_w/2, core_offset_y + core_row_y - core_row_text_h/2), 
                              row_name, font=font, fill="black")
        

        """
        Draw heat boxes
        """
        heat_box_img = ImageDraw.Draw(core_diagram)
        heat_box_w, heat_box_h = core_pos_box_w/4, H_core/(len(ppf_heat_ranges)+3)
        heat_box_offset_x, heat_box_offset_y = (6/7)*w, core_offset_y
        # print(f" heat_box_offset_y = {heat_box_offset_y} \n h = {h} \n H_core = {H_core} ")

        heat_scale_title = plot_type
        heat_scale_title_w, heat_scale_title_h = heat_box_img.textsize(heat_scale_title, font=font)
        
        heat_box_img.text((heat_box_offset_x, heat_box_offset_y - 2*heat_scale_title_h), heat_scale_title, font=font, fill="black")
        heat_box_img.line([(heat_box_offset_x, heat_box_offset_y),(heat_box_offset_x+ 1.75*heat_box_w, heat_box_offset_y)], fill="black", width=3)
        heat_box_img.text((heat_box_offset_x+ 2*heat_box_w, heat_box_offset_y - heat_scale_title_h/2), str('{:.2f}'.format(ppf_heat_ranges[-1])), font=font, fill="black")

        for i in range(1, len(ppf_heat_ranges)):
            heat_box_img.rectangle([(heat_box_offset_x, heat_box_offset_y+ (i-1)*heat_box_h),(heat_box_offset_x+ heat_box_w, heat_box_offset_y+ i*heat_box_h)], fill=ppf_fill_colors[-i], outline = "black", width=2)
            heat_box_img.line([(heat_box_offset_x, heat_box_offset_y+ i*heat_box_h),(heat_box_offset_x+ 1.75*heat_box_w, heat_box_offset_y+ i*heat_box_h)], fill="black", width=3)
            heat_box_img.text((heat_box_offset_x+ 2*heat_box_w, heat_box_offset_y+ i*heat_box_h - heat_scale_title_h/2), str('{:.2f}'.format(ppf_heat_ranges[-i-1])), font=font, fill="black")

        """
        Draw Core Component, Graphite, Empty legend boxes
        """
        heat_scale_key_grph, heat_scale_key_core_comp, heat_scale_key_empty = "Graphite", "Core\nComponent", "Empty"

        heat_box_img.rectangle([(heat_box_offset_x, heat_box_offset_y+ (len(ppf_heat_ranges))*heat_box_h),(heat_box_offset_x+ heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+1)*heat_box_h)], fill=core_comp_fill_color, outline = "black", width=2)            
        heat_box_img.text((heat_box_offset_x+ 2*heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+0.33)*heat_box_h - heat_scale_title_h/2), heat_scale_key_core_comp, font=font, fill="black")

        heat_box_img.rectangle([(heat_box_offset_x, heat_box_offset_y+ (len(ppf_heat_ranges)+1)*heat_box_h),(heat_box_offset_x+ heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+2)*heat_box_h)], fill=grph_fill_color, outline = "black", width=2)            
        heat_box_img.text((heat_box_offset_x+ 2*heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+1.5)*heat_box_h - heat_scale_title_h/2), heat_scale_key_grph, font=font, fill="black")
        
        heat_box_img.rectangle([(heat_box_offset_x, heat_box_offset_y+ (len(ppf_heat_ranges)+2)*heat_box_h),(heat_box_offset_x+ heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+3)*heat_box_h)], fill=empty_fill_color, outline = "black", width=2)            
        heat_box_img.text((heat_box_offset_x+ 2*heat_box_w, heat_box_offset_y+ (len(ppf_heat_ranges)+2.5)*heat_box_h - heat_scale_title_h/2), heat_scale_key_empty, font=font, fill="black")
        
        """
        Show and save the figures
        """
        # Show figure
        core_diagram.show()
        # Save figure
        core_diagram.save(f"{'/'.join(xlsx_filepath.split('/')[:-1])}PowerDistribution_MUTR_results_{plot_type.split()[0].lower()}.png")

        
if __name__ == '__main__':
    draw_core_diagram_ppf(xlsx_filepath=f"{os.getcwd()}/PowerDistribution_MUTdR_params.xlsx")