import os
import sys
import numpy as np
import pandas as pd
from PIL import Image, ImageFont, ImageDraw, ImageEnhance

sys.path.insert(0, "./Python/")


def draw_core_diagram_ppf(xlsx_filepath=None):
    CORE_POS = ['A1', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6',
            'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12',
            'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12',
            'D13', 'D14', 'D15', 'D16', 'D17', 'D18',
            'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12',
            'E13', 'E14', 'E15', 'E16', 'E17', 'E18', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24',
            'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 
            'F13', 'F14', 'F15', 'F16', 'F17', 'F18', 'F19', 'F20', 'F21', 'F22', 'F23', 'F24', 
            'F25', 'F26', 'F27', 'F28', 'F29', 'F30']
    """
    Load power spreadsheet

    Make sure:
    - spreadsheet has top-row columns headers "Core Position", "Element", "Power (kW)", "PPF"!
    - "Core Position" orders fuel elements in order from bottom right of core, reading left and up
    - "Element" has FE ID or "GRPH", "Core Component Name", "EMPTY", etc.
    - Only numbers are in "Power (kW)" and "PPF"
    """
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

    """
    Read spreadsheet into a Python dataframe
    """
    ppf_df = pd.read_excel(xlsx_filepath, engine='openpyxl') # need to specify openpyxl engine to read xlsx
    ppf_df.set_index("Core Position", inplace=True)
    
    """ 
    This section sets up the variable values necessary for future sections

    Ex. For R = 6, N = 2, P = [2, 4]
    print(ring_radii_list)
    >>> [2.0, 4.0]
    print(cords_list_all)
    >>> [[[0.0, 2.0], [-0.0, -2.0]], [[0.0, 4.0], [-4.0, 0.0], [-0.0, -4.0], [4.0, -0.0]]]
    """
    R_core, num_pos_per_ring = 1200, [6, 12, 18, 24, 30]
    num_rings = len(num_pos_per_ring)
    ring_radii_list = []

    ring_number_list = np.arange(1, num_rings + 1)
    for ring_number in ring_number_list:
        radius_increment = R_core / (num_rings + 1)
        new_radius = radius_increment * ring_number
        ring_radii_list.append(round(new_radius, 6))

    coords_list_all = [[[0,0]]]

    for r in ring_radii_list:
        number_of_points = int(num_pos_per_ring[ring_radii_list.index(r)])
        coords_list_for_this_ring = []
        for pos in np.arange(0, number_of_points):
            angle = 0 + 2 * np.pi / number_of_points * pos + np.pi / 2  # phase shift to begin at (0,y) and not (x, 0)
            angle += np.pi # PIL has +y pointing down, so phase shift another 180 deg to have B1, C1, etc. start at 12 oclock pos
            x = float("{:.12f}".format(r * np.cos(angle)))
            y = float("{:.12f}".format(r * np.sin(angle)))
            coords_list_for_this_ring.append([x, y])
        coords_list_all.append(coords_list_for_this_ring)

    """

    """
    w, h = round(2.33*R_core), round(1.875*R_core)
    core_diagram = Image.new("RGB", (w, h), "white")

    font = ImageFont.truetype("arial", size=40)

    # center of core pos circle
    x, y = 0, 0
    r = R_core / (2.25 * (num_rings + 1))


    # ppf_fill_colors = ["purple", "blue", "green", "yellow", "orange", "red"]
    ppf_fill_colors = ["#CC99C9", "#9EC1CF", "#9EE09E", "#FDFD97", "#FEB144", "#FF6663"]
    grph_fill_color = "#CFCFC4"
    core_comp_fill_color = "white"

    # font = ImageFont.load("arial.pil")
    # print(ppf_df.index.values.tolist())
    
    for plot_type in ["Power (kW)", "PPF"]: # , "Power Peaking Factor"]
        core_pos_counter = 0
        core_pos_img = ImageDraw.Draw(core_diagram)
        core_pos_img.rectangle([(0, 0),(w, h)], fill="white")

        for coords_list_ring in coords_list_all:
            for coords in coords_list_ring:
                x, y = coords[0], coords[1]
                
                core_pos_text = CORE_POS[core_pos_counter]

                fe_id_text = str(ppf_df.loc[core_pos_text, "Element"])
                if fe_id_text == "1070":
                    fe_id_text = "10705"

                ppf_text = " "
                fill_color = core_comp_fill_color
                if ppf_df.loc[core_pos_text, "Element"].upper() == "GRPH":
                    fill_color = grph_fill_color
                elif ppf_df.loc[core_pos_text, plot_type] >= 0:
                    ppf_text = str('{:.2f}'.format(ppf_df.loc[core_pos_text, plot_type]))

                    ppf_range_increment = (max(ppf_df[plot_type].dropna().tolist()) - min(ppf_df[plot_type].dropna().tolist())) / 6
                    ppf_min = float('{:.2f}'.format(min(ppf_df[plot_type].dropna().tolist())))
                    ppf_max = float('{:.2f}'.format(max(ppf_df[plot_type].dropna().tolist())))
                    ppf_ranges = [ppf_min, ppf_min + ppf_range_increment, ppf_min + 2 * ppf_range_increment, ppf_min + 3 * ppf_range_increment, 
                                  ppf_min + 4 * ppf_range_increment, ppf_min + 5 * ppf_range_increment, ppf_max]

                    for i in range(0, len(ppf_ranges)-1):
                        if ppf_ranges[i] <= float(ppf_text) <= ppf_ranges[i+1]: # a <= b <= c gets expanded to a <= b and b <= c
                            fill_color = ppf_fill_colors[i]
                    
                core_pos_text_w, core_pos_text_h = core_pos_img.textsize(core_pos_text, font=font)
                fe_id_text_w, fe_id_text_h = core_pos_img.textsize(fe_id_text, font=font)
                ppf_text_w, ppf_text_h = core_pos_img.textsize(ppf_text, font=font)

                
                core_pos_img.ellipse([(w/2.5 + x - r, h/2 + y - r),(w/2.5 + x + r, h/2 + y + r)], fill=fill_color, outline = "black", width=2)

                core_pos_img.text((w/2.5 + x - core_pos_text_w/2, h/2 + y - r/2 - core_pos_text_h/2), core_pos_text, font=font, fill="black")
                core_pos_img.text((w/2.5 + x - fe_id_text_w/2,    h/2 + y - fe_id_text_h/2),          fe_id_text, font=font, fill="black")
                core_pos_img.text((w/2.5 + x - ppf_text_w/2,      h/2 + y + r/2 - ppf_text_h/2),      ppf_text, font=font, fill="black")
                # origin is top left corner, y-coords is positive as it goes down

                core_pos_counter += 1

        heat_box_img = ImageDraw.Draw(core_diagram)
        heat_box_w, heat_box_h = R_core/20, R_core/len(ppf_ranges)
        heat_box_x, heat_box_y = (6/7)*w, (h-1.6*R_core)
        # print(f" heat_box_y = {heat_box_y} \n h = {h} \n R_core = {R_core} ")

        heat_scale_title = plot_type
        heat_scale_title_w, heat_scale_title_h = heat_box_img.textsize(heat_scale_title, font=font)
        
        heat_box_img.text((heat_box_x, heat_box_y - 2*heat_scale_title_h), heat_scale_title, font=font, fill="black")
        heat_box_img.line([(heat_box_x, heat_box_y),(heat_box_x+ 1.75*heat_box_w, heat_box_y)], fill="black", width=3)
        heat_box_img.text((heat_box_x+ 2*heat_box_w, heat_box_y - heat_scale_title_h/2), str('{:.2f}'.format(ppf_ranges[-1])), font=font, fill="black")

        for i in range(1, len(ppf_ranges)):
            heat_box_img.rectangle([(heat_box_x, heat_box_y+ (i-1)*heat_box_h),(heat_box_x+ heat_box_w, heat_box_y+ i*heat_box_h)], fill=ppf_fill_colors[-i], outline = "black", width=2)
            heat_box_img.line([(heat_box_x, heat_box_y+ i*heat_box_h),(heat_box_x+ 1.75*heat_box_w, heat_box_y+ i*heat_box_h)], fill="black", width=3)
            heat_box_img.text((heat_box_x+ 2*heat_box_w, heat_box_y+ i*heat_box_h - heat_scale_title_h/2), str('{:.2f}'.format(ppf_ranges[-i-1])), font=font, fill="black")

        heat_scale_key_grph, heat_scale_key_core_comp = "Graphite", "Core\nComponent"

        heat_box_img.rectangle([(heat_box_x, heat_box_y+ (len(ppf_ranges))*heat_box_h),(heat_box_x+ heat_box_w, heat_box_y+ (len(ppf_ranges)+1)*heat_box_h)], fill=core_comp_fill_color, outline = "black", width=2)            
        heat_box_img.text((heat_box_x+ 2*heat_box_w, heat_box_y+ (len(ppf_ranges)+0.33)*heat_box_h - heat_scale_title_h/2), heat_scale_key_core_comp, font=font, fill="black")

        heat_box_img.rectangle([(heat_box_x, heat_box_y+ (len(ppf_ranges)+1)*heat_box_h),(heat_box_x+ heat_box_w, heat_box_y+ (len(ppf_ranges)+2)*heat_box_h)], fill=grph_fill_color, outline = "black", width=2)            
        heat_box_img.text((heat_box_x+ 2*heat_box_w, heat_box_y+ (len(ppf_ranges)+1.5)*heat_box_h - heat_scale_title_h/2), heat_scale_key_grph, font=font, fill="black")
        
        # save in new file
        # core_diagram.show()
        core_diagram.save(f"{'/'.join(xlsx_filepath.split('/')[:-1])}/PowerDistribution_RRR_results_{plot_type.split()[0].lower()}.png")


if __name__ == '__main__':
    draw_core_diagram_ppf(xlsx_filepath=f"{os.getcwd()}/PowerDistribution_RRR_params.xlsx")