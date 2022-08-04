

# Style Guidelines:

PEP8 Python Style Guidelines
Global constants are in CAPS and are most likely defined in ./Source/Python/Parameters.py


# Functionalities
The Reed Automated Neutronics has an individual "module" to calculate each reactivity parameter. To trace this code, open up `NeutronicsEngine.py` and start from there.

## Banked rods

`cd D:\MCNP6\facilities\reed\RANE_export`
`python3 NeutronicsEngine.py -r bank`

What this does: Calculates banked rods. In `./Results/bank`, produces a table of , calculates Estimated Critical Position (ECP), . Produces bank worth curve.

<details>
    <summary> **Nitty Gritty Details** </summary>
    A total of 6 files are produced:
    `reed_core49_bank_keff.csv`
    `reed_core49_bank_params.csv`
    `reed_core49_bank_rho.csv`
    `reed_core49_kntc_results.csv`

</details>


How to change things:
To change 
...

## Rod calibration

What this does: Calculates rod worths.


## Flux calculations

What this does: Calculates thermal, intermediate, fast neutron flux at the core IR positions and control rods. In `./Results/flux`, produces a spreadsheet of energy bins and flux values. The energy bins are logarithmically spaced, since most flux graphs are on a log-log scale.

## Plot

What this does: 

Warning: The MCNP plotter XMing may have slightly different commands from Windows to Mac. I don't expect this to work on other machines... The bulk of this module is the `run_geometry_plotter` function in `MCNP_File.py`, most problems will probably start from where RANE checks `platform.system()`.


## Moderator temperature coefficient [rcty_modr]

What this does: Calculates moderator temperature coefficient, or how core reactivity changes as a function of moderator (pool light water) temeprature. Produces a spreadsheet of values and a `.png` plot of it.

## Fuel temperature coefficient [rcty_fuel]

What this does: Calculates moderator temperature coefficient, or how core reactivity changes as a function of moderator (pool light water) temeprature.

## Void coefficient [rcty_void]

What this does: Calculates moderator temperature coefficient, or how core reactivity changes as a function of moderator (pool light water) temeprature.

## Heat Load (WIP)


# The Way This Thing Works:
Let's map out the file structure first. The basic items are:

./NeutronicsEngine.py
./Source/

NeutronicsEngine.py will be the main Python file you interact with to run this engine.

Inside ./Source/ there are:

./Source/Core
./Source/Fuel
./Source/Plot
./Source/Python
./Source/Tallies
reed.template

Let's go through these one-by-one.

# Folder `./Source/Core`

Inside ./Source/Core, there is the 49.core text file. It looks like this:

    c _____
    c Notes
    c use lower case 'c' to line comment and '$' to in-line comment
    c use '1070' for fuel element 10705
    c use '18' to make empty (water)
    c use '60' for AmBe source
    c use '70' for Ir-192 source
    c use '80' for graphite dummy
    c
    B1=7202
    B2=9678
    B3=9679
    B4=7946
    B5=7945
    B6=8104
    c
    C1=4086
    C2=4070

This is a text file in MCNP syntax. MCNP_File.py will read this file to learn what fuel elements to put in each grid position. 

So, to add a new core configuration, you just make a new file inside ./Source/Core, name it `50.core` or `1234abc.core` (alphanumeric only, no spaces), and swap out the fuel element IDs as necessary.

# Folder `./Source/Fuel`
MCNP_File.py then calls upon `Core Burnup History 20201117.xlsx` file here to calculate the most recently known mass fractions of isotopes in our fuel elements. 

# Folder `./Source/Python`

`Parameters.py` + `Utilities.py` -> `NeutronicsEngine.py` -> `MCNP_File.py` -> run-specific python file for processing





# FAQs: How can I do X?
<details>
    <summary> **Print a normal input deck** </summary>
</details>

<details>
    <summary> **Add a new core configuration** </summary>
</details>


