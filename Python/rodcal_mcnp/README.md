## rodcal-mcnp: Python-automated MCNP simulation of control rod calibration (integral and differential worth curve generation) 

Patrick Park | <ppark@reed.edu> | Physics '22 | Reed College

Last major code update: Jan. 1, 2021

### Scope

This project involves a python wrapper (`rc_m.py`) that:
1. edits the standard MCNP input deck (`rc.i`) to produce new input decks with desired rod heights for calibration
2. runs MCNP through cmd line
3. reads through MCNP output files to get final k_eff values
4. converts k_eff values to rho values 
5. plots integral and differential worth curves (`results.png`)

A `mcnp_funcs.py` has been created to contain some general python functions related to writing, running, or reading MCNP decks. 
The `mcnp_funcs.py` is not yet reverse-compatible with my earlier project, [**critloadexp**](https:/github.com/patrickpark910/critloadexp),
but I hope to use it as a base library in future projects.

### Results 

In `results.png`, the MCNP-predicted control rod worth curves are plotted. 

![Result figure produced](https://github.com/patrickpark910/rodcal-mcnp/blob/main/results_rho.png?raw=true)

From the plotted data, the following tabulated parameters can be calculated. From the maximum integral worth, the dollar worth of the rods were found. The maximum differential worth is the peak worth added per unit percent or inch of height. Using the current motor speeds and the maximum differential worth, the reactivity addition rates were found. Our federally-specified reactivity addition rate limit is $0.16/sec, so the maximum motor speed we can use without violating this limit was also computed.

| Rod  | Worth ($)         | Peak worth added per % height ($/%) | Peak worth added per height ($/in) | Current motor speed (in./min)  | Reactivity add. rate ($/sec) | Reactivity add. limit ($/sec) | Max motor speed (in./min) |
| ---- | :-----------------: | :----------------------------------: | :---------------------------------: | :--------------------------------: | :--------------------------------: | :------------------------:| :------------------------: |
| Safe | 3.41 | 0.05188                | 0.3468                | 19    | 0.1098  | 0.16        | 27.68        |
| Shim | 4.10 | 0.05765                | 0.3853                | 11    | 0.0706  | 0.16         | 24.91        |
| Reg  | 2.57 | 0.03587                | 0.2398                | 24    | 0.0959  | 0.16         | 40.04       |

My next project will be to improve our currently existing experimental rodcal python code during our annual maintenance and calibrations in mid-January.

### Procedure

*These instructions are designed to be inclusive of undergraduates and first-time CS learners.*

You need to have MCNP installed. It's an export-controlled, licensed software regulated by Big Brother at Oak Ridge National Laboratory.

> **If you don't have MCNP**, you can still run this program. I have included all the input and output decks necessary to bypass the MCNP sections.
> Alternatively, you can also just use the `convert_keff_to_rho()` and `plot_rodcal_data()` functions in `rc_m.py` to plot a given CSV of keff values into worth curves.
> See Technical Notes below.

You also need to have python installed, which you can Google how to do so. If you're not sure if it's installed, open cmd (Windows) or Terminal (Mac) and type in `python --version`
which will get you either your python version (`Python 3.7.1`) or an error.

First, open `rc_m.py` and change the `filepath` variable to the location of this project folder on your computer. 
For instance, the path of my `rc_m.py` is `C:\MCNP6\facilities\reed\rodcal-mcnp\rc_m.py`, so for me, `filepath = 'C:\MCNP6\facilities\reed\rodcal-mcnp`. Do **not** include a backslash at the end.

Then, run `rc_m.py` on your computer. This will be the only file you're really interacting with, unless you need to change the base MCNP input deck (`rc.i`).

1. On Windows, press the Windows key, type in `cmd`, and press `Enter`. On Mac, open Terminal using Spotlight search.
2. Change your directory to where this project is located. This should be what you typed in for `filepath`. Type in `cd` followed by a space and your filepath.
    
        cd C:\MCNP6\facilities\reed\critloadexp
    
3. To run the `cle.py` python file, type in `python rc_m.py` or `python3 rc_m.py`.
4. Follow the instructions printed on your cmd line. 
5. Currently, `.\inputs` and `.\outputs` come with all the MCNP files you need, so MCNP will not actually be run. 
Rename or relocate these two folders for `rc_m.py` to execute MCNP runs. 
### Technical Notes

#### Running whole `rc_m.py` without MCNP
As long as you have the `.\outputs` folder with all the `.o` files associated with the calibration heights, `rc_m.py` will skip execution of MCNP. 
However, if you change the default calibration heights in `rc_m.py` (0 to 100 in intervals of 5), you will be missing the associated MCNP `.o` output file,
so `rc_m.py` will execute a MCNP run, which will result in an error if you do not have MCNP.

Creating `.i` input decks in `.\inputs` does not require MCNP-- mechanically, these are just text replacements.

#### Inputting your own CSV of keff values and plotting them
You can place your own CSV of keff values into the project folder and have `rc_m.py` plot worth curves from that data. 

The `rc_m.py` expects your keff CSV to have the following format, 

| height | rod1 | rod1 unc | ... | rod3 unc|
|:---:|:---:|:---:|---|:---:|
| float | float | float | ... | float |

with up to 3 rods, where `rod#` is your rod name in lowercase, e.g. `shim`, and associated uncertainties, e.g. `shim unc`. 
The `rc_m.py` calculation and plotting functions will automatically recognize your rod names from your CSV and plot curves accordingly.

Ensuring your CSV is properly formatted, follow the commented instructions in `rc_m.py` to comment out the appropriate parts of the code so that it only reads your new CSV file. 
Then, in `rc_m.py`, change the `keff_csv_name` variable definition to a string with your CSV file name, e.g. `"keff.csv"`.

#### For use at another facility

You will need to edit a few functions to make sure `rc_m.py` properly recognizes where your control rod geometry parameters are located.

In your base input deck `rc.i`, you will need to add unique start and end markers for `rc_m.py` to recognize the surface cards for each rod. 
Your base input deck does not need to be `rc.i`. When you execute `rc_m.py`, you will have the option to pick any `.i` input file to use as the base deck.
Whichever deck you do use, just make sure it has these start and end markers that you specify in `rc_m.py`.

In `find_height()`, you will need to specify which surface card number that your control rods start with. 
It is hardcoded into `line[0].startswith("8")`, where Reed's control rod surfaces begin with `"8"`.

In `math()`, you may need to adjust how much 1% change in height adjusts the z-coordinate (axial height) per your specific core geometry.

### Acknowledgements

I learned this method of Python-MCNP automation thanks to my time working remotely with the NIST Center for Neutron Research. 
My `run_mcnp()` function is almost identical to Dr. Danyal Turkoglu's NCNR code library, and 
I have adapted the `extract_keff()` and iterative `matplotlib` worth curve plotting functions from what I wrote during my time working with him.
