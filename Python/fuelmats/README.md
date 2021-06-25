## fuelmats: Python-automated creation of MCNP fuel material cards

Patrick Park | <ppark@reed.edu> | Physics '22 | Reed College

### Scope

This project involves a python wrapper (`fuelmats.py`) that:
1. calculates number fractions of uranium fuel isotopes from the Core Burnup History Excel files
2. prints MCNP material cards (`results.txt`)

### Procedure

We want to create MCNP materials cards with the following pseudocode syntax:
```
c
m{fe id} 92235.80c -{g U-235}  92238.80c -{g U-238}
         94249.80c -{g Pu-239}
         40000.80c -{g Zr}      1001.80c -{g H}
c
mt{fe id} h/zr.10t zr/h.10t
c
```
Note that the negative value indicates mass fraction. A positive value indicates atom fraction. Our Core Burnup datasheet provides exact masses of U-235, U-238, and Pu-239 in the fuel elements. By our Technical Specifications, 8.5 wt% of our fuel is uranium. So, we assume the uranium mass is composed of U-235, U-238, and Pu-239, and that the remainder of the element weight (91.5 wt%) is composed of ZrH. Using our TS value that our H:Zr ratio is 1.575 (halfway between the allowed 1.5 to 1.65 ratios), we derive the masses of H and Zr in each fuel element.

Essentially, we want `fuelmats.py` to produce `results.txt` that has such a materials card written for every fuel element in our inventory.

### Technical Notes
The TRIGA fuel elements contain uranium as a fine metallic dispersion in a ZrH matrix.

#### To-do Improvements

