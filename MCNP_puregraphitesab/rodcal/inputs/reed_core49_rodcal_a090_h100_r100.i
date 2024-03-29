1 Reed TRIGA (2021-06-19) - Core 49 - Run Type: rodcal - Printed: 2021-08-23 19:21:07
c    __   ___  ___  __      __   ___  __   ___       __   __           __   ___       __  ___  __   __  
c   |__) |__  |__  |  \    |__) |__  /__` |__   /\  |__) /  ` |__|    |__) |__   /\  /  `  |  /  \ |__) 
c   |  \ |___ |___ |__/    |  \ |___ .__/ |___ /--\ |  \ \__, |  |    |  \ |___ /--\ \__,  |  \__/ |  \
c
c
c   Reed Research Reactor TRIGA input deck
c   Created by Malcolm McCarthy, SRO, Physics '18 (malcolm@ande.site)
c   with help from Robert Shickler of Oregon State University
c 
c   Edited by Patrick Park, SRO, 3-2 Physics '23 (pjp2136@columbia.edu)
c   Last major update: Aug 21, 2021
c
c   ___________________________________
c   Guide to reading the RRR input deck 
c
c   __________
c   Cell Cards 
c
c
c      The cell card identifiers are five-digit numbers.  The first two digits represent a region of the model:
c        
c         10 - Voids
c         11 - Upper and lower grid plate cells
c         12 - Graphite reflector and rotary specimen rack cells
c         13 - Water cells
c         14 - Central thimble cells
c         15 - 
c         16 - 
c         17 - Rabbit and in core facility cells
c         18 - Control rod cells
c         19 - Misc/general
c
c      The last three numbers of the cell card identifiers are arbitrary.
c
c
c
c      Note: The fuel cell cards identifiers are different than the rest of the cells.  
c      Their identifiers are five-digit numbers, ABBCC.
c      The first digit, A, represents the ring (2 through 6 denoting A through F), and next two digits, BB, represents the hole in the ring.
c      The last two digits, CC, are arbitrary.
c
c
c   
c   _____________
c   Surface Cards
c
c   The surface card identifiers are six-digit numbers, AABCDD.
c   The first two digits, AA, represent a region of the model:
c
c
c      10 - Voids
c
c
c   The second two digits, BC, represent the type of surface card:
c
c      Number  B  C
c
c      1       c  x
c      2       p  y
c      3       k  z
c      4       s  o
c
c
c
c   For example, if a surface's middle two digits are 12, it is a cy surface.
c   This enables the user to identify what type of surface the card is without having to scroll to the bottom of the deck.  
c   Cylindrical surfaces centered at the origin are organized from smallest to largest.  
c   Generally, x, y, and z, surfaces are organized east to west, south to north, and top to bottom respectively   (vet this)
c
c
c   Note: The fuel surface cards are different than the rest of the surfaces.  
c   The first two digits are 90 to denote the in-core area, but the last four digits are different.  
c   The third, fourth, and fifth digit represent the grid location in the core, the third digit representing the ring, 
c   and the fifth representing the hole (holes less than ten will use a zero for the fourth digit).  
c   The sixth digit will represent a cylinder, 0 being the zirconium rod, 3 being the outside of the fuel/graphite, and 9 being the outside of the cladding.  
c
c
c
c
c   __________
c   Data Cards
c
c   Material card identifiers are three digit numbers counting sequentially from 101.  
c   Fuel materials are five digit numbers, AAAAB, The first four digits representing the fuel element's serial number, 
c   the next representing which of five axial segments (one at the bottom and five at the top).
c   There is one fuel element with a 3 digit serial number which has only AAAB with the same meaning
c
c
c
c
c
c
c
c
c   --- Malcom's TODO ---
c   core support structure
c   center channel assy/beam
c   tank 
c   multicelled fuel burnup model (*)
c   lower grid plate water flow holes
c   guide tube holes
c   fix guide tube taper
c   fuel card generator for streamlined core configuration management (*)
c   more accurate top and tip fitting geometry (*)
c   rabbit system holes 
c
c
c
c
c
c
c
c
c
c
c
c
c -------- REPLACEMENT SURFACES FOR UNIVERSE 3-DIG TRANSFORMED SURFACE RESTRICTIONS ---------  
c
c    112302  -> TO -> 10
c    132303  -> TO -> 11
c    192300  -> TO -> 20
c
c
c
c    ___________________________________________________________________
c    Major Deck Changes - tracked by Patrick (but intermittently, sorry)
c
c    2021-02-13
c    - Rewrote fuel mats with 2020 burnup data
c    - Consolidated invidual fuel meat section mat cards into one mat card for each FE
c    - Removed vol=77..096 argument from each fuel meat cell
c
c    2021-02-16
c    - Added fuel mat start/end markers
c
c    2021-06-14
c    - Changed AmBe and Ir-192 cells from hard-coded cells to fill universes (fill = 60, 70, respectively)
c
c    2021-06-19
c    - Changed from 1 to 5 KSRC points per core position at mid-plane of each fuel meat axial zone
c    - Changed from averaged (5..66 g/cc) to unique (avg = 5..78 g/cc) fuel meat densities for every FE based 
c      on Core Burnup spreadsheet
c    - Control rod B4C densities changed from 1..72066 to 1..806693 (reverting the 5% depletion modeled by OSU in 2010)
c      as that depletion approximation was based on OSU experiments of the OSTR core, not the RRR core
c
c    2021-08-08
c    - Added Sm-149 to fuel mat cards based on poison formula (1 Sm-149 atom per 6880 U-235 atoms)
c
c    2021-08-09
c    - Re-added 5 at% depletion and 15 % radius reduction of control rod B4C 
c
c    2021-08-12
c    - Fixed graphite density from 1..53 to 1..698 - original densities had been decreased by OSU in lieu of cladding, which is now modeled
c
c    2021-08-15
c    - B4C: change density from 1..8122 to 1..80772 and change radius from 1..53 to 1..52112
c
c    2021-08-21
c    - Upgraded to ENDF8 xs and SaB libs
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c -----------------------------------------------------------------------------
c ---------------------------- CELL CARDS -------------------------------------
c -----------------------------------------------------------------------------
c --Begin Cells-- $ for NIST MCNP syntax
c
c
c
c ------------------------------
c -------- Core config ---------
c ------------------------------
c
c ------ fill = empty: 2, water: 18, AmBe: 60, Ir-192: 70, graphite: 80, fuel element: FE ID
c
c B ring
201 0 10 -11 -20 trcl=(0.00000  4.05384 0)      imp:n=1 fill=7202 $  
202 0 10 -11 -20 trcl=(3.51053  2.02692 0)      imp:n=1 fill=9678 $  
203 0 10 -11 -20 trcl=(3.51053 -2.02692 0)      imp:n=1 fill=9679 $  
204 0 10 -11 -20 trcl=( 0.00000 -4.05384 0)     imp:n=1 fill=7946 $  
205 0 10 -11 -20 trcl=(-3.51053 -2.02692 0)     imp:n=1 fill=7945 $  
206 0 10 -11 -20 trcl=(-3.51053  2.02692 0)     imp:n=1 fill=8104 $  
c
c C ring
301 0 10 -11 -20 trcl=( 0.00000  7.98068 0)     imp:n=1 fill=4086 $  
302 0 10 -11 -20 trcl=( 3.99034  6.91134 0)     imp:n=1 fill=4070 $  
303 0 10 -11 -20 trcl=( 6.91134  3.99034 0)     imp:n=1 fill=8102 $  
304 0 10 -11 -20 trcl=( 7.98068  0.00000 0)     imp:n=1 fill=3856 $ 
c safe rod 
306 0 10 -11 -20 trcl=( 3.99034 -6.91134 0)     imp:n=1 fill=8103 $  
307 0 10 -11 -20 trcl=( 0.00000 -7.98068 0)     imp:n=1 fill=4117 $  
308 0 10 -11 -20 trcl=(-3.99034 -6.91134 0)     imp:n=1 fill=8105 $ 
c shim rod 
310 0 10 -11 -20 trcl=(-7.98068  0.00000 0)     imp:n=1 fill=8736 $  
311 0 10 -11 -20 trcl=(-6.91130  3.99030 0)     imp:n=1 fill=8735 $  
312 0 10 -11 -20 trcl=(-3.99030  6.91130 0)     imp:n=1 fill=1070 $  
c
c D ring
401 0 10 -11 -20 trcl=( 0.00000  11.9456 0)     imp:n=1 fill=3679 $  
402 0 10 -11 -20 trcl=( 4.08530  11.2253 0)     imp:n=1 fill=8732 $  
403 0 10 -11 -20 trcl=( 7.67870  9.15040 0)     imp:n=1 fill=4103 $  
404 0 10 -11 -20 trcl=( 10.3449  5.97280 0)     imp:n=1 fill=8734 $  
405 0 10 -11 -20 trcl=( 11.7640  2.07370 0)     imp:n=1 fill=3685 $  
406 0 10 -11 -20 trcl=( 11.7640 -2.07370 0)     imp:n=1 fill=4095 $  
407 0 10 -11 -20 trcl=( 10.3449 -5.97280 0)     imp:n=1 fill=4104 $  
408 0 10 -11 -20 trcl=( 7.67870 -9.15040 0)     imp:n=1 fill=4054 $  
409 0 10 -11 -20 trcl=( 4.08530 -11.2253 0)     imp:n=1 fill=4118 $  
410 0 10 -11 -20 trcl=( 0.00000 -11.9456 0)     imp:n=1 fill=3677 $  
411 0 10 -11 -20 trcl=(-4.08530 -11.2253 0)     imp:n=1 fill=4131 $  
412 0 10 -11 -20 trcl=(-7.67870 -9.15040 0)     imp:n=1 fill=4065 $  
413 0 10 -11 -20 trcl=(-10.3449 -5.97280 0)     imp:n=1 fill=3851 $  
414 0 10 -11 -20 trcl=(-11.7640 -2.07370 0)     imp:n=1 fill=3866 $  
415 0 10 -11 -20 trcl=(-11.7640  2.07370 0)     imp:n=1 fill=8733 $  
416 0 10 -11 -20 trcl=(-10.3449  5.97280 0)     imp:n=1 fill=4094 $  
417 0 10 -11 -20 trcl=(-7.67870  9.15040 0)     imp:n=1 fill=4129 $  
418 0 10 -11 -20 trcl=(-4.08530  11.2253 0)     imp:n=1 fill=3874 $  
c
c E ring
c reg rod ( 0.0000000  15.915600 0)
502 0 10 -11 -20 trcl=( 4.1189000  15.372800 0) imp:n=1 fill=3872 $  
503 0 10 -11 -20 trcl=( 7.9578000  13.782800 0) imp:n=1 fill=4106 $  
504 0 10 -11 -20 trcl=( 11.254000  11.254000 0) imp:n=1 fill=3671 $  
505 0 10 -11 -20 trcl=( 13.874200  7.9578000 0) imp:n=1 fill=4062 $  
506 0 10 -11 -20 trcl=( 15.372800  4.1189000 0) imp:n=1 fill=4121 $  
507 0 10 -11 -20 trcl=( 15.915600  0.0000000 0) imp:n=1 fill=4114 $  
508 0 10 -11 -20 trcl=( 15.372800 -4.1189000 0) imp:n=1 fill=4077 $  
509 0 10 -11 -20 trcl=( 13.874200 -7.9578000 0) imp:n=1 fill=3674 $  
510 0 10 -11 -20 trcl=( 11.254000 -11.254000 0) imp:n=1 fill=4071 $  
511 0 10 -11 -20 trcl=( 7.9578000 -13.782800 0) imp:n=1 fill=4122 $  
512 0 10 -11 -20 trcl=( 4.1189000 -15.372800 0) imp:n=1 fill=4083 $  
513 0 10 -11 -20 trcl=( 0.0000000 -15.915600 0) imp:n=1 fill=3853 $  
514 0 10 -11 -20 trcl=(-4.1189000 -15.372800 0) imp:n=1 fill=4134 $  
515 0 10 -11 -20 trcl=(-7.9578000 -13.782800 0) imp:n=1 fill=4133 $  
516 0 10 -11 -20 trcl=(-11.254000 -11.254000 0) imp:n=1 fill=4085 $  
517 0 10 -11 -20 trcl=(-13.874200 -7.9578000 0) imp:n=1 fill=4110 $  
518 0 10 -11 -20 trcl=(-15.372800 -4.1189000 0) imp:n=1 fill=4055 $  
519 0 10 -11 -20 trcl=(-15.915600  0.0000000 0) imp:n=1 fill=3862 $  
520 0 10 -11 -20 trcl=(-15.372800  4.1189000 0) imp:n=1 fill=4064 $  
521 0 10 -11 -20 trcl=(-13.874200  7.9578000 0) imp:n=1 fill=3858 $  
522 0 10 -11 -20 trcl=(-11.254000  11.254000 0) imp:n=1 fill=4053 $  
523 0 10 -11 -20 trcl=(-7.9578000  13.782800 0) imp:n=1 fill=3748 $  
524 0 10 -11 -20 trcl=(-4.1189000  15.372800 0) imp:n=1 fill=3852 $  
c
c F ring
601 0 10 -11 -20 trcl=( 0.0000000  19.888200 0) imp:n=1 fill=4057 $  
602 0 10 -11 -20 trcl=( 4.1348660  19.452590 0) imp:n=1 fill=4125 $  
603 0 10 -11 -20 trcl=( 8.0886300  18.157860 0) imp:n=1 fill=4074 $  
604 0 10 -11 -20 trcl=( 11.690350  16.089630 0) imp:n=1 fill=4069 $  
605 0 10 -11 -20 trcl=( 14.778990  13.307314 0) imp:n=1 fill=4088 $  
606 0 10 -11 -20 trcl=( 17.223232  9.9441000 0) imp:n=1 fill=80 $  
607 0 10 -11 -20 trcl=( 18.915634  6.1455300 0) imp:n=1 fill=3868 $  
608 0 10 -11 -20 trcl=( 19.777202  2.0706080 0) imp:n=1 fill=4120 $  
c rabbit ( 19.777202 -2.0706080 0)
610 0 10 -11 -20 trcl=( 18.915634 -6.1455300 0) imp:n=1 fill=80 $  
611 0 10 -11 -20 trcl=( 17.223232 -9.9441000 0) imp:n=1 fill=80 $  
612 0 10 -11 -20 trcl=( 14.778990 -13.307314 0) imp:n=1 fill=80 $  
613 0 10 -11 -20 trcl=( 11.690350 -16.089630 0) imp:n=1 fill=80 $  
614 0 10 -11 -20 trcl=( 8.0886300 -18.167858 0) imp:n=1 fill=3810 $  
615 0 10 -11 -20 trcl=( 4.1348660 -19.452590 0) imp:n=1 fill=4130 $  
616 0 10 -11 -20 trcl=( 0.0000000 -19.888200 0) imp:n=1 fill=4091 $  
617 0 10 -11 -20 trcl=(-4.1348660 -19.452590 0) imp:n=1 fill=3673 $  
618 0 10 -11 -20 trcl=(-8.0886300 -18.167858 0) imp:n=1 fill=3682 $  
619 0 10 -11 -20 trcl=(-11.690350 -16.089630 0) imp:n=1 fill=4132 $  
620 0 10 -11 -20 trcl=(-14.778990 -13.307314 0) imp:n=1 fill=4046 $  
621 0 10 -11 -20 trcl=(-17.223232 -9.9441000 0) imp:n=1 fill=3865 $  
622 0 10 -11 -20 trcl=(-18.915634 -6.1455300 0) imp:n=1 fill=3743 $  
623 0 10 -11 -20 trcl=(-19.777202 -2.0706080 0) imp:n=1 fill=60 $  
624 0 10 -11 -20 trcl=(-19.777202  2.0706080 0) imp:n=1 fill=3835 $  
625 0 10 -11 -20 trcl=(-18.915634  6.1455300 0) imp:n=1 fill=70 $  
626 0 10 -11 -20 trcl=(-17.223232  9.9441000 0) imp:n=1 fill=3676 $  
627 0 10 -11 -20 trcl=(-14.778990  13.307314 0) imp:n=1 fill=3840 $  
628 0 10 -11 -20 trcl=(-11.690350  16.089630 0) imp:n=1 fill=3854 $  
629 0 10 -11 -20 trcl=(-8.0886300  18.167858 0) imp:n=1 fill=4049 $  
630 0 10 -11 -20 trcl=(-4.1348660  19.452590 0) imp:n=1 fill=4127 $  
c
c
c
c
c
c
c
c
c ------------------------------
c --------- Universes ---------- TODO
c ------------------------------
c
c
c Graphite element (TOS210D120) universe
c
8001  104  -2.70     312300 -312301 -311302          imp:n=1 u=80  $ Lower grid plate pin
8002  102  -0.997903     312300 -312301  311302 -311306  imp:n=1 u=80 tmp=2.526170e-08 $ Water around lower grid plate pin
8003  104  -2.70     312301 -312302 -311305          imp:n=1 u=80  $ Bottom casing 
8004  102  -0.997903     312301 -312306  311305 -311306  imp:n=1 u=80 tmp=2.526170e-08 $ Water around element
8005  106  -1.698     312302 -312305 -311304          imp:n=1 u=80  $ Graphite slug
8006  104  -2.70     312302 -312305  311304 -311305  imp:n=1 u=80  $ Element cladding
8007  104  -2.70     312305 -312306 -311305          imp:n=1 u=80  $ SS top cap
8008  104  -2.70     312306 -312307 -311303          imp:n=1 u=80  $ Tri-flute
8009  102  -0.997903     312306 -312307  311303 -311306  imp:n=1 u=80 tmp=2.526170e-08 $ Water around tri-flute
8010  104  -2.70     312307 -312308 -311302          imp:n=1 u=80  $ Element tip
8011  102  -0.997903     312307 -312308  311302 -311306  imp:n=1 u=80 tmp=2.526170e-08 $ Water around tip
8012  102  -0.997903     312308 -312309 -311306          imp:n=1 u=80 tmp=2.526170e-08 $ Water above element
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c The following are universes based on 31X3XX surfaces defined in 'Fuel Surfaces' section
c 
c 
c TOS210D210 refers to the GA drawing number
c
c --- 18 - water universe ---
c
1801 102 -0.997903     312300 -312301 -311302          imp:n=1 u=18   tmp=2.526170e-08 $ Lower grid plate pin
1802 102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=18   tmp=2.526170e-08 $ Water around grid plate pin 
1803 102 -0.997903     312301 -312302 -311305          imp:n=1 u=18   tmp=2.526170e-08 $ Bottom casing 
1804 102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=18   tmp=2.526170e-08 $ Water around fuel element
1805 102 -0.997903     312302 -312303 -311304          imp:n=1 u=18   tmp=2.526170e-08 $ Lower graphite slug 
1806 102 -0.997903     312302 -312305  311304 -311305  imp:n=1 u=18   tmp=2.526170e-08 $ Fuel cladding
1807 102 -0.997903     312303 -312304 -311301          imp:n=1 u=18   tmp=2.526170e-08 $ Zirc pin 
1808 102 -0.997903     312303 -302303  311301 -311304   imp:n=1 u=18  tmp=2.526170e-08 $ Fuel meat section 1
1809 102 -0.997903     302303 -302306  311301 -311304   imp:n=1 u=18  tmp=2.526170e-08 $ Fuel meat section 2
1810 102 -0.997903     302306 -302309  311301 -311304   imp:n=1 u=18  tmp=2.526170e-08 $ Fuel meat section 3
1811 102 -0.997903     302309 -302312  311301 -311304   imp:n=1 u=18  tmp=2.526170e-08 $ Fuel meat section 4
1812 102 -0.997903     302312 -312304  311301 -311304   imp:n=1 u=18  tmp=2.526170e-08 $ Fuel meat section 5
1813 102 -0.997903     312304 -312305 -311304          imp:n=1 u=18   tmp=2.526170e-08 $ Upper graphite spacer
1814 102 -0.997903     312305 -312306 -311305          imp:n=1 u=18   tmp=2.526170e-08 $ SS top cap 
1815 102 -0.997903     312306 -312307 -311303          imp:n=1 u=18   tmp=2.526170e-08 $ Tri-flute 
1816 102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=18   tmp=2.526170e-08 $ Water around tri-flute 
1817 102 -0.997903     312307 -312308 -311302          imp:n=1 u=18   tmp=2.526170e-08 $ Fuel tip
1818 102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=18   tmp=2.526170e-08 $ Water around fuel tip
1819 102 -0.997903     312308 -312309 -311306          imp:n=1 u=18   tmp=2.526170e-08 $ Water above fuel element
c
c
c
c --Begin Fuel Cells--                   
c fuel meat density auto-generated from 'Core Burnup History 20201117.xlsx'                   
c calculated fuel active section volume = 387.771296 cm^3 
c average fuel meat density = 5.779214 g/cm^3                     
c                     
c
c --- 7202 - SS clad (TOS210C219) universe --- 
c                         
720201   105 -7.85     312300 -312301 -311302          imp:n=1 u=7202  $ Lower grid plate pin                         
720202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=7202  tmp=2.526170e-08 $ Water around grid plate pin                       
720203   105 -7.85     312301 -312302 -311305          imp:n=1 u=7202  $ Bottom casing                          
720204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=7202  tmp=2.526170e-08 $ Water around fuel element                         
720205   106 -1.698     312302 -312303 -311304          imp:n=1 u=7202  $ Lower graphite slug                          
720206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=7202  $ Fuel cladding                         
720207   108  0.042234 312303 -312304 -311301          imp:n=1 u=7202  tmp=2.533494e-08 $ Zirc pin                          
720208  7202 -5.821543 312303 -302303  311301 -311304  imp:n=1 u=7202  tmp=2.533494e-08 $ Fuel meat section 1                         
720209  7202 -5.821543 302303 -302306  311301 -311304  imp:n=1 u=7202  tmp=2.533494e-08 $ Fuel meat section 2                         
720210  7202 -5.821543 302306 -302309  311301 -311304  imp:n=1 u=7202  tmp=2.533494e-08 $ Fuel meat section 3                         
720211  7202 -5.821543 302309 -302312  311301 -311304  imp:n=1 u=7202  tmp=2.533494e-08 $ Fuel meat section 4                         
720212  7202 -5.821543 302312 -312304  311301 -311304  imp:n=1 u=7202  tmp=2.533494e-08 $ Fuel meat section 5                         
720213   106 -1.698     312304 -312305 -311304          imp:n=1 u=7202  $ Upper graphite spacer                         
720214   105 -7.85     312305 -312306 -311305          imp:n=1 u=7202  $ SS top cap                          
720215   105 -7.85     312306 -312307 -311303          imp:n=1 u=7202  $ Tri-flute                          
720216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=7202  tmp=2.526170e-08 $ Water around tri-flute                          
720217   105 -7.85     312307 -312308 -311302          imp:n=1 u=7202  $ Fuel tip                         
720218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=7202  tmp=2.526170e-08 $ Water around fuel tip                         
720219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=7202  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 7945 - SS clad (TOS210D210R) universe --- 
c                         
794501   105 -7.85     312300 -312301 -311302          imp:n=1 u=7945  $ Lower grid plate pin                         
794502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=7945  tmp=2.526170e-08 $ Water around grid plate pin                          
794503   105 -7.85     312301 -312302 -311305          imp:n=1 u=7945  $ Bottom casing                          
794504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=7945  tmp=2.526170e-08 $ Water around fuel element                         
794505   106 -1.698     312302 -312303 -311304          imp:n=1 u=7945  $ Lower graphite slug                          
794506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=7945  $ Fuel cladding                         
794507   108  0.042234 312303 -312304 -311301          imp:n=1 u=7945  tmp=2.533494e-08 $ Zirc pin                          
794508  7945 -5.761246 312303 -302303  311301 -311304  imp:n=1 u=7945  tmp=2.533494e-08 $ Fuel meat section 1                         
794509  7945 -5.761246 302303 -302306  311301 -311304  imp:n=1 u=7945  tmp=2.533494e-08 $ Fuel meat section 2                         
794510  7945 -5.761246 302306 -302309  311301 -311304  imp:n=1 u=7945  tmp=2.533494e-08 $ Fuel meat section 3                         
794511  7945 -5.761246 302309 -302312  311301 -311304  imp:n=1 u=7945  tmp=2.533494e-08 $ Fuel meat section 4                         
794512  7945 -5.761246 302312 -312304  311301 -311304  imp:n=1 u=7945  tmp=2.533494e-08 $ Fuel meat section 5                         
794513   106 -1.698     312304 -312305 -311304          imp:n=1 u=7945  $ Upper graphite spacer                         
794514   105 -7.85     312305 -312306 -311305          imp:n=1 u=7945  $ SS top cap                          
794515   105 -7.85     312306 -312307 -311303          imp:n=1 u=7945  $ Tri-flute                          
794516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=7945  tmp=2.526170e-08 $ Water around tri-flute                          
794517   105 -7.85     312307 -312308 -311302          imp:n=1 u=7945  $ Fuel tip                         
794518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=7945  tmp=2.526170e-08 $ Water around fuel tip                         
794519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=7945  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 7946 - SS clad (TOS210D210R) universe --- 
c                         
794601   105 -7.85     312300 -312301 -311302          imp:n=1 u=7946  $ Lower grid plate pin                         
794602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=7946  tmp=2.526170e-08 $ Water around grid plate pin                          
794603   105 -7.85     312301 -312302 -311305          imp:n=1 u=7946  $ Bottom casing                          
794604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=7946  tmp=2.526170e-08 $ Water around fuel element                         
794605   106 -1.698     312302 -312303 -311304          imp:n=1 u=7946  $ Lower graphite slug                          
794606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=7946  $ Fuel cladding                         
794607   108  0.042234 312303 -312304 -311301          imp:n=1 u=7946  tmp=2.533494e-08 $ Zirc pin                          
794608  7946 -5.730713 312303 -302303  311301 -311304  imp:n=1 u=7946  tmp=2.533494e-08 $ Fuel meat section 1                         
794609  7946 -5.730713 302303 -302306  311301 -311304  imp:n=1 u=7946  tmp=2.533494e-08 $ Fuel meat section 2                         
794610  7946 -5.730713 302306 -302309  311301 -311304  imp:n=1 u=7946  tmp=2.533494e-08 $ Fuel meat section 3                         
794611  7946 -5.730713 302309 -302312  311301 -311304  imp:n=1 u=7946  tmp=2.533494e-08 $ Fuel meat section 4                         
794612  7946 -5.730713 302312 -312304  311301 -311304  imp:n=1 u=7946  tmp=2.533494e-08 $ Fuel meat section 5                         
794613   106 -1.698     312304 -312305 -311304          imp:n=1 u=7946  $ Upper graphite spacer                         
794614   105 -7.85     312305 -312306 -311305          imp:n=1 u=7946  $ SS top cap                          
794615   105 -7.85     312306 -312307 -311303          imp:n=1 u=7946  $ Tri-flute                          
794616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=7946  tmp=2.526170e-08 $ Water around tri-flute                          
794617   105 -7.85     312307 -312308 -311302          imp:n=1 u=7946  $ Fuel tip                         
794618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=7946  tmp=2.526170e-08 $ Water around fuel tip                         
794619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=7946  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8102 - SS clad (TOS210D210R) universe --- 
c                         
810201   105 -7.85     312300 -312301 -311302          imp:n=1 u=8102  $ Lower grid plate pin                         
810202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8102  tmp=2.526170e-08 $ Water around grid plate pin                          
810203   105 -7.85     312301 -312302 -311305          imp:n=1 u=8102  $ Bottom casing                          
810204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8102  tmp=2.526170e-08 $ Water around fuel element                         
810205   106 -1.698     312302 -312303 -311304          imp:n=1 u=8102  $ Lower graphite slug                          
810206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8102  $ Fuel cladding                         
810207   108  0.042234 312303 -312304 -311301          imp:n=1 u=8102  tmp=2.533494e-08 $ Zirc pin                          
810208  8102 -5.777895 312303 -302303  311301 -311304  imp:n=1 u=8102  tmp=2.533494e-08 $ Fuel meat section 1                         
810209  8102 -5.777895 302303 -302306  311301 -311304  imp:n=1 u=8102  tmp=2.533494e-08 $ Fuel meat section 2                         
810210  8102 -5.777895 302306 -302309  311301 -311304  imp:n=1 u=8102  tmp=2.533494e-08 $ Fuel meat section 3                         
810211  8102 -5.777895 302309 -302312  311301 -311304  imp:n=1 u=8102  tmp=2.533494e-08 $ Fuel meat section 4                         
810212  8102 -5.777895 302312 -312304  311301 -311304  imp:n=1 u=8102  tmp=2.533494e-08 $ Fuel meat section 5                         
810213   106 -1.698     312304 -312305 -311304          imp:n=1 u=8102  $ Upper graphite spacer                         
810214   105 -7.85     312305 -312306 -311305          imp:n=1 u=8102  $ SS top cap                          
810215   105 -7.85     312306 -312307 -311303          imp:n=1 u=8102  $ Tri-flute                          
810216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8102  tmp=2.526170e-08 $ Water around tri-flute                          
810217   105 -7.85     312307 -312308 -311302          imp:n=1 u=8102  $ Fuel tip                         
810218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8102  tmp=2.526170e-08 $ Water around fuel tip                         
810219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8102  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8103 - SS clad (TOS210D210R) universe --- 
c                         
810301   105 -7.85     312300 -312301 -311302          imp:n=1 u=8103  $ Lower grid plate pin                         
810302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8103  tmp=2.526170e-08 $ Water around grid plate pin                          
810303   105 -7.85     312301 -312302 -311305          imp:n=1 u=8103  $ Bottom casing                          
810304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8103  tmp=2.526170e-08 $ Water around fuel element                         
810305   106 -1.698     312302 -312303 -311304          imp:n=1 u=8103  $ Lower graphite slug                          
810306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8103  $ Fuel cladding                         
810307   108  0.042234 312303 -312304 -311301          imp:n=1 u=8103  tmp=2.533494e-08 $ Zirc pin                          
810308  8103 -5.777895 312303 -302303  311301 -311304  imp:n=1 u=8103  tmp=2.533494e-08 $ Fuel meat section 1                         
810309  8103 -5.777895 302303 -302306  311301 -311304  imp:n=1 u=8103  tmp=2.533494e-08 $ Fuel meat section 2                         
810310  8103 -5.777895 302306 -302309  311301 -311304  imp:n=1 u=8103  tmp=2.533494e-08 $ Fuel meat section 3                         
810311  8103 -5.777895 302309 -302312  311301 -311304  imp:n=1 u=8103  tmp=2.533494e-08 $ Fuel meat section 4                         
810312  8103 -5.777895 302312 -312304  311301 -311304  imp:n=1 u=8103  tmp=2.533494e-08 $ Fuel meat section 5                         
810313   106 -1.698     312304 -312305 -311304          imp:n=1 u=8103  $ Upper graphite spacer                         
810314   105 -7.85     312305 -312306 -311305          imp:n=1 u=8103  $ SS top cap                          
810315   105 -7.85     312306 -312307 -311303          imp:n=1 u=8103  $ Tri-flute                          
810316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8103  tmp=2.526170e-08 $ Water around tri-flute                          
810317   105 -7.85     312307 -312308 -311302          imp:n=1 u=8103  $ Fuel tip                         
810318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8103  tmp=2.526170e-08 $ Water around fuel tip                         
810319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8103  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8104 - SS clad (TOS210D210R) universe --- 
c                         
810401   105 -7.85     312300 -312301 -311302          imp:n=1 u=8104  $ Lower grid plate pin                         
810402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8104  tmp=2.526170e-08 $ Water around grid plate pin                          
810403   105 -7.85     312301 -312302 -311305          imp:n=1 u=8104  $ Bottom casing                          
810404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8104  tmp=2.526170e-08 $ Water around fuel element                         
810405   106 -1.698     312302 -312303 -311304          imp:n=1 u=8104  $ Lower graphite slug                          
810406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8104  $ Fuel cladding                         
810407   108  0.042234 312303 -312304 -311301          imp:n=1 u=8104  tmp=2.533494e-08 $ Zirc pin                          
810408  8104 -5.777737 312303 -302303  311301 -311304  imp:n=1 u=8104  tmp=2.533494e-08 $ Fuel meat section 1                         
810409  8104 -5.777737 302303 -302306  311301 -311304  imp:n=1 u=8104  tmp=2.533494e-08 $ Fuel meat section 2                         
810410  8104 -5.777737 302306 -302309  311301 -311304  imp:n=1 u=8104  tmp=2.533494e-08 $ Fuel meat section 3                         
810411  8104 -5.777737 302309 -302312  311301 -311304  imp:n=1 u=8104  tmp=2.533494e-08 $ Fuel meat section 4                         
810412  8104 -5.777737 302312 -312304  311301 -311304  imp:n=1 u=8104  tmp=2.533494e-08 $ Fuel meat section 5                         
810413   106 -1.698     312304 -312305 -311304          imp:n=1 u=8104  $ Upper graphite spacer                         
810414   105 -7.85     312305 -312306 -311305          imp:n=1 u=8104  $ SS top cap                          
810415   105 -7.85     312306 -312307 -311303          imp:n=1 u=8104  $ Tri-flute                          
810416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8104  tmp=2.526170e-08 $ Water around tri-flute                          
810417   105 -7.85     312307 -312308 -311302          imp:n=1 u=8104  $ Fuel tip                         
810418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8104  tmp=2.526170e-08 $ Water around fuel tip                         
810419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8104  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8105 - SS clad (TOS210D210R) universe --- 
c                         
810501   105 -7.85     312300 -312301 -311302          imp:n=1 u=8105  $ Lower grid plate pin                         
810502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8105  tmp=2.526170e-08 $ Water around grid plate pin                          
810503   105 -7.85     312301 -312302 -311305          imp:n=1 u=8105  $ Bottom casing                          
810504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8105  tmp=2.526170e-08 $ Water around fuel element                         
810505   106 -1.698     312302 -312303 -311304          imp:n=1 u=8105  $ Lower graphite slug                          
810506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8105  $ Fuel cladding                         
810507   108  0.042234 312303 -312304 -311301          imp:n=1 u=8105  tmp=2.533494e-08 $ Zirc pin                          
810508  8105 -5.777907 312303 -302303  311301 -311304  imp:n=1 u=8105  tmp=2.533494e-08 $ Fuel meat section 1                         
810509  8105 -5.777907 302303 -302306  311301 -311304  imp:n=1 u=8105  tmp=2.533494e-08 $ Fuel meat section 2                         
810510  8105 -5.777907 302306 -302309  311301 -311304  imp:n=1 u=8105  tmp=2.533494e-08 $ Fuel meat section 3                         
810511  8105 -5.777907 302309 -302312  311301 -311304  imp:n=1 u=8105  tmp=2.533494e-08 $ Fuel meat section 4                         
810512  8105 -5.777907 302312 -312304  311301 -311304  imp:n=1 u=8105  tmp=2.533494e-08 $ Fuel meat section 5                         
810513   106 -1.698     312304 -312305 -311304          imp:n=1 u=8105  $ Upper graphite spacer                         
810514   105 -7.85     312305 -312306 -311305          imp:n=1 u=8105  $ SS top cap                          
810515   105 -7.85     312306 -312307 -311303          imp:n=1 u=8105  $ Tri-flute                          
810516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8105  tmp=2.526170e-08 $ Water around tri-flute                          
810517   105 -7.85     312307 -312308 -311302          imp:n=1 u=8105  $ Fuel tip                         
810518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8105  tmp=2.526170e-08 $ Water around fuel tip                         
810519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8105  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 9678 - SS clad (TOS210D210R) universe --- 
c                         
967801   105 -7.85     312300 -312301 -311302          imp:n=1 u=9678  $ Lower grid plate pin                         
967802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=9678  tmp=2.526170e-08 $ Water around grid plate pin                          
967803   105 -7.85     312301 -312302 -311305          imp:n=1 u=9678  $ Bottom casing                          
967804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=9678  tmp=2.526170e-08 $ Water around fuel element                         
967805   106 -1.698     312302 -312303 -311304          imp:n=1 u=9678  $ Lower graphite slug                          
967806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=9678  $ Fuel cladding                         
967807   108  0.042234 312303 -312304 -311301          imp:n=1 u=9678  tmp=2.533494e-08 $ Zirc pin                          
967808  9678 -5.700371 312303 -302303  311301 -311304  imp:n=1 u=9678  tmp=2.533494e-08 $ Fuel meat section 1                         
967809  9678 -5.700371 302303 -302306  311301 -311304  imp:n=1 u=9678  tmp=2.533494e-08 $ Fuel meat section 2                         
967810  9678 -5.700371 302306 -302309  311301 -311304  imp:n=1 u=9678  tmp=2.533494e-08 $ Fuel meat section 3                         
967811  9678 -5.700371 302309 -302312  311301 -311304  imp:n=1 u=9678  tmp=2.533494e-08 $ Fuel meat section 4                         
967812  9678 -5.700371 302312 -312304  311301 -311304  imp:n=1 u=9678  tmp=2.533494e-08 $ Fuel meat section 5                         
967813   106 -1.698     312304 -312305 -311304          imp:n=1 u=9678  $ Upper graphite spacer                         
967814   105 -7.85     312305 -312306 -311305          imp:n=1 u=9678  $ SS top cap                          
967815   105 -7.85     312306 -312307 -311303          imp:n=1 u=9678  $ Tri-flute                          
967816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=9678  tmp=2.526170e-08 $ Water around tri-flute                          
967817   105 -7.85     312307 -312308 -311302          imp:n=1 u=9678  $ Fuel tip                         
967818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=9678  tmp=2.526170e-08 $ Water around fuel tip                         
967819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=9678  tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 9679 - SS clad (TOS210D210R) universe --- 
c                         
967901   105 -7.85     312300 -312301 -311302          imp:n=1 u=9679  $ Lower grid plate pin                         
967902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=9679 tmp=2.526170e-08 $ Water around grid plate pin                          
967903   105 -7.85     312301 -312302 -311305          imp:n=1 u=9679  $ Bottom casing                          
967904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=9679 tmp=2.526170e-08 $ Water around fuel element                         
967905   106 -1.698     312302 -312303 -311304          imp:n=1 u=9679  $ Lower graphite slug                          
967906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=9679  $ Fuel cladding                         
967907   108  0.042234 312303 -312304 -311301          imp:n=1 u=9679  tmp=2.533494e-08 $ Zirc pin                          
967908  9679 -5.704919 312303 -302303  311301 -311304  imp:n=1 u=9679  tmp=2.533494e-08 $ Fuel meat section 1                         
967909  9679 -5.704919 302303 -302306  311301 -311304  imp:n=1 u=9679  tmp=2.533494e-08 $ Fuel meat section 2                         
967910  9679 -5.704919 302306 -302309  311301 -311304  imp:n=1 u=9679  tmp=2.533494e-08 $ Fuel meat section 3                         
967911  9679 -5.704919 302309 -302312  311301 -311304  imp:n=1 u=9679  tmp=2.533494e-08 $ Fuel meat section 4                         
967912  9679 -5.704919 302312 -312304  311301 -311304  imp:n=1 u=9679  tmp=2.533494e-08 $ Fuel meat section 5                         
967913   106 -1.698     312304 -312305 -311304          imp:n=1 u=9679  $ Upper graphite spacer                         
967914   105 -7.85     312305 -312306 -311305          imp:n=1 u=9679  $ SS top cap                          
967915   105 -7.85     312306 -312307 -311303          imp:n=1 u=9679  $ Tri-flute                          
967916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=9679 tmp=2.526170e-08 $ Water around tri-flute                          
967917   105 -7.85     312307 -312308 -311302          imp:n=1 u=9679  $ Fuel tip                         
967918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=9679 tmp=2.526170e-08 $ Water around fuel tip                         
967919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=9679 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 10705 - SS clad (TOS210D210R) universe --- 
c                         
107001   105 -7.85     312300 -312301 -311302          imp:n=1 u=1070  $ Lower grid plate pin                         
107002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=1070 tmp=2.526170e-08 $ Water around grid plate pin                          
107003   105 -7.85     312301 -312302 -311305          imp:n=1 u=1070  $ Bottom casing                          
107004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=1070 tmp=2.526170e-08 $ Water around fuel element                         
107005   106 -1.698     312302 -312303 -311304          imp:n=1 u=1070  $ Lower graphite slug                          
107006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=1070  $ Fuel cladding                         
107007   108  0.042234 312303 -312304 -311301          imp:n=1 u=1070  tmp=2.533494e-08 $ Zirc pin                          
107008  1070 -5.781268 312303 -302303  311301 -311304  imp:n=1 u=1070  tmp=2.533494e-08 $ Fuel meat section 1                         
107009  1070 -5.781268 302303 -302306  311301 -311304  imp:n=1 u=1070  tmp=2.533494e-08 $ Fuel meat section 2                         
107010  1070 -5.781268 302306 -302309  311301 -311304  imp:n=1 u=1070  tmp=2.533494e-08 $ Fuel meat section 3                         
107011  1070 -5.781268 302309 -302312  311301 -311304  imp:n=1 u=1070  tmp=2.533494e-08 $ Fuel meat section 4                         
107012  1070 -5.781268 302312 -312304  311301 -311304  imp:n=1 u=1070  tmp=2.533494e-08 $ Fuel meat section 5                         
107013   106 -1.698     312304 -312305 -311304          imp:n=1 u=1070  $ Upper graphite spacer                         
107014   105 -7.85     312305 -312306 -311305          imp:n=1 u=1070  $ SS top cap                          
107015   105 -7.85     312306 -312307 -311303          imp:n=1 u=1070  $ Tri-flute                          
107016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=1070 tmp=2.526170e-08 $ Water around tri-flute                          
107017   105 -7.85     312307 -312308 -311302          imp:n=1 u=1070  $ Fuel tip                         
107018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=1070 tmp=2.526170e-08 $ Water around fuel tip                         
107019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=1070 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3671 - SS clad (T0S210D210) universe --- 
c                         
367101   105 -7.85     312300 -312301 -311302          imp:n=1 u=3671  $ Lower grid plate pin                         
367102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3671 tmp=2.526170e-08 $ Water around grid plate pin                          
367103   105 -7.85     312301 -312302 -311305          imp:n=1 u=3671  $ Bottom casing                          
367104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3671 tmp=2.526170e-08 $ Water around fuel element                         
367105   106 -1.698     312302 -312303 -311304          imp:n=1 u=3671  $ Lower graphite slug                          
367106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3671  $ Fuel cladding                         
367107   108  0.042234 312303 -312304 -311301          imp:n=1 u=3671  tmp=2.533494e-08 $ Zirc pin                          
367108  3671 -5.758028 312303 -302303  311301 -311304  imp:n=1 u=3671  tmp=2.533494e-08 $ Fuel meat section 1                         
367109  3671 -5.758028 302303 -302306  311301 -311304  imp:n=1 u=3671  tmp=2.533494e-08 $ Fuel meat section 2                         
367110  3671 -5.758028 302306 -302309  311301 -311304  imp:n=1 u=3671  tmp=2.533494e-08 $ Fuel meat section 3                         
367111  3671 -5.758028 302309 -302312  311301 -311304  imp:n=1 u=3671  tmp=2.533494e-08 $ Fuel meat section 4                         
367112  3671 -5.758028 302312 -312304  311301 -311304  imp:n=1 u=3671  tmp=2.533494e-08 $ Fuel meat section 5                         
367113   106 -1.698     312304 -312305 -311304          imp:n=1 u=3671  $ Upper graphite spacer                         
367114   105 -7.85     312305 -312306 -311305          imp:n=1 u=3671  $ SS top cap                          
367115   105 -7.85     312306 -312307 -311303          imp:n=1 u=3671  $ Tri-flute                          
367116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3671 tmp=2.526170e-08 $ Water around tri-flute                          
367117   105 -7.85     312307 -312308 -311302          imp:n=1 u=3671  $ Fuel tip                         
367118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3671 tmp=2.526170e-08 $ Water around fuel tip                         
367119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3671 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3673 - SS clad (T0S210D210) universe --- 
c                         
367301   105 -7.85     312300 -312301 -311302          imp:n=1 u=3673  $ Lower grid plate pin                         
367302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3673 tmp=2.526170e-08 $ Water around grid plate pin                          
367303   105 -7.85     312301 -312302 -311305          imp:n=1 u=3673  $ Bottom casing                          
367304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3673 tmp=2.526170e-08 $ Water around fuel element                         
367305   106 -1.698     312302 -312303 -311304          imp:n=1 u=3673  $ Lower graphite slug                          
367306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3673  $ Fuel cladding                         
367307   108  0.042234 312303 -312304 -311301          imp:n=1 u=3673  tmp=2.533494e-08 $ Zirc pin                          
367308  3673 -5.761926 312303 -302303  311301 -311304  imp:n=1 u=3673  tmp=2.533494e-08 $ Fuel meat section 1                         
367309  3673 -5.761926 302303 -302306  311301 -311304  imp:n=1 u=3673  tmp=2.533494e-08 $ Fuel meat section 2                         
367310  3673 -5.761926 302306 -302309  311301 -311304  imp:n=1 u=3673  tmp=2.533494e-08 $ Fuel meat section 3                         
367311  3673 -5.761926 302309 -302312  311301 -311304  imp:n=1 u=3673  tmp=2.533494e-08 $ Fuel meat section 4                         
367312  3673 -5.761926 302312 -312304  311301 -311304  imp:n=1 u=3673  tmp=2.533494e-08 $ Fuel meat section 5                         
367313   106 -1.698     312304 -312305 -311304          imp:n=1 u=3673  $ Upper graphite spacer                         
367314   105 -7.85     312305 -312306 -311305          imp:n=1 u=3673  $ SS top cap                          
367315   105 -7.85     312306 -312307 -311303          imp:n=1 u=3673  $ Tri-flute                          
367316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3673 tmp=2.526170e-08 $ Water around tri-flute                          
367317   105 -7.85     312307 -312308 -311302          imp:n=1 u=3673  $ Fuel tip                         
367318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3673 tmp=2.526170e-08 $ Water around fuel tip                         
367319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3673 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3674 - SS clad (T0S210D210) universe --- 
c                         
367401   105 -7.85     312300 -312301 -311302          imp:n=1 u=3674  $ Lower grid plate pin                         
367402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3674 tmp=2.526170e-08 $ Water around grid plate pin                          
367403   105 -7.85     312301 -312302 -311305          imp:n=1 u=3674  $ Bottom casing                          
367404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3674 tmp=2.526170e-08 $ Water around fuel element                         
367405   106 -1.698     312302 -312303 -311304          imp:n=1 u=3674  $ Lower graphite slug                          
367406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3674  $ Fuel cladding                         
367407   108  0.042234 312303 -312304 -311301          imp:n=1 u=3674  tmp=2.533494e-08 $ Zirc pin                          
367408  3674 -5.761474 312303 -302303  311301 -311304  imp:n=1 u=3674  tmp=2.533494e-08 $ Fuel meat section 1                         
367409  3674 -5.761474 302303 -302306  311301 -311304  imp:n=1 u=3674  tmp=2.533494e-08 $ Fuel meat section 2                         
367410  3674 -5.761474 302306 -302309  311301 -311304  imp:n=1 u=3674  tmp=2.533494e-08 $ Fuel meat section 3                         
367411  3674 -5.761474 302309 -302312  311301 -311304  imp:n=1 u=3674  tmp=2.533494e-08 $ Fuel meat section 4                         
367412  3674 -5.761474 302312 -312304  311301 -311304  imp:n=1 u=3674  tmp=2.533494e-08 $ Fuel meat section 5                         
367413   106 -1.698     312304 -312305 -311304          imp:n=1 u=3674  $ Upper graphite spacer                         
367414   105 -7.85     312305 -312306 -311305          imp:n=1 u=3674  $ SS top cap                          
367415   105 -7.85     312306 -312307 -311303          imp:n=1 u=3674  $ Tri-flute                          
367416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3674 tmp=2.526170e-08 $ Water around tri-flute                          
367417   105 -7.85     312307 -312308 -311302          imp:n=1 u=3674  $ Fuel tip                         
367418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3674 tmp=2.526170e-08 $ Water around fuel tip                         
367419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3674 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3676 - SS clad (T0S210D210) universe --- 
c                         
367601   105 -7.85     312300 -312301 -311302          imp:n=1 u=3676  $ Lower grid plate pin                         
367602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3676 tmp=2.526170e-08 $ Water around grid plate pin                          
367603   105 -7.85     312301 -312302 -311305          imp:n=1 u=3676  $ Bottom casing                          
367604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3676 tmp=2.526170e-08 $ Water around fuel element                         
367605   106 -1.698     312302 -312303 -311304          imp:n=1 u=3676  $ Lower graphite slug                          
367606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3676  $ Fuel cladding                         
367607   108  0.042234 312303 -312304 -311301          imp:n=1 u=3676  tmp=2.533494e-08 $ Zirc pin                          
367608  3676 -5.76172 312303 -302303  311301 -311304  imp:n=1 u=3676  tmp=2.533494e-08 $ Fuel meat section 1                         
367609  3676 -5.76172 302303 -302306  311301 -311304  imp:n=1 u=3676  tmp=2.533494e-08 $ Fuel meat section 2                         
367610  3676 -5.76172 302306 -302309  311301 -311304  imp:n=1 u=3676  tmp=2.533494e-08 $ Fuel meat section 3                         
367611  3676 -5.76172 302309 -302312  311301 -311304  imp:n=1 u=3676  tmp=2.533494e-08 $ Fuel meat section 4                         
367612  3676 -5.76172 302312 -312304  311301 -311304  imp:n=1 u=3676  tmp=2.533494e-08 $ Fuel meat section 5                         
367613   106 -1.698     312304 -312305 -311304          imp:n=1 u=3676  $ Upper graphite spacer                         
367614   105 -7.85     312305 -312306 -311305          imp:n=1 u=3676  $ SS top cap                          
367615   105 -7.85     312306 -312307 -311303          imp:n=1 u=3676  $ Tri-flute                          
367616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3676 tmp=2.526170e-08 $ Water around tri-flute                          
367617   105 -7.85     312307 -312308 -311302          imp:n=1 u=3676  $ Fuel tip                         
367618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3676 tmp=2.526170e-08 $ Water around fuel tip                         
367619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3676 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3677 - SS clad (T0S210D210) universe --- 
c                         
367701   105 -7.85     312300 -312301 -311302          imp:n=1 u=3677  $ Lower grid plate pin                         
367702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3677 tmp=2.526170e-08 $ Water around grid plate pin                          
367703   105 -7.85     312301 -312302 -311305          imp:n=1 u=3677  $ Bottom casing                          
367704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3677 tmp=2.526170e-08 $ Water around fuel element                         
367705   106 -1.698     312302 -312303 -311304          imp:n=1 u=3677  $ Lower graphite slug                          
367706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3677  $ Fuel cladding                         
367707   108  0.042234 312303 -312304 -311301          imp:n=1 u=3677  tmp=2.533494e-08 $ Zirc pin                          
367708  3677 -5.757819 312303 -302303  311301 -311304  imp:n=1 u=3677  tmp=2.533494e-08 $ Fuel meat section 1                         
367709  3677 -5.757819 302303 -302306  311301 -311304  imp:n=1 u=3677  tmp=2.533494e-08 $ Fuel meat section 2                         
367710  3677 -5.757819 302306 -302309  311301 -311304  imp:n=1 u=3677  tmp=2.533494e-08 $ Fuel meat section 3                         
367711  3677 -5.757819 302309 -302312  311301 -311304  imp:n=1 u=3677  tmp=2.533494e-08 $ Fuel meat section 4                         
367712  3677 -5.757819 302312 -312304  311301 -311304  imp:n=1 u=3677  tmp=2.533494e-08 $ Fuel meat section 5                         
367713   106 -1.698     312304 -312305 -311304          imp:n=1 u=3677  $ Upper graphite spacer                         
367714   105 -7.85     312305 -312306 -311305          imp:n=1 u=3677  $ SS top cap                          
367715   105 -7.85     312306 -312307 -311303          imp:n=1 u=3677  $ Tri-flute                          
367716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3677 tmp=2.526170e-08 $ Water around tri-flute                          
367717   105 -7.85     312307 -312308 -311302          imp:n=1 u=3677  $ Fuel tip                         
367718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3677 tmp=2.526170e-08 $ Water around fuel tip                         
367719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3677 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3679 - SS clad (T0S210D210) universe --- 
c                         
367901   105 -7.85     312300 -312301 -311302          imp:n=1 u=3679  $ Lower grid plate pin                         
367902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3679 tmp=2.526170e-08 $ Water around grid plate pin                          
367903   105 -7.85     312301 -312302 -311305          imp:n=1 u=3679  $ Bottom casing                          
367904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3679 tmp=2.526170e-08 $ Water around fuel element                         
367905   106 -1.698     312302 -312303 -311304          imp:n=1 u=3679  $ Lower graphite slug                          
367906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3679  $ Fuel cladding                         
367907   108  0.042234 312303 -312304 -311301          imp:n=1 u=3679  tmp=2.533494e-08 $ Zirc pin                          
367908  3679 -5.757745 312303 -302303  311301 -311304  imp:n=1 u=3679  tmp=2.533494e-08 $ Fuel meat section 1                         
367909  3679 -5.757745 302303 -302306  311301 -311304  imp:n=1 u=3679  tmp=2.533494e-08 $ Fuel meat section 2                         
367910  3679 -5.757745 302306 -302309  311301 -311304  imp:n=1 u=3679  tmp=2.533494e-08 $ Fuel meat section 3                         
367911  3679 -5.757745 302309 -302312  311301 -311304  imp:n=1 u=3679  tmp=2.533494e-08 $ Fuel meat section 4                         
367912  3679 -5.757745 302312 -312304  311301 -311304  imp:n=1 u=3679  tmp=2.533494e-08 $ Fuel meat section 5                         
367913   106 -1.698     312304 -312305 -311304          imp:n=1 u=3679  $ Upper graphite spacer                         
367914   105 -7.85     312305 -312306 -311305          imp:n=1 u=3679  $ SS top cap                          
367915   105 -7.85     312306 -312307 -311303          imp:n=1 u=3679  $ Tri-flute                          
367916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3679 tmp=2.526170e-08 $ Water around tri-flute                          
367917   105 -7.85     312307 -312308 -311302          imp:n=1 u=3679  $ Fuel tip                         
367918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3679 tmp=2.526170e-08 $ Water around fuel tip                         
367919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3679 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3682 - SS clad (T0S210D210) universe --- 
c                         
368201   105 -7.85     312300 -312301 -311302          imp:n=1 u=3682  $ Lower grid plate pin                         
368202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3682 tmp=2.526170e-08 $ Water around grid plate pin                          
368203   105 -7.85     312301 -312302 -311305          imp:n=1 u=3682  $ Bottom casing                          
368204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3682 tmp=2.526170e-08 $ Water around fuel element                         
368205   106 -1.698     312302 -312303 -311304          imp:n=1 u=3682  $ Lower graphite slug                          
368206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3682  $ Fuel cladding                         
368207   108  0.042234 312303 -312304 -311301          imp:n=1 u=3682  tmp=2.533494e-08 $ Zirc pin                          
368208  3682 -5.759656 312303 -302303  311301 -311304  imp:n=1 u=3682  tmp=2.533494e-08 $ Fuel meat section 1                         
368209  3682 -5.759656 302303 -302306  311301 -311304  imp:n=1 u=3682  tmp=2.533494e-08 $ Fuel meat section 2                         
368210  3682 -5.759656 302306 -302309  311301 -311304  imp:n=1 u=3682  tmp=2.533494e-08 $ Fuel meat section 3                         
368211  3682 -5.759656 302309 -302312  311301 -311304  imp:n=1 u=3682  tmp=2.533494e-08 $ Fuel meat section 4                         
368212  3682 -5.759656 302312 -312304  311301 -311304  imp:n=1 u=3682  tmp=2.533494e-08 $ Fuel meat section 5                         
368213   106 -1.698     312304 -312305 -311304          imp:n=1 u=3682  $ Upper graphite spacer                         
368214   105 -7.85     312305 -312306 -311305          imp:n=1 u=3682  $ SS top cap                          
368215   105 -7.85     312306 -312307 -311303          imp:n=1 u=3682  $ Tri-flute                          
368216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3682 tmp=2.526170e-08 $ Water around tri-flute                          
368217   105 -7.85     312307 -312308 -311302          imp:n=1 u=3682  $ Fuel tip                         
368218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3682 tmp=2.526170e-08 $ Water around fuel tip                         
368219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3682 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3683 - SS clad (T0S210D210) universe --- 
c                         
368301   105 -7.85     312300 -312301 -311302          imp:n=1 u=3683  $ Lower grid plate pin                         
368302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3683 tmp=2.526170e-08 $ Water around grid plate pin                          
368303   105 -7.85     312301 -312302 -311305          imp:n=1 u=3683  $ Bottom casing                          
368304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3683 tmp=2.526170e-08 $ Water around fuel element                         
368305   106 -1.698     312302 -312303 -311304          imp:n=1 u=3683  $ Lower graphite slug                          
368306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3683  $ Fuel cladding                         
368307   108  0.042234 312303 -312304 -311301          imp:n=1 u=3683  tmp=2.533494e-08 $ Zirc pin                          
368308  3683 -5.762053 312303 -302303  311301 -311304  imp:n=1 u=3683  tmp=2.533494e-08 $ Fuel meat section 1                         
368309  3683 -5.762053 302303 -302306  311301 -311304  imp:n=1 u=3683  tmp=2.533494e-08 $ Fuel meat section 2                         
368310  3683 -5.762053 302306 -302309  311301 -311304  imp:n=1 u=3683  tmp=2.533494e-08 $ Fuel meat section 3                         
368311  3683 -5.762053 302309 -302312  311301 -311304  imp:n=1 u=3683  tmp=2.533494e-08 $ Fuel meat section 4                         
368312  3683 -5.762053 302312 -312304  311301 -311304  imp:n=1 u=3683  tmp=2.533494e-08 $ Fuel meat section 5                         
368313   106 -1.698     312304 -312305 -311304          imp:n=1 u=3683  $ Upper graphite spacer                         
368314   105 -7.85     312305 -312306 -311305          imp:n=1 u=3683  $ SS top cap                          
368315   105 -7.85     312306 -312307 -311303          imp:n=1 u=3683  $ Tri-flute                          
368316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3683 tmp=2.526170e-08 $ Water around tri-flute                          
368317   105 -7.85     312307 -312308 -311302          imp:n=1 u=3683  $ Fuel tip                         
368318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3683 tmp=2.526170e-08 $ Water around fuel tip                         
368319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3683 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3685 - SS clad (T0S210D210) universe --- 
c                         
368501   105 -7.85     312300 -312301 -311302          imp:n=1 u=3685  $ Lower grid plate pin                         
368502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3685 tmp=2.526170e-08 $ Water around grid plate pin                          
368503   105 -7.85     312301 -312302 -311305          imp:n=1 u=3685  $ Bottom casing                          
368504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3685 tmp=2.526170e-08 $ Water around fuel element                         
368505   106 -1.698     312302 -312303 -311304          imp:n=1 u=3685  $ Lower graphite slug                          
368506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3685  $ Fuel cladding                         
368507   108  0.042234 312303 -312304 -311301          imp:n=1 u=3685  tmp=2.533494e-08 $ Zirc pin                          
368508  3685 -5.75955 312303 -302303  311301 -311304  imp:n=1 u=3685  tmp=2.533494e-08 $ Fuel meat section 1                         
368509  3685 -5.75955 302303 -302306  311301 -311304  imp:n=1 u=3685  tmp=2.533494e-08 $ Fuel meat section 2                         
368510  3685 -5.75955 302306 -302309  311301 -311304  imp:n=1 u=3685  tmp=2.533494e-08 $ Fuel meat section 3                         
368511  3685 -5.75955 302309 -302312  311301 -311304  imp:n=1 u=3685  tmp=2.533494e-08 $ Fuel meat section 4                         
368512  3685 -5.75955 302312 -312304  311301 -311304  imp:n=1 u=3685  tmp=2.533494e-08 $ Fuel meat section 5                         
368513   106 -1.698     312304 -312305 -311304          imp:n=1 u=3685  $ Upper graphite spacer                         
368514   105 -7.85     312305 -312306 -311305          imp:n=1 u=3685  $ SS top cap                          
368515   105 -7.85     312306 -312307 -311303          imp:n=1 u=3685  $ Tri-flute                          
368516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3685 tmp=2.526170e-08 $ Water around tri-flute                          
368517   105 -7.85     312307 -312308 -311302          imp:n=1 u=3685  $ Fuel tip                         
368518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3685 tmp=2.526170e-08 $ Water around fuel tip                         
368519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3685 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3721 - SS clad (T0S210D210) universe --- 
c                         
372101   105 -7.85     312300 -312301 -311302          imp:n=1 u=3721  $ Lower grid plate pin                         
372102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3721 tmp=2.526170e-08 $ Water around grid plate pin                          
372103   105 -7.85     312301 -312302 -311305          imp:n=1 u=3721  $ Bottom casing                          
372104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3721 tmp=2.526170e-08 $ Water around fuel element                         
372105   106 -1.698     312302 -312303 -311304          imp:n=1 u=3721  $ Lower graphite slug                          
372106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3721  $ Fuel cladding                         
372107   108  0.042234 312303 -312304 -311301          imp:n=1 u=3721  tmp=2.533494e-08 $ Zirc pin                          
372108  3721 -5.604529 312303 -302303  311301 -311304  imp:n=1 u=3721  tmp=2.533494e-08 $ Fuel meat section 1                         
372109  3721 -5.604529 302303 -302306  311301 -311304  imp:n=1 u=3721  tmp=2.533494e-08 $ Fuel meat section 2                         
372110  3721 -5.604529 302306 -302309  311301 -311304  imp:n=1 u=3721  tmp=2.533494e-08 $ Fuel meat section 3                         
372111  3721 -5.604529 302309 -302312  311301 -311304  imp:n=1 u=3721  tmp=2.533494e-08 $ Fuel meat section 4                         
372112  3721 -5.604529 302312 -312304  311301 -311304  imp:n=1 u=3721  tmp=2.533494e-08 $ Fuel meat section 5                         
372113   106 -1.698     312304 -312305 -311304          imp:n=1 u=3721  $ Upper graphite spacer                         
372114   105 -7.85     312305 -312306 -311305          imp:n=1 u=3721  $ SS top cap                          
372115   105 -7.85     312306 -312307 -311303          imp:n=1 u=3721  $ Tri-flute                          
372116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3721 tmp=2.526170e-08 $ Water around tri-flute                          
372117   105 -7.85     312307 -312308 -311302          imp:n=1 u=3721  $ Fuel tip                         
372118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3721 tmp=2.526170e-08 $ Water around fuel tip                         
372119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3721 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3743 - SS clad (T0S210D210) universe --- 
c                         
374301   105 -7.85     312300 -312301 -311302          imp:n=1 u=3743  $ Lower grid plate pin                         
374302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3743 tmp=2.526170e-08 $ Water around grid plate pin                          
374303   105 -7.85     312301 -312302 -311305          imp:n=1 u=3743  $ Bottom casing                          
374304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3743 tmp=2.526170e-08 $ Water around fuel element                         
374305   106 -1.698     312302 -312303 -311304          imp:n=1 u=3743  $ Lower graphite slug                          
374306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3743  $ Fuel cladding                         
374307   108  0.042234 312303 -312304 -311301          imp:n=1 u=3743  tmp=2.533494e-08 $ Zirc pin                          
374308  3743 -5.607189 312303 -302303  311301 -311304  imp:n=1 u=3743  tmp=2.533494e-08 $ Fuel meat section 1                         
374309  3743 -5.607189 302303 -302306  311301 -311304  imp:n=1 u=3743  tmp=2.533494e-08 $ Fuel meat section 2                         
374310  3743 -5.607189 302306 -302309  311301 -311304  imp:n=1 u=3743  tmp=2.533494e-08 $ Fuel meat section 3                         
374311  3743 -5.607189 302309 -302312  311301 -311304  imp:n=1 u=3743  tmp=2.533494e-08 $ Fuel meat section 4                         
374312  3743 -5.607189 302312 -312304  311301 -311304  imp:n=1 u=3743  tmp=2.533494e-08 $ Fuel meat section 5                         
374313   106 -1.698     312304 -312305 -311304          imp:n=1 u=3743  $ Upper graphite spacer                         
374314   105 -7.85     312305 -312306 -311305          imp:n=1 u=3743  $ SS top cap                          
374315   105 -7.85     312306 -312307 -311303          imp:n=1 u=3743  $ Tri-flute                          
374316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3743 tmp=2.526170e-08 $ Water around tri-flute                          
374317   105 -7.85     312307 -312308 -311302          imp:n=1 u=3743  $ Fuel tip                         
374318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3743 tmp=2.526170e-08 $ Water around fuel tip                         
374319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3743 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3748 - SS clad (T0S210D210) universe --- 
c                         
374801   105 -7.85     312300 -312301 -311302          imp:n=1 u=3748  $ Lower grid plate pin                         
374802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3748 tmp=2.526170e-08 $ Water around grid plate pin                          
374803   105 -7.85     312301 -312302 -311305          imp:n=1 u=3748  $ Bottom casing                          
374804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3748 tmp=2.526170e-08 $ Water around fuel element                         
374805   106 -1.698     312302 -312303 -311304          imp:n=1 u=3748  $ Lower graphite slug                          
374806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3748  $ Fuel cladding                         
374807   108  0.042234 312303 -312304 -311301          imp:n=1 u=3748  tmp=2.533494e-08 $ Zirc pin                          
374808  3748 -5.61485 312303 -302303  311301 -311304  imp:n=1 u=3748  tmp=2.533494e-08 $ Fuel meat section 1                         
374809  3748 -5.61485 302303 -302306  311301 -311304  imp:n=1 u=3748  tmp=2.533494e-08 $ Fuel meat section 2                         
374810  3748 -5.61485 302306 -302309  311301 -311304  imp:n=1 u=3748  tmp=2.533494e-08 $ Fuel meat section 3                         
374811  3748 -5.61485 302309 -302312  311301 -311304  imp:n=1 u=3748  tmp=2.533494e-08 $ Fuel meat section 4                         
374812  3748 -5.61485 302312 -312304  311301 -311304  imp:n=1 u=3748  tmp=2.533494e-08 $ Fuel meat section 5                         
374813   106 -1.698     312304 -312305 -311304          imp:n=1 u=3748  $ Upper graphite spacer                         
374814   105 -7.85     312305 -312306 -311305          imp:n=1 u=3748  $ SS top cap                          
374815   105 -7.85     312306 -312307 -311303          imp:n=1 u=3748  $ Tri-flute                          
374816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3748 tmp=2.526170e-08 $ Water around tri-flute                          
374817   105 -7.85     312307 -312308 -311302          imp:n=1 u=3748  $ Fuel tip                         
374818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3748 tmp=2.526170e-08 $ Water around fuel tip                         
374819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3748 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3774 - SS clad (T0S210D210) universe --- 
c                         
377401   105 -7.85     312300 -312301 -311302          imp:n=1 u=3774  $ Lower grid plate pin                         
377402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3774 tmp=2.526170e-08 $ Water around grid plate pin                          
377403   105 -7.85     312301 -312302 -311305          imp:n=1 u=3774  $ Bottom casing                          
377404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3774 tmp=2.526170e-08 $ Water around fuel element                         
377405   106 -1.698     312302 -312303 -311304          imp:n=1 u=3774  $ Lower graphite slug                          
377406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3774  $ Fuel cladding                         
377407   108  0.042234 312303 -312304 -311301          imp:n=1 u=3774  tmp=2.533494e-08 $ Zirc pin                          
377408  3774 -5.756737 312303 -302303  311301 -311304  imp:n=1 u=3774  tmp=2.533494e-08 $ Fuel meat section 1                         
377409  3774 -5.756737 302303 -302306  311301 -311304  imp:n=1 u=3774  tmp=2.533494e-08 $ Fuel meat section 2                         
377410  3774 -5.756737 302306 -302309  311301 -311304  imp:n=1 u=3774  tmp=2.533494e-08 $ Fuel meat section 3                         
377411  3774 -5.756737 302309 -302312  311301 -311304  imp:n=1 u=3774  tmp=2.533494e-08 $ Fuel meat section 4                         
377412  3774 -5.756737 302312 -312304  311301 -311304  imp:n=1 u=3774  tmp=2.533494e-08 $ Fuel meat section 5                         
377413   106 -1.698     312304 -312305 -311304          imp:n=1 u=3774  $ Upper graphite spacer                         
377414   105 -7.85     312305 -312306 -311305          imp:n=1 u=3774  $ SS top cap                          
377415   105 -7.85     312306 -312307 -311303          imp:n=1 u=3774  $ Tri-flute                          
377416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3774 tmp=2.526170e-08 $ Water around tri-flute                          
377417   105 -7.85     312307 -312308 -311302          imp:n=1 u=3774  $ Fuel tip                         
377418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3774 tmp=2.526170e-08 $ Water around fuel tip                         
377419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3774 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3810 - SS clad (T0S210D210) universe --- 
c                         
381001   105 -7.85     312300 -312301 -311302          imp:n=1 u=3810  $ Lower grid plate pin                         
381002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3810 tmp=2.526170e-08 $ Water around grid plate pin                          
381003   105 -7.85     312301 -312302 -311305          imp:n=1 u=3810  $ Bottom casing                          
381004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3810 tmp=2.526170e-08 $ Water around fuel element                         
381005   106 -1.698     312302 -312303 -311304          imp:n=1 u=3810  $ Lower graphite slug                          
381006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3810  $ Fuel cladding                         
381007   108  0.042234 312303 -312304 -311301          imp:n=1 u=3810  tmp=2.533494e-08 $ Zirc pin                          
381008  3810 -5.756887 312303 -302303  311301 -311304  imp:n=1 u=3810  tmp=2.533494e-08 $ Fuel meat section 1                         
381009  3810 -5.756887 302303 -302306  311301 -311304  imp:n=1 u=3810  tmp=2.533494e-08 $ Fuel meat section 2                         
381010  3810 -5.756887 302306 -302309  311301 -311304  imp:n=1 u=3810  tmp=2.533494e-08 $ Fuel meat section 3                         
381011  3810 -5.756887 302309 -302312  311301 -311304  imp:n=1 u=3810  tmp=2.533494e-08 $ Fuel meat section 4                         
381012  3810 -5.756887 302312 -312304  311301 -311304  imp:n=1 u=3810  tmp=2.533494e-08 $ Fuel meat section 5                         
381013   106 -1.698     312304 -312305 -311304          imp:n=1 u=3810  $ Upper graphite spacer                         
381014   105 -7.85     312305 -312306 -311305          imp:n=1 u=3810  $ SS top cap                          
381015   105 -7.85     312306 -312307 -311303          imp:n=1 u=3810  $ Tri-flute                          
381016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3810 tmp=2.526170e-08 $ Water around tri-flute                          
381017   105 -7.85     312307 -312308 -311302          imp:n=1 u=3810  $ Fuel tip                         
381018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3810 tmp=2.526170e-08 $ Water around fuel tip                         
381019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3810 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3835 - SS clad (T0S210D210) universe --- 
c                         
383501   105 -7.85     312300 -312301 -311302          imp:n=1 u=3835  $ Lower grid plate pin                         
383502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3835 tmp=2.526170e-08 $ Water around grid plate pin                          
383503   105 -7.85     312301 -312302 -311305          imp:n=1 u=3835  $ Bottom casing                          
383504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3835 tmp=2.526170e-08 $ Water around fuel element                         
383505   106 -1.698     312302 -312303 -311304          imp:n=1 u=3835  $ Lower graphite slug                          
383506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3835  $ Fuel cladding                         
383507   108  0.042234 312303 -312304 -311301          imp:n=1 u=3835  tmp=2.533494e-08 $ Zirc pin                          
383508  3835 -5.915718 312303 -302303  311301 -311304  imp:n=1 u=3835  tmp=2.533494e-08 $ Fuel meat section 1                         
383509  3835 -5.915718 302303 -302306  311301 -311304  imp:n=1 u=3835  tmp=2.533494e-08 $ Fuel meat section 2                         
383510  3835 -5.915718 302306 -302309  311301 -311304  imp:n=1 u=3835  tmp=2.533494e-08 $ Fuel meat section 3                         
383511  3835 -5.915718 302309 -302312  311301 -311304  imp:n=1 u=3835  tmp=2.533494e-08 $ Fuel meat section 4                         
383512  3835 -5.915718 302312 -312304  311301 -311304  imp:n=1 u=3835  tmp=2.533494e-08 $ Fuel meat section 5                         
383513   106 -1.698     312304 -312305 -311304          imp:n=1 u=3835  $ Upper graphite spacer                         
383514   105 -7.85     312305 -312306 -311305          imp:n=1 u=3835  $ SS top cap                          
383515   105 -7.85     312306 -312307 -311303          imp:n=1 u=3835  $ Tri-flute                          
383516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3835 tmp=2.526170e-08 $ Water around tri-flute                          
383517   105 -7.85     312307 -312308 -311302          imp:n=1 u=3835  $ Fuel tip                         
383518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3835 tmp=2.526170e-08 $ Water around fuel tip                         
383519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3835 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3840 - SS clad (T0S210D210) universe --- 
c                         
384001   105 -7.85     312300 -312301 -311302          imp:n=1 u=3840  $ Lower grid plate pin                         
384002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3840 tmp=2.526170e-08 $ Water around grid plate pin                          
384003   105 -7.85     312301 -312302 -311305          imp:n=1 u=3840  $ Bottom casing                          
384004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3840 tmp=2.526170e-08 $ Water around fuel element                         
384005   106 -1.698     312302 -312303 -311304          imp:n=1 u=3840  $ Lower graphite slug                          
384006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3840  $ Fuel cladding                         
384007   108  0.042234 312303 -312304 -311301          imp:n=1 u=3840  tmp=2.533494e-08 $ Zirc pin                          
384008  3840 -5.764653 312303 -302303  311301 -311304  imp:n=1 u=3840  tmp=2.533494e-08 $ Fuel meat section 1                         
384009  3840 -5.764653 302303 -302306  311301 -311304  imp:n=1 u=3840  tmp=2.533494e-08 $ Fuel meat section 2                         
384010  3840 -5.764653 302306 -302309  311301 -311304  imp:n=1 u=3840  tmp=2.533494e-08 $ Fuel meat section 3                         
384011  3840 -5.764653 302309 -302312  311301 -311304  imp:n=1 u=3840  tmp=2.533494e-08 $ Fuel meat section 4                         
384012  3840 -5.764653 302312 -312304  311301 -311304  imp:n=1 u=3840  tmp=2.533494e-08 $ Fuel meat section 5                         
384013   106 -1.698     312304 -312305 -311304          imp:n=1 u=3840  $ Upper graphite spacer                         
384014   105 -7.85     312305 -312306 -311305          imp:n=1 u=3840  $ SS top cap                          
384015   105 -7.85     312306 -312307 -311303          imp:n=1 u=3840  $ Tri-flute                          
384016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3840 tmp=2.526170e-08 $ Water around tri-flute                          
384017   105 -7.85     312307 -312308 -311302          imp:n=1 u=3840  $ Fuel tip                         
384018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3840 tmp=2.526170e-08 $ Water around fuel tip                         
384019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3840 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3851 - SS clad (T0S210D210) universe --- 
c                         
385101   105 -7.85     312300 -312301 -311302          imp:n=1 u=3851  $ Lower grid plate pin                         
385102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3851 tmp=2.526170e-08 $ Water around grid plate pin                          
385103   105 -7.85     312301 -312302 -311305          imp:n=1 u=3851  $ Bottom casing                          
385104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3851 tmp=2.526170e-08 $ Water around fuel element                         
385105   106 -1.698     312302 -312303 -311304          imp:n=1 u=3851  $ Lower graphite slug                          
385106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3851  $ Fuel cladding                         
385107   108  0.042234 312303 -312304 -311301          imp:n=1 u=3851  tmp=2.533494e-08 $ Zirc pin                          
385108  3851 -5.764518 312303 -302303  311301 -311304  imp:n=1 u=3851  tmp=2.533494e-08 $ Fuel meat section 1                         
385109  3851 -5.764518 302303 -302306  311301 -311304  imp:n=1 u=3851  tmp=2.533494e-08 $ Fuel meat section 2                         
385110  3851 -5.764518 302306 -302309  311301 -311304  imp:n=1 u=3851  tmp=2.533494e-08 $ Fuel meat section 3                         
385111  3851 -5.764518 302309 -302312  311301 -311304  imp:n=1 u=3851  tmp=2.533494e-08 $ Fuel meat section 4                         
385112  3851 -5.764518 302312 -312304  311301 -311304  imp:n=1 u=3851  tmp=2.533494e-08 $ Fuel meat section 5                         
385113   106 -1.698     312304 -312305 -311304          imp:n=1 u=3851  $ Upper graphite spacer                         
385114   105 -7.85     312305 -312306 -311305          imp:n=1 u=3851  $ SS top cap                          
385115   105 -7.85     312306 -312307 -311303          imp:n=1 u=3851  $ Tri-flute                          
385116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3851 tmp=2.526170e-08 $ Water around tri-flute                          
385117   105 -7.85     312307 -312308 -311302          imp:n=1 u=3851  $ Fuel tip                         
385118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3851 tmp=2.526170e-08 $ Water around fuel tip                         
385119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3851 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3852 - SS clad (T0S210D210) universe --- 
c                         
385201   105 -7.85     312300 -312301 -311302          imp:n=1 u=3852  $ Lower grid plate pin                         
385202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3852 tmp=2.526170e-08 $ Water around grid plate pin                          
385203   105 -7.85     312301 -312302 -311305          imp:n=1 u=3852  $ Bottom casing                          
385204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3852 tmp=2.526170e-08 $ Water around fuel element                         
385205   106 -1.698     312302 -312303 -311304          imp:n=1 u=3852  $ Lower graphite slug                          
385206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3852  $ Fuel cladding                         
385207   108  0.042234 312303 -312304 -311301          imp:n=1 u=3852  tmp=2.533494e-08 $ Zirc pin                          
385208  3852 -5.76672 312303 -302303  311301 -311304  imp:n=1 u=3852  tmp=2.533494e-08 $ Fuel meat section 1                         
385209  3852 -5.76672 302303 -302306  311301 -311304  imp:n=1 u=3852  tmp=2.533494e-08 $ Fuel meat section 2                         
385210  3852 -5.76672 302306 -302309  311301 -311304  imp:n=1 u=3852  tmp=2.533494e-08 $ Fuel meat section 3                         
385211  3852 -5.76672 302309 -302312  311301 -311304  imp:n=1 u=3852  tmp=2.533494e-08 $ Fuel meat section 4                         
385212  3852 -5.76672 302312 -312304  311301 -311304  imp:n=1 u=3852  tmp=2.533494e-08 $ Fuel meat section 5                         
385213   106 -1.698     312304 -312305 -311304          imp:n=1 u=3852  $ Upper graphite spacer                         
385214   105 -7.85     312305 -312306 -311305          imp:n=1 u=3852  $ SS top cap                          
385215   105 -7.85     312306 -312307 -311303          imp:n=1 u=3852  $ Tri-flute                          
385216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3852 tmp=2.526170e-08 $ Water around tri-flute                          
385217   105 -7.85     312307 -312308 -311302          imp:n=1 u=3852  $ Fuel tip                         
385218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3852 tmp=2.526170e-08 $ Water around fuel tip                         
385219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3852 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3853 - SS clad (T0S210D210) universe --- 
c                         
385301   105 -7.85     312300 -312301 -311302          imp:n=1 u=3853  $ Lower grid plate pin                         
385302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3853 tmp=2.526170e-08 $ Water around grid plate pin                          
385303   105 -7.85     312301 -312302 -311305          imp:n=1 u=3853  $ Bottom casing                          
385304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3853 tmp=2.526170e-08 $ Water around fuel element                         
385305   106 -1.698     312302 -312303 -311304          imp:n=1 u=3853  $ Lower graphite slug                          
385306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3853  $ Fuel cladding                         
385307   108  0.042234 312303 -312304 -311301          imp:n=1 u=3853  tmp=2.533494e-08 $ Zirc pin                          
385308  3853 -5.76317 312303 -302303  311301 -311304  imp:n=1 u=3853  tmp=2.533494e-08 $ Fuel meat section 1                         
385309  3853 -5.76317 302303 -302306  311301 -311304  imp:n=1 u=3853  tmp=2.533494e-08 $ Fuel meat section 2                         
385310  3853 -5.76317 302306 -302309  311301 -311304  imp:n=1 u=3853  tmp=2.533494e-08 $ Fuel meat section 3                         
385311  3853 -5.76317 302309 -302312  311301 -311304  imp:n=1 u=3853  tmp=2.533494e-08 $ Fuel meat section 4                         
385312  3853 -5.76317 302312 -312304  311301 -311304  imp:n=1 u=3853  tmp=2.533494e-08 $ Fuel meat section 5                         
385313   106 -1.698     312304 -312305 -311304          imp:n=1 u=3853  $ Upper graphite spacer                         
385314   105 -7.85     312305 -312306 -311305          imp:n=1 u=3853  $ SS top cap                          
385315   105 -7.85     312306 -312307 -311303          imp:n=1 u=3853  $ Tri-flute                          
385316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3853 tmp=2.526170e-08 $ Water around tri-flute                          
385317   105 -7.85     312307 -312308 -311302          imp:n=1 u=3853  $ Fuel tip                         
385318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3853 tmp=2.526170e-08 $ Water around fuel tip                         
385319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3853 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3854 - SS clad (T0S210D210) universe --- 
c                         
385401   105 -7.85     312300 -312301 -311302          imp:n=1 u=3854  $ Lower grid plate pin                         
385402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3854 tmp=2.526170e-08 $ Water around grid plate pin                          
385403   105 -7.85     312301 -312302 -311305          imp:n=1 u=3854  $ Bottom casing                          
385404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3854 tmp=2.526170e-08 $ Water around fuel element                         
385405   106 -1.698     312302 -312303 -311304          imp:n=1 u=3854  $ Lower graphite slug                          
385406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3854  $ Fuel cladding                         
385407   108  0.042234 312303 -312304 -311301          imp:n=1 u=3854  tmp=2.533494e-08 $ Zirc pin                          
385408  3854 -5.756059 312303 -302303  311301 -311304  imp:n=1 u=3854  tmp=2.533494e-08 $ Fuel meat section 1                         
385409  3854 -5.756059 302303 -302306  311301 -311304  imp:n=1 u=3854  tmp=2.533494e-08 $ Fuel meat section 2                         
385410  3854 -5.756059 302306 -302309  311301 -311304  imp:n=1 u=3854  tmp=2.533494e-08 $ Fuel meat section 3                         
385411  3854 -5.756059 302309 -302312  311301 -311304  imp:n=1 u=3854  tmp=2.533494e-08 $ Fuel meat section 4                         
385412  3854 -5.756059 302312 -312304  311301 -311304  imp:n=1 u=3854  tmp=2.533494e-08 $ Fuel meat section 5                         
385413   106 -1.698     312304 -312305 -311304          imp:n=1 u=3854  $ Upper graphite spacer                         
385414   105 -7.85     312305 -312306 -311305          imp:n=1 u=3854  $ SS top cap                          
385415   105 -7.85     312306 -312307 -311303          imp:n=1 u=3854  $ Tri-flute                          
385416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3854 tmp=2.526170e-08 $ Water around tri-flute                          
385417   105 -7.85     312307 -312308 -311302          imp:n=1 u=3854  $ Fuel tip                         
385418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3854 tmp=2.526170e-08 $ Water around fuel tip                         
385419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3854 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3855 - SS clad (T0S210D210) universe --- 
c                         
385501   105 -7.85     312300 -312301 -311302          imp:n=1 u=3855  $ Lower grid plate pin                         
385502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3855 tmp=2.526170e-08 $ Water around grid plate pin                          
385503   105 -7.85     312301 -312302 -311305          imp:n=1 u=3855  $ Bottom casing                          
385504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3855 tmp=2.526170e-08 $ Water around fuel element                         
385505   106 -1.698     312302 -312303 -311304          imp:n=1 u=3855  $ Lower graphite slug                          
385506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3855  $ Fuel cladding                         
385507   108  0.042234 312303 -312304 -311301          imp:n=1 u=3855  tmp=2.533494e-08 $ Zirc pin                          
385508  3855 -5.757336 312303 -302303  311301 -311304  imp:n=1 u=3855  tmp=2.533494e-08 $ Fuel meat section 1                         
385509  3855 -5.757336 302303 -302306  311301 -311304  imp:n=1 u=3855  tmp=2.533494e-08 $ Fuel meat section 2                         
385510  3855 -5.757336 302306 -302309  311301 -311304  imp:n=1 u=3855  tmp=2.533494e-08 $ Fuel meat section 3                         
385511  3855 -5.757336 302309 -302312  311301 -311304  imp:n=1 u=3855  tmp=2.533494e-08 $ Fuel meat section 4                         
385512  3855 -5.757336 302312 -312304  311301 -311304  imp:n=1 u=3855  tmp=2.533494e-08 $ Fuel meat section 5                         
385513   106 -1.698     312304 -312305 -311304          imp:n=1 u=3855  $ Upper graphite spacer                         
385514   105 -7.85     312305 -312306 -311305          imp:n=1 u=3855  $ SS top cap                          
385515   105 -7.85     312306 -312307 -311303          imp:n=1 u=3855  $ Tri-flute                          
385516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3855 tmp=2.526170e-08 $ Water around tri-flute                          
385517   105 -7.85     312307 -312308 -311302          imp:n=1 u=3855  $ Fuel tip                         
385518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3855 tmp=2.526170e-08 $ Water around fuel tip                         
385519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3855 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3856 - SS clad (T0S210D210) universe --- 
c                         
385601   105 -7.85     312300 -312301 -311302          imp:n=1 u=3856  $ Lower grid plate pin                         
385602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3856 tmp=2.526170e-08 $ Water around grid plate pin                          
385603   105 -7.85     312301 -312302 -311305          imp:n=1 u=3856  $ Bottom casing                          
385604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3856 tmp=2.526170e-08 $ Water around fuel element                         
385605   106 -1.698     312302 -312303 -311304          imp:n=1 u=3856  $ Lower graphite slug                          
385606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3856  $ Fuel cladding                         
385607   108  0.042234 312303 -312304 -311301          imp:n=1 u=3856  tmp=2.533494e-08 $ Zirc pin                          
385608  3856 -5.765405 312303 -302303  311301 -311304  imp:n=1 u=3856  tmp=2.533494e-08 $ Fuel meat section 1                         
385609  3856 -5.765405 302303 -302306  311301 -311304  imp:n=1 u=3856  tmp=2.533494e-08 $ Fuel meat section 2                         
385610  3856 -5.765405 302306 -302309  311301 -311304  imp:n=1 u=3856  tmp=2.533494e-08 $ Fuel meat section 3                         
385611  3856 -5.765405 302309 -302312  311301 -311304  imp:n=1 u=3856  tmp=2.533494e-08 $ Fuel meat section 4                         
385612  3856 -5.765405 302312 -312304  311301 -311304  imp:n=1 u=3856  tmp=2.533494e-08 $ Fuel meat section 5                         
385613   106 -1.698     312304 -312305 -311304          imp:n=1 u=3856  $ Upper graphite spacer                         
385614   105 -7.85     312305 -312306 -311305          imp:n=1 u=3856  $ SS top cap                          
385615   105 -7.85     312306 -312307 -311303          imp:n=1 u=3856  $ Tri-flute                          
385616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3856 tmp=2.526170e-08 $ Water around tri-flute                          
385617   105 -7.85     312307 -312308 -311302          imp:n=1 u=3856  $ Fuel tip                         
385618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3856 tmp=2.526170e-08 $ Water around fuel tip                         
385619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3856 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3858 - SS clad (T0S210D210) universe --- 
c                         
385801   105 -7.85     312300 -312301 -311302          imp:n=1 u=3858  $ Lower grid plate pin                         
385802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3858 tmp=2.526170e-08 $ Water around grid plate pin                          
385803   105 -7.85     312301 -312302 -311305          imp:n=1 u=3858  $ Bottom casing                          
385804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3858 tmp=2.526170e-08 $ Water around fuel element                         
385805   106 -1.698     312302 -312303 -311304          imp:n=1 u=3858  $ Lower graphite slug                          
385806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3858  $ Fuel cladding                         
385807   108  0.042234 312303 -312304 -311301          imp:n=1 u=3858  tmp=2.533494e-08 $ Zirc pin                          
385808  3858 -5.755396 312303 -302303  311301 -311304  imp:n=1 u=3858  tmp=2.533494e-08 $ Fuel meat section 1                         
385809  3858 -5.755396 302303 -302306  311301 -311304  imp:n=1 u=3858  tmp=2.533494e-08 $ Fuel meat section 2                         
385810  3858 -5.755396 302306 -302309  311301 -311304  imp:n=1 u=3858  tmp=2.533494e-08 $ Fuel meat section 3                         
385811  3858 -5.755396 302309 -302312  311301 -311304  imp:n=1 u=3858  tmp=2.533494e-08 $ Fuel meat section 4                         
385812  3858 -5.755396 302312 -312304  311301 -311304  imp:n=1 u=3858  tmp=2.533494e-08 $ Fuel meat section 5                         
385813   106 -1.698     312304 -312305 -311304          imp:n=1 u=3858  $ Upper graphite spacer                         
385814   105 -7.85     312305 -312306 -311305          imp:n=1 u=3858  $ SS top cap                          
385815   105 -7.85     312306 -312307 -311303          imp:n=1 u=3858  $ Tri-flute                          
385816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3858 tmp=2.526170e-08 $ Water around tri-flute                          
385817   105 -7.85     312307 -312308 -311302          imp:n=1 u=3858  $ Fuel tip                         
385818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3858 tmp=2.526170e-08 $ Water around fuel tip                         
385819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3858 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3862 - SS clad (T0S210D210) universe --- 
c                         
386201   105 -7.85     312300 -312301 -311302          imp:n=1 u=3862  $ Lower grid plate pin                         
386202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3862 tmp=2.526170e-08 $ Water around grid plate pin                          
386203   105 -7.85     312301 -312302 -311305          imp:n=1 u=3862  $ Bottom casing                          
386204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3862 tmp=2.526170e-08 $ Water around fuel element                         
386205   106 -1.698     312302 -312303 -311304          imp:n=1 u=3862  $ Lower graphite slug                          
386206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3862  $ Fuel cladding                         
386207   108  0.042234 312303 -312304 -311301          imp:n=1 u=3862  tmp=2.533494e-08 $ Zirc pin                          
386208  3862 -5.754853 312303 -302303  311301 -311304  imp:n=1 u=3862  tmp=2.533494e-08 $ Fuel meat section 1                         
386209  3862 -5.754853 302303 -302306  311301 -311304  imp:n=1 u=3862  tmp=2.533494e-08 $ Fuel meat section 2                         
386210  3862 -5.754853 302306 -302309  311301 -311304  imp:n=1 u=3862  tmp=2.533494e-08 $ Fuel meat section 3                         
386211  3862 -5.754853 302309 -302312  311301 -311304  imp:n=1 u=3862  tmp=2.533494e-08 $ Fuel meat section 4                         
386212  3862 -5.754853 302312 -312304  311301 -311304  imp:n=1 u=3862  tmp=2.533494e-08 $ Fuel meat section 5                         
386213   106 -1.698     312304 -312305 -311304          imp:n=1 u=3862  $ Upper graphite spacer                         
386214   105 -7.85     312305 -312306 -311305          imp:n=1 u=3862  $ SS top cap                          
386215   105 -7.85     312306 -312307 -311303          imp:n=1 u=3862  $ Tri-flute                          
386216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3862 tmp=2.526170e-08 $ Water around tri-flute                          
386217   105 -7.85     312307 -312308 -311302          imp:n=1 u=3862  $ Fuel tip                         
386218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3862 tmp=2.526170e-08 $ Water around fuel tip                         
386219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3862 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3864 - SS clad (T0S210D210) universe --- 
c                         
386401   105 -7.85     312300 -312301 -311302          imp:n=1 u=3864  $ Lower grid plate pin                         
386402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3864 tmp=2.526170e-08 $ Water around grid plate pin                          
386403   105 -7.85     312301 -312302 -311305          imp:n=1 u=3864  $ Bottom casing                          
386404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3864 tmp=2.526170e-08 $ Water around fuel element                         
386405   106 -1.698     312302 -312303 -311304          imp:n=1 u=3864  $ Lower graphite slug                          
386406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3864  $ Fuel cladding                         
386407   108  0.042234 312303 -312304 -311301          imp:n=1 u=3864  tmp=2.533494e-08 $ Zirc pin                          
386408  3864 -5.909261 312303 -302303  311301 -311304  imp:n=1 u=3864  tmp=2.533494e-08 $ Fuel meat section 1                         
386409  3864 -5.909261 302303 -302306  311301 -311304  imp:n=1 u=3864  tmp=2.533494e-08 $ Fuel meat section 2                         
386410  3864 -5.909261 302306 -302309  311301 -311304  imp:n=1 u=3864  tmp=2.533494e-08 $ Fuel meat section 3                         
386411  3864 -5.909261 302309 -302312  311301 -311304  imp:n=1 u=3864  tmp=2.533494e-08 $ Fuel meat section 4                         
386412  3864 -5.909261 302312 -312304  311301 -311304  imp:n=1 u=3864  tmp=2.533494e-08 $ Fuel meat section 5                         
386413   106 -1.698     312304 -312305 -311304          imp:n=1 u=3864  $ Upper graphite spacer                         
386414   105 -7.85     312305 -312306 -311305          imp:n=1 u=3864  $ SS top cap                          
386415   105 -7.85     312306 -312307 -311303          imp:n=1 u=3864  $ Tri-flute                          
386416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3864 tmp=2.526170e-08 $ Water around tri-flute                          
386417   105 -7.85     312307 -312308 -311302          imp:n=1 u=3864  $ Fuel tip                         
386418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3864 tmp=2.526170e-08 $ Water around fuel tip                         
386419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3864 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3865 - SS clad (T0S210D210) universe --- 
c                         
386501   105 -7.85     312300 -312301 -311302          imp:n=1 u=3865  $ Lower grid plate pin                         
386502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3865 tmp=2.526170e-08 $ Water around grid plate pin                          
386503   105 -7.85     312301 -312302 -311305          imp:n=1 u=3865  $ Bottom casing                          
386504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3865 tmp=2.526170e-08 $ Water around fuel element                         
386505   106 -1.698     312302 -312303 -311304          imp:n=1 u=3865  $ Lower graphite slug                          
386506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3865  $ Fuel cladding                         
386507   108  0.042234 312303 -312304 -311301          imp:n=1 u=3865  tmp=2.533494e-08 $ Zirc pin                          
386508  3865 -5.766066 312303 -302303  311301 -311304  imp:n=1 u=3865  tmp=2.533494e-08 $ Fuel meat section 1                         
386509  3865 -5.766066 302303 -302306  311301 -311304  imp:n=1 u=3865  tmp=2.533494e-08 $ Fuel meat section 2                         
386510  3865 -5.766066 302306 -302309  311301 -311304  imp:n=1 u=3865  tmp=2.533494e-08 $ Fuel meat section 3                         
386511  3865 -5.766066 302309 -302312  311301 -311304  imp:n=1 u=3865  tmp=2.533494e-08 $ Fuel meat section 4                         
386512  3865 -5.766066 302312 -312304  311301 -311304  imp:n=1 u=3865  tmp=2.533494e-08 $ Fuel meat section 5                         
386513   106 -1.698     312304 -312305 -311304          imp:n=1 u=3865  $ Upper graphite spacer                         
386514   105 -7.85     312305 -312306 -311305          imp:n=1 u=3865  $ SS top cap                          
386515   105 -7.85     312306 -312307 -311303          imp:n=1 u=3865  $ Tri-flute                          
386516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3865 tmp=2.526170e-08 $ Water around tri-flute                          
386517   105 -7.85     312307 -312308 -311302          imp:n=1 u=3865  $ Fuel tip                         
386518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3865 tmp=2.526170e-08 $ Water around fuel tip                         
386519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3865 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3866 - SS clad (T0S210D210) universe --- 
c                         
386601   105 -7.85     312300 -312301 -311302          imp:n=1 u=3866  $ Lower grid plate pin                         
386602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3866 tmp=2.526170e-08 $ Water around grid plate pin                          
386603   105 -7.85     312301 -312302 -311305          imp:n=1 u=3866  $ Bottom casing                          
386604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3866 tmp=2.526170e-08 $ Water around fuel element                         
386605   106 -1.698     312302 -312303 -311304          imp:n=1 u=3866  $ Lower graphite slug                          
386606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3866  $ Fuel cladding                         
386607   108  0.042234 312303 -312304 -311301          imp:n=1 u=3866  tmp=2.533494e-08 $ Zirc pin                          
386608  3866 -5.917832 312303 -302303  311301 -311304  imp:n=1 u=3866  tmp=2.533494e-08 $ Fuel meat section 1                         
386609  3866 -5.917832 302303 -302306  311301 -311304  imp:n=1 u=3866  tmp=2.533494e-08 $ Fuel meat section 2                         
386610  3866 -5.917832 302306 -302309  311301 -311304  imp:n=1 u=3866  tmp=2.533494e-08 $ Fuel meat section 3                         
386611  3866 -5.917832 302309 -302312  311301 -311304  imp:n=1 u=3866  tmp=2.533494e-08 $ Fuel meat section 4                         
386612  3866 -5.917832 302312 -312304  311301 -311304  imp:n=1 u=3866  tmp=2.533494e-08 $ Fuel meat section 5                         
386613   106 -1.698     312304 -312305 -311304          imp:n=1 u=3866  $ Upper graphite spacer                         
386614   105 -7.85     312305 -312306 -311305          imp:n=1 u=3866  $ SS top cap                          
386615   105 -7.85     312306 -312307 -311303          imp:n=1 u=3866  $ Tri-flute                          
386616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3866 tmp=2.526170e-08 $ Water around tri-flute                          
386617   105 -7.85     312307 -312308 -311302          imp:n=1 u=3866  $ Fuel tip                         
386618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3866 tmp=2.526170e-08 $ Water around fuel tip                         
386619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3866 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3868 - SS clad (T0S210D210) universe --- 
c                         
386801   105 -7.85     312300 -312301 -311302          imp:n=1 u=3868  $ Lower grid plate pin                         
386802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3868 tmp=2.526170e-08 $ Water around grid plate pin                          
386803   105 -7.85     312301 -312302 -311305          imp:n=1 u=3868  $ Bottom casing                          
386804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3868 tmp=2.526170e-08 $ Water around fuel element                         
386805   106 -1.698     312302 -312303 -311304          imp:n=1 u=3868  $ Lower graphite slug                          
386806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3868  $ Fuel cladding                         
386807   108  0.042234 312303 -312304 -311301          imp:n=1 u=3868  tmp=2.533494e-08 $ Zirc pin                          
386808  3868 -5.763278 312303 -302303  311301 -311304  imp:n=1 u=3868  tmp=2.533494e-08 $ Fuel meat section 1                         
386809  3868 -5.763278 302303 -302306  311301 -311304  imp:n=1 u=3868  tmp=2.533494e-08 $ Fuel meat section 2                         
386810  3868 -5.763278 302306 -302309  311301 -311304  imp:n=1 u=3868  tmp=2.533494e-08 $ Fuel meat section 3                         
386811  3868 -5.763278 302309 -302312  311301 -311304  imp:n=1 u=3868  tmp=2.533494e-08 $ Fuel meat section 4                         
386812  3868 -5.763278 302312 -312304  311301 -311304  imp:n=1 u=3868  tmp=2.533494e-08 $ Fuel meat section 5                         
386813   106 -1.698     312304 -312305 -311304          imp:n=1 u=3868  $ Upper graphite spacer                         
386814   105 -7.85     312305 -312306 -311305          imp:n=1 u=3868  $ SS top cap                          
386815   105 -7.85     312306 -312307 -311303          imp:n=1 u=3868  $ Tri-flute                          
386816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3868 tmp=2.526170e-08 $ Water around tri-flute                          
386817   105 -7.85     312307 -312308 -311302          imp:n=1 u=3868  $ Fuel tip                         
386818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3868 tmp=2.526170e-08 $ Water around fuel tip                         
386819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3868 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3870 - SS clad (T0S210D210) universe --- 
c                         
387001   105 -7.85     312300 -312301 -311302          imp:n=1 u=3870  $ Lower grid plate pin                         
387002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3870 tmp=2.526170e-08 $ Water around grid plate pin                          
387003   105 -7.85     312301 -312302 -311305          imp:n=1 u=3870  $ Bottom casing                          
387004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3870 tmp=2.526170e-08 $ Water around fuel element                         
387005   106 -1.698     312302 -312303 -311304          imp:n=1 u=3870  $ Lower graphite slug                          
387006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3870  $ Fuel cladding                         
387007   108  0.042234 312303 -312304 -311301          imp:n=1 u=3870  tmp=2.533494e-08 $ Zirc pin                          
387008  3870 -5.75512 312303 -302303  311301 -311304  imp:n=1 u=3870  tmp=2.533494e-08 $ Fuel meat section 1                         
387009  3870 -5.75512 302303 -302306  311301 -311304  imp:n=1 u=3870  tmp=2.533494e-08 $ Fuel meat section 2                         
387010  3870 -5.75512 302306 -302309  311301 -311304  imp:n=1 u=3870  tmp=2.533494e-08 $ Fuel meat section 3                         
387011  3870 -5.75512 302309 -302312  311301 -311304  imp:n=1 u=3870  tmp=2.533494e-08 $ Fuel meat section 4                         
387012  3870 -5.75512 302312 -312304  311301 -311304  imp:n=1 u=3870  tmp=2.533494e-08 $ Fuel meat section 5                         
387013   106 -1.698     312304 -312305 -311304          imp:n=1 u=3870  $ Upper graphite spacer                         
387014   105 -7.85     312305 -312306 -311305          imp:n=1 u=3870  $ SS top cap                          
387015   105 -7.85     312306 -312307 -311303          imp:n=1 u=3870  $ Tri-flute                          
387016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3870 tmp=2.526170e-08 $ Water around tri-flute                          
387017   105 -7.85     312307 -312308 -311302          imp:n=1 u=3870  $ Fuel tip                         
387018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3870 tmp=2.526170e-08 $ Water around fuel tip                         
387019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3870 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3872 - SS clad (T0S210D210) universe --- 
c                         
387201   105 -7.85     312300 -312301 -311302          imp:n=1 u=3872  $ Lower grid plate pin                         
387202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3872 tmp=2.526170e-08 $ Water around grid plate pin                          
387203   105 -7.85     312301 -312302 -311305          imp:n=1 u=3872  $ Bottom casing                          
387204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3872 tmp=2.526170e-08 $ Water around fuel element                         
387205   106 -1.698     312302 -312303 -311304          imp:n=1 u=3872  $ Lower graphite slug                          
387206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3872  $ Fuel cladding                         
387207   108  0.042234 312303 -312304 -311301          imp:n=1 u=3872  tmp=2.533494e-08 $ Zirc pin                          
387208  3872 -5.905917 312303 -302303  311301 -311304  imp:n=1 u=3872  tmp=2.533494e-08 $ Fuel meat section 1                         
387209  3872 -5.905917 302303 -302306  311301 -311304  imp:n=1 u=3872  tmp=2.533494e-08 $ Fuel meat section 2                         
387210  3872 -5.905917 302306 -302309  311301 -311304  imp:n=1 u=3872  tmp=2.533494e-08 $ Fuel meat section 3                         
387211  3872 -5.905917 302309 -302312  311301 -311304  imp:n=1 u=3872  tmp=2.533494e-08 $ Fuel meat section 4                         
387212  3872 -5.905917 302312 -312304  311301 -311304  imp:n=1 u=3872  tmp=2.533494e-08 $ Fuel meat section 5                         
387213   106 -1.698     312304 -312305 -311304          imp:n=1 u=3872  $ Upper graphite spacer                         
387214   105 -7.85     312305 -312306 -311305          imp:n=1 u=3872  $ SS top cap                          
387215   105 -7.85     312306 -312307 -311303          imp:n=1 u=3872  $ Tri-flute                          
387216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3872 tmp=2.526170e-08 $ Water around tri-flute                          
387217   105 -7.85     312307 -312308 -311302          imp:n=1 u=3872  $ Fuel tip                         
387218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3872 tmp=2.526170e-08 $ Water around fuel tip                         
387219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3872 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 3874 - SS clad (T0S210D210) universe --- 
c                         
387401   105 -7.85     312300 -312301 -311302          imp:n=1 u=3874  $ Lower grid plate pin                         
387402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=3874 tmp=2.526170e-08 $ Water around grid plate pin                          
387403   105 -7.85     312301 -312302 -311305          imp:n=1 u=3874  $ Bottom casing                          
387404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=3874 tmp=2.526170e-08 $ Water around fuel element                         
387405   106 -1.698     312302 -312303 -311304          imp:n=1 u=3874  $ Lower graphite slug                          
387406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=3874  $ Fuel cladding                         
387407   108  0.042234 312303 -312304 -311301          imp:n=1 u=3874  tmp=2.533494e-08 $ Zirc pin                          
387408  3874 -5.769668 312303 -302303  311301 -311304  imp:n=1 u=3874  tmp=2.533494e-08 $ Fuel meat section 1                         
387409  3874 -5.769668 302303 -302306  311301 -311304  imp:n=1 u=3874  tmp=2.533494e-08 $ Fuel meat section 2                         
387410  3874 -5.769668 302306 -302309  311301 -311304  imp:n=1 u=3874  tmp=2.533494e-08 $ Fuel meat section 3                         
387411  3874 -5.769668 302309 -302312  311301 -311304  imp:n=1 u=3874  tmp=2.533494e-08 $ Fuel meat section 4                         
387412  3874 -5.769668 302312 -312304  311301 -311304  imp:n=1 u=3874  tmp=2.533494e-08 $ Fuel meat section 5                         
387413   106 -1.698     312304 -312305 -311304          imp:n=1 u=3874  $ Upper graphite spacer                         
387414   105 -7.85     312305 -312306 -311305          imp:n=1 u=3874  $ SS top cap                          
387415   105 -7.85     312306 -312307 -311303          imp:n=1 u=3874  $ Tri-flute                          
387416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=3874 tmp=2.526170e-08 $ Water around tri-flute                          
387417   105 -7.85     312307 -312308 -311302          imp:n=1 u=3874  $ Fuel tip                         
387418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=3874 tmp=2.526170e-08 $ Water around fuel tip                         
387419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=3874 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4046 - SS clad (T0S210D210) universe --- 
c                         
404601   105 -7.85     312300 -312301 -311302          imp:n=1 u=4046  $ Lower grid plate pin                         
404602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4046 tmp=2.526170e-08 $ Water around grid plate pin                          
404603   105 -7.85     312301 -312302 -311305          imp:n=1 u=4046  $ Bottom casing                          
404604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4046 tmp=2.526170e-08 $ Water around fuel element                         
404605   106 -1.698     312302 -312303 -311304          imp:n=1 u=4046  $ Lower graphite slug                          
404606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4046  $ Fuel cladding                         
404607   108  0.042234 312303 -312304 -311301          imp:n=1 u=4046  tmp=2.533494e-08 $ Zirc pin                          
404608  4046 -5.909753 312303 -302303  311301 -311304  imp:n=1 u=4046  tmp=2.533494e-08 $ Fuel meat section 1                         
404609  4046 -5.909753 302303 -302306  311301 -311304  imp:n=1 u=4046  tmp=2.533494e-08 $ Fuel meat section 2                         
404610  4046 -5.909753 302306 -302309  311301 -311304  imp:n=1 u=4046  tmp=2.533494e-08 $ Fuel meat section 3                         
404611  4046 -5.909753 302309 -302312  311301 -311304  imp:n=1 u=4046  tmp=2.533494e-08 $ Fuel meat section 4                         
404612  4046 -5.909753 302312 -312304  311301 -311304  imp:n=1 u=4046  tmp=2.533494e-08 $ Fuel meat section 5                         
404613   106 -1.698     312304 -312305 -311304          imp:n=1 u=4046  $ Upper graphite spacer                         
404614   105 -7.85     312305 -312306 -311305          imp:n=1 u=4046  $ SS top cap                          
404615   105 -7.85     312306 -312307 -311303          imp:n=1 u=4046  $ Tri-flute                          
404616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4046 tmp=2.526170e-08 $ Water around tri-flute                          
404617   105 -7.85     312307 -312308 -311302          imp:n=1 u=4046  $ Fuel tip                         
404618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4046 tmp=2.526170e-08 $ Water around fuel tip                         
404619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4046 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4049 - SS clad (T0S210D210) universe --- 
c                         
404901   105 -7.85     312300 -312301 -311302          imp:n=1 u=4049  $ Lower grid plate pin                         
404902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4049 tmp=2.526170e-08 $ Water around grid plate pin                          
404903   105 -7.85     312301 -312302 -311305          imp:n=1 u=4049  $ Bottom casing                          
404904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4049 tmp=2.526170e-08 $ Water around fuel element                         
404905   106 -1.698     312302 -312303 -311304          imp:n=1 u=4049  $ Lower graphite slug                          
404906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4049  $ Fuel cladding                         
404907   108  0.042234 312303 -312304 -311301          imp:n=1 u=4049  tmp=2.533494e-08 $ Zirc pin                          
404908  4049 -5.909062 312303 -302303  311301 -311304  imp:n=1 u=4049  tmp=2.533494e-08 $ Fuel meat section 1                         
404909  4049 -5.909062 302303 -302306  311301 -311304  imp:n=1 u=4049  tmp=2.533494e-08 $ Fuel meat section 2                         
404910  4049 -5.909062 302306 -302309  311301 -311304  imp:n=1 u=4049  tmp=2.533494e-08 $ Fuel meat section 3                         
404911  4049 -5.909062 302309 -302312  311301 -311304  imp:n=1 u=4049  tmp=2.533494e-08 $ Fuel meat section 4                         
404912  4049 -5.909062 302312 -312304  311301 -311304  imp:n=1 u=4049  tmp=2.533494e-08 $ Fuel meat section 5                         
404913   106 -1.698     312304 -312305 -311304          imp:n=1 u=4049  $ Upper graphite spacer                         
404914   105 -7.85     312305 -312306 -311305          imp:n=1 u=4049  $ SS top cap                          
404915   105 -7.85     312306 -312307 -311303          imp:n=1 u=4049  $ Tri-flute                          
404916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4049 tmp=2.526170e-08 $ Water around tri-flute                          
404917   105 -7.85     312307 -312308 -311302          imp:n=1 u=4049  $ Fuel tip                         
404918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4049 tmp=2.526170e-08 $ Water around fuel tip                         
404919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4049 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4050 - SS clad (T0S210D210) universe --- 
c                         
405001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4050  $ Lower grid plate pin                         
405002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4050 tmp=2.526170e-08 $ Water around grid plate pin                          
405003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4050  $ Bottom casing                          
405004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4050 tmp=2.526170e-08 $ Water around fuel element                         
405005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4050  $ Lower graphite slug                          
405006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4050  $ Fuel cladding                         
405007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4050  tmp=2.533494e-08 $ Zirc pin                          
405008  4050 -5.905406 312303 -302303  311301 -311304  imp:n=1 u=4050  tmp=2.533494e-08 $ Fuel meat section 1                         
405009  4050 -5.905406 302303 -302306  311301 -311304  imp:n=1 u=4050  tmp=2.533494e-08 $ Fuel meat section 2                         
405010  4050 -5.905406 302306 -302309  311301 -311304  imp:n=1 u=4050  tmp=2.533494e-08 $ Fuel meat section 3                         
405011  4050 -5.905406 302309 -302312  311301 -311304  imp:n=1 u=4050  tmp=2.533494e-08 $ Fuel meat section 4                         
405012  4050 -5.905406 302312 -312304  311301 -311304  imp:n=1 u=4050  tmp=2.533494e-08 $ Fuel meat section 5                         
405013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4050  $ Upper graphite spacer                         
405014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4050  $ SS top cap                          
405015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4050  $ Tri-flute                          
405016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4050 tmp=2.526170e-08 $ Water around tri-flute                          
405017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4050  $ Fuel tip                         
405018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4050 tmp=2.526170e-08 $ Water around fuel tip                         
405019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4050 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4053 - SS clad (T0S210D210) universe --- 
c                         
405301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4053  $ Lower grid plate pin                         
405302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4053 tmp=2.526170e-08 $ Water around grid plate pin                          
405303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4053  $ Bottom casing                          
405304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4053 tmp=2.526170e-08 $ Water around fuel element                         
405305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4053  $ Lower graphite slug                          
405306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4053  $ Fuel cladding                         
405307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4053  tmp=2.533494e-08 $ Zirc pin                          
405308  4053 -5.916091 312303 -302303  311301 -311304  imp:n=1 u=4053  tmp=2.533494e-08 $ Fuel meat section 1                         
405309  4053 -5.916091 302303 -302306  311301 -311304  imp:n=1 u=4053  tmp=2.533494e-08 $ Fuel meat section 2                         
405310  4053 -5.916091 302306 -302309  311301 -311304  imp:n=1 u=4053  tmp=2.533494e-08 $ Fuel meat section 3                         
405311  4053 -5.916091 302309 -302312  311301 -311304  imp:n=1 u=4053  tmp=2.533494e-08 $ Fuel meat section 4                         
405312  4053 -5.916091 302312 -312304  311301 -311304  imp:n=1 u=4053  tmp=2.533494e-08 $ Fuel meat section 5                         
405313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4053  $ Upper graphite spacer                         
405314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4053  $ SS top cap                          
405315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4053  $ Tri-flute                          
405316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4053 tmp=2.526170e-08 $ Water around tri-flute                          
405317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4053  $ Fuel tip                         
405318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4053 tmp=2.526170e-08 $ Water around fuel tip                         
405319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4053 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4054 - SS clad (T0S210D210) universe --- 
c                         
405401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4054  $ Lower grid plate pin                         
405402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4054 tmp=2.526170e-08 $ Water around grid plate pin                          
405403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4054  $ Bottom casing                          
405404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4054 tmp=2.526170e-08 $ Water around fuel element                         
405405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4054  $ Lower graphite slug                          
405406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4054  $ Fuel cladding                         
405407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4054  tmp=2.533494e-08 $ Zirc pin                          
405408  4054 -5.759574 312303 -302303  311301 -311304  imp:n=1 u=4054  tmp=2.533494e-08 $ Fuel meat section 1                         
405409  4054 -5.759574 302303 -302306  311301 -311304  imp:n=1 u=4054  tmp=2.533494e-08 $ Fuel meat section 2                         
405410  4054 -5.759574 302306 -302309  311301 -311304  imp:n=1 u=4054  tmp=2.533494e-08 $ Fuel meat section 3                         
405411  4054 -5.759574 302309 -302312  311301 -311304  imp:n=1 u=4054  tmp=2.533494e-08 $ Fuel meat section 4                         
405412  4054 -5.759574 302312 -312304  311301 -311304  imp:n=1 u=4054  tmp=2.533494e-08 $ Fuel meat section 5                         
405413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4054  $ Upper graphite spacer                         
405414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4054  $ SS top cap                          
405415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4054  $ Tri-flute                          
405416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4054 tmp=2.526170e-08 $ Water around tri-flute                          
405417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4054  $ Fuel tip                         
405418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4054 tmp=2.526170e-08 $ Water around fuel tip                         
405419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4054 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4055 - SS clad (T0S210D210) universe --- 
c                         
405501   105 -7.85     312300 -312301 -311302          imp:n=1 u=4055  $ Lower grid plate pin                         
405502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4055 tmp=2.526170e-08 $ Water around grid plate pin                          
405503   105 -7.85     312301 -312302 -311305          imp:n=1 u=4055  $ Bottom casing                          
405504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4055 tmp=2.526170e-08 $ Water around fuel element                         
405505   106 -1.698     312302 -312303 -311304          imp:n=1 u=4055  $ Lower graphite slug                          
405506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4055  $ Fuel cladding                         
405507   108  0.042234 312303 -312304 -311301          imp:n=1 u=4055  tmp=2.533494e-08 $ Zirc pin                          
405508  4055 -5.916033 312303 -302303  311301 -311304  imp:n=1 u=4055  tmp=2.533494e-08 $ Fuel meat section 1                         
405509  4055 -5.916033 302303 -302306  311301 -311304  imp:n=1 u=4055  tmp=2.533494e-08 $ Fuel meat section 2                         
405510  4055 -5.916033 302306 -302309  311301 -311304  imp:n=1 u=4055  tmp=2.533494e-08 $ Fuel meat section 3                         
405511  4055 -5.916033 302309 -302312  311301 -311304  imp:n=1 u=4055  tmp=2.533494e-08 $ Fuel meat section 4                         
405512  4055 -5.916033 302312 -312304  311301 -311304  imp:n=1 u=4055  tmp=2.533494e-08 $ Fuel meat section 5                         
405513   106 -1.698     312304 -312305 -311304          imp:n=1 u=4055  $ Upper graphite spacer                         
405514   105 -7.85     312305 -312306 -311305          imp:n=1 u=4055  $ SS top cap                          
405515   105 -7.85     312306 -312307 -311303          imp:n=1 u=4055  $ Tri-flute                          
405516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4055 tmp=2.526170e-08 $ Water around tri-flute                          
405517   105 -7.85     312307 -312308 -311302          imp:n=1 u=4055  $ Fuel tip                         
405518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4055 tmp=2.526170e-08 $ Water around fuel tip                         
405519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4055 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4057 - SS clad (T0S210D210) universe --- 
c                         
405701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4057  $ Lower grid plate pin                         
405702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4057 tmp=2.526170e-08 $ Water around grid plate pin                          
405703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4057  $ Bottom casing                          
405704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4057 tmp=2.526170e-08 $ Water around fuel element                         
405705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4057  $ Lower graphite slug                          
405706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4057  $ Fuel cladding                         
405707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4057  tmp=2.533494e-08 $ Zirc pin                          
405708  4057 -5.765107 312303 -302303  311301 -311304  imp:n=1 u=4057  tmp=2.533494e-08 $ Fuel meat section 1                         
405709  4057 -5.765107 302303 -302306  311301 -311304  imp:n=1 u=4057  tmp=2.533494e-08 $ Fuel meat section 2                         
405710  4057 -5.765107 302306 -302309  311301 -311304  imp:n=1 u=4057  tmp=2.533494e-08 $ Fuel meat section 3                         
405711  4057 -5.765107 302309 -302312  311301 -311304  imp:n=1 u=4057  tmp=2.533494e-08 $ Fuel meat section 4                         
405712  4057 -5.765107 302312 -312304  311301 -311304  imp:n=1 u=4057  tmp=2.533494e-08 $ Fuel meat section 5                         
405713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4057  $ Upper graphite spacer                         
405714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4057  $ SS top cap                          
405715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4057  $ Tri-flute                          
405716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4057 tmp=2.526170e-08 $ Water around tri-flute                          
405717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4057  $ Fuel tip                         
405718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4057 tmp=2.526170e-08 $ Water around fuel tip                         
405719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4057 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4060 - SS clad (T0S210D210) universe --- 
c                         
406001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4060  $ Lower grid plate pin                         
406002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4060 tmp=2.526170e-08 $ Water around grid plate pin                          
406003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4060  $ Bottom casing                          
406004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4060 tmp=2.526170e-08 $ Water around fuel element                         
406005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4060  $ Lower graphite slug                          
406006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4060  $ Fuel cladding                         
406007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4060  tmp=2.533494e-08 $ Zirc pin                          
406008  4060 -5.755088 312303 -302303  311301 -311304  imp:n=1 u=4060  tmp=2.533494e-08 $ Fuel meat section 1                         
406009  4060 -5.755088 302303 -302306  311301 -311304  imp:n=1 u=4060  tmp=2.533494e-08 $ Fuel meat section 2                         
406010  4060 -5.755088 302306 -302309  311301 -311304  imp:n=1 u=4060  tmp=2.533494e-08 $ Fuel meat section 3                         
406011  4060 -5.755088 302309 -302312  311301 -311304  imp:n=1 u=4060  tmp=2.533494e-08 $ Fuel meat section 4                         
406012  4060 -5.755088 302312 -312304  311301 -311304  imp:n=1 u=4060  tmp=2.533494e-08 $ Fuel meat section 5                         
406013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4060  $ Upper graphite spacer                         
406014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4060  $ SS top cap                          
406015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4060  $ Tri-flute                          
406016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4060 tmp=2.526170e-08 $ Water around tri-flute                          
406017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4060  $ Fuel tip                         
406018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4060 tmp=2.526170e-08 $ Water around fuel tip                         
406019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4060 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4061 - SS clad (T0S210D210) universe --- 
c                         
406101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4061  $ Lower grid plate pin                         
406102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4061 tmp=2.526170e-08 $ Water around grid plate pin                          
406103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4061  $ Bottom casing                          
406104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4061 tmp=2.526170e-08 $ Water around fuel element                         
406105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4061  $ Lower graphite slug                          
406106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4061  $ Fuel cladding                         
406107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4061  tmp=2.533494e-08 $ Zirc pin                          
406108  4061 -5.914925 312303 -302303  311301 -311304  imp:n=1 u=4061  tmp=2.533494e-08 $ Fuel meat section 1                         
406109  4061 -5.914925 302303 -302306  311301 -311304  imp:n=1 u=4061  tmp=2.533494e-08 $ Fuel meat section 2                         
406110  4061 -5.914925 302306 -302309  311301 -311304  imp:n=1 u=4061  tmp=2.533494e-08 $ Fuel meat section 3                         
406111  4061 -5.914925 302309 -302312  311301 -311304  imp:n=1 u=4061  tmp=2.533494e-08 $ Fuel meat section 4                         
406112  4061 -5.914925 302312 -312304  311301 -311304  imp:n=1 u=4061  tmp=2.533494e-08 $ Fuel meat section 5                         
406113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4061  $ Upper graphite spacer                         
406114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4061  $ SS top cap                          
406115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4061  $ Tri-flute                          
406116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4061 tmp=2.526170e-08 $ Water around tri-flute                          
406117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4061  $ Fuel tip                         
406118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4061 tmp=2.526170e-08 $ Water around fuel tip                         
406119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4061 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4062 - SS clad (T0S210D210) universe --- 
c                         
406201   105 -7.85     312300 -312301 -311302          imp:n=1 u=4062  $ Lower grid plate pin                         
406202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4062 tmp=2.526170e-08 $ Water around grid plate pin                          
406203   105 -7.85     312301 -312302 -311305          imp:n=1 u=4062  $ Bottom casing                          
406204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4062 tmp=2.526170e-08 $ Water around fuel element                         
406205   106 -1.698     312302 -312303 -311304          imp:n=1 u=4062  $ Lower graphite slug                          
406206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4062  $ Fuel cladding                         
406207   108  0.042234 312303 -312304 -311301          imp:n=1 u=4062  tmp=2.533494e-08 $ Zirc pin                          
406208  4062 -5.763905 312303 -302303  311301 -311304  imp:n=1 u=4062  tmp=2.533494e-08 $ Fuel meat section 1                         
406209  4062 -5.763905 302303 -302306  311301 -311304  imp:n=1 u=4062  tmp=2.533494e-08 $ Fuel meat section 2                         
406210  4062 -5.763905 302306 -302309  311301 -311304  imp:n=1 u=4062  tmp=2.533494e-08 $ Fuel meat section 3                         
406211  4062 -5.763905 302309 -302312  311301 -311304  imp:n=1 u=4062  tmp=2.533494e-08 $ Fuel meat section 4                         
406212  4062 -5.763905 302312 -312304  311301 -311304  imp:n=1 u=4062  tmp=2.533494e-08 $ Fuel meat section 5                         
406213   106 -1.698     312304 -312305 -311304          imp:n=1 u=4062  $ Upper graphite spacer                         
406214   105 -7.85     312305 -312306 -311305          imp:n=1 u=4062  $ SS top cap                          
406215   105 -7.85     312306 -312307 -311303          imp:n=1 u=4062  $ Tri-flute                          
406216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4062 tmp=2.526170e-08 $ Water around tri-flute                          
406217   105 -7.85     312307 -312308 -311302          imp:n=1 u=4062  $ Fuel tip                         
406218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4062 tmp=2.526170e-08 $ Water around fuel tip                         
406219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4062 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4063 - SS clad (T0S210D210) universe --- 
c                         
406301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4063  $ Lower grid plate pin                         
406302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4063 tmp=2.526170e-08 $ Water around grid plate pin                          
406303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4063  $ Bottom casing                          
406304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4063 tmp=2.526170e-08 $ Water around fuel element                         
406305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4063  $ Lower graphite slug                          
406306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4063  $ Fuel cladding                         
406307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4063  tmp=2.533494e-08 $ Zirc pin                          
406308  4063 -5.753071 312303 -302303  311301 -311304  imp:n=1 u=4063  tmp=2.533494e-08 $ Fuel meat section 1                         
406309  4063 -5.753071 302303 -302306  311301 -311304  imp:n=1 u=4063  tmp=2.533494e-08 $ Fuel meat section 2                         
406310  4063 -5.753071 302306 -302309  311301 -311304  imp:n=1 u=4063  tmp=2.533494e-08 $ Fuel meat section 3                         
406311  4063 -5.753071 302309 -302312  311301 -311304  imp:n=1 u=4063  tmp=2.533494e-08 $ Fuel meat section 4                         
406312  4063 -5.753071 302312 -312304  311301 -311304  imp:n=1 u=4063  tmp=2.533494e-08 $ Fuel meat section 5                         
406313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4063  $ Upper graphite spacer                         
406314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4063  $ SS top cap                          
406315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4063  $ Tri-flute                          
406316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4063 tmp=2.526170e-08 $ Water around tri-flute                          
406317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4063  $ Fuel tip                         
406318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4063 tmp=2.526170e-08 $ Water around fuel tip                         
406319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4063 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4064 - SS clad (T0S210D210) universe --- 
c                         
406401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4064  $ Lower grid plate pin                         
406402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4064 tmp=2.526170e-08 $ Water around grid plate pin                          
406403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4064  $ Bottom casing                          
406404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4064 tmp=2.526170e-08 $ Water around fuel element                         
406405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4064  $ Lower graphite slug                          
406406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4064  $ Fuel cladding                         
406407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4064  tmp=2.533494e-08 $ Zirc pin                          
406408  4064 -5.612743 312303 -302303  311301 -311304  imp:n=1 u=4064  tmp=2.533494e-08 $ Fuel meat section 1                         
406409  4064 -5.612743 302303 -302306  311301 -311304  imp:n=1 u=4064  tmp=2.533494e-08 $ Fuel meat section 2                         
406410  4064 -5.612743 302306 -302309  311301 -311304  imp:n=1 u=4064  tmp=2.533494e-08 $ Fuel meat section 3                         
406411  4064 -5.612743 302309 -302312  311301 -311304  imp:n=1 u=4064  tmp=2.533494e-08 $ Fuel meat section 4                         
406412  4064 -5.612743 302312 -312304  311301 -311304  imp:n=1 u=4064  tmp=2.533494e-08 $ Fuel meat section 5                         
406413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4064  $ Upper graphite spacer                         
406414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4064  $ SS top cap                          
406415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4064  $ Tri-flute                          
406416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4064 tmp=2.526170e-08 $ Water around tri-flute                          
406417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4064  $ Fuel tip                         
406418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4064 tmp=2.526170e-08 $ Water around fuel tip                         
406419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4064 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4065 - SS clad (T0S210D210) universe --- 
c                         
406501   105 -7.85     312300 -312301 -311302          imp:n=1 u=4065  $ Lower grid plate pin                         
406502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4065 tmp=2.526170e-08 $ Water around grid plate pin                          
406503   105 -7.85     312301 -312302 -311305          imp:n=1 u=4065  $ Bottom casing                          
406504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4065 tmp=2.526170e-08 $ Water around fuel element                         
406505   106 -1.698     312302 -312303 -311304          imp:n=1 u=4065  $ Lower graphite slug                          
406506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4065  $ Fuel cladding                         
406507   108  0.042234 312303 -312304 -311301          imp:n=1 u=4065  tmp=2.533494e-08 $ Zirc pin                          
406508  4065 -5.609396 312303 -302303  311301 -311304  imp:n=1 u=4065  tmp=2.533494e-08 $ Fuel meat section 1                         
406509  4065 -5.609396 302303 -302306  311301 -311304  imp:n=1 u=4065  tmp=2.533494e-08 $ Fuel meat section 2                         
406510  4065 -5.609396 302306 -302309  311301 -311304  imp:n=1 u=4065  tmp=2.533494e-08 $ Fuel meat section 3                         
406511  4065 -5.609396 302309 -302312  311301 -311304  imp:n=1 u=4065  tmp=2.533494e-08 $ Fuel meat section 4                         
406512  4065 -5.609396 302312 -312304  311301 -311304  imp:n=1 u=4065  tmp=2.533494e-08 $ Fuel meat section 5                         
406513   106 -1.698     312304 -312305 -311304          imp:n=1 u=4065  $ Upper graphite spacer                         
406514   105 -7.85     312305 -312306 -311305          imp:n=1 u=4065  $ SS top cap                          
406515   105 -7.85     312306 -312307 -311303          imp:n=1 u=4065  $ Tri-flute                          
406516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4065 tmp=2.526170e-08 $ Water around tri-flute                          
406517   105 -7.85     312307 -312308 -311302          imp:n=1 u=4065  $ Fuel tip                         
406518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4065 tmp=2.526170e-08 $ Water around fuel tip                         
406519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4065 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4066 - SS clad (T0S210D210) universe --- 
c                         
406601   105 -7.85     312300 -312301 -311302          imp:n=1 u=4066  $ Lower grid plate pin                         
406602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4066 tmp=2.526170e-08 $ Water around grid plate pin                          
406603   105 -7.85     312301 -312302 -311305          imp:n=1 u=4066  $ Bottom casing                          
406604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4066 tmp=2.526170e-08 $ Water around fuel element                         
406605   106 -1.698     312302 -312303 -311304          imp:n=1 u=4066  $ Lower graphite slug                          
406606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4066  $ Fuel cladding                         
406607   108  0.042234 312303 -312304 -311301          imp:n=1 u=4066  tmp=2.533494e-08 $ Zirc pin                          
406608  4066 -5.755591 312303 -302303  311301 -311304  imp:n=1 u=4066  tmp=2.533494e-08 $ Fuel meat section 1                         
406609  4066 -5.755591 302303 -302306  311301 -311304  imp:n=1 u=4066  tmp=2.533494e-08 $ Fuel meat section 2                         
406610  4066 -5.755591 302306 -302309  311301 -311304  imp:n=1 u=4066  tmp=2.533494e-08 $ Fuel meat section 3                         
406611  4066 -5.755591 302309 -302312  311301 -311304  imp:n=1 u=4066  tmp=2.533494e-08 $ Fuel meat section 4                         
406612  4066 -5.755591 302312 -312304  311301 -311304  imp:n=1 u=4066  tmp=2.533494e-08 $ Fuel meat section 5                         
406613   106 -1.698     312304 -312305 -311304          imp:n=1 u=4066  $ Upper graphite spacer                         
406614   105 -7.85     312305 -312306 -311305          imp:n=1 u=4066  $ SS top cap                          
406615   105 -7.85     312306 -312307 -311303          imp:n=1 u=4066  $ Tri-flute                          
406616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4066 tmp=2.526170e-08 $ Water around tri-flute                          
406617   105 -7.85     312307 -312308 -311302          imp:n=1 u=4066  $ Fuel tip                         
406618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4066 tmp=2.526170e-08 $ Water around fuel tip                         
406619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4066 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4068 - SS clad (T0S210D210) universe --- 
c                         
406801   105 -7.85     312300 -312301 -311302          imp:n=1 u=4068  $ Lower grid plate pin                         
406802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4068 tmp=2.526170e-08 $ Water around grid plate pin                          
406803   105 -7.85     312301 -312302 -311305          imp:n=1 u=4068  $ Bottom casing                          
406804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4068 tmp=2.526170e-08 $ Water around fuel element                         
406805   106 -1.698     312302 -312303 -311304          imp:n=1 u=4068  $ Lower graphite slug                          
406806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4068  $ Fuel cladding                         
406807   108  0.042234 312303 -312304 -311301          imp:n=1 u=4068  tmp=2.533494e-08 $ Zirc pin                          
406808  4068 -5.909109 312303 -302303  311301 -311304  imp:n=1 u=4068  tmp=2.533494e-08 $ Fuel meat section 1                         
406809  4068 -5.909109 302303 -302306  311301 -311304  imp:n=1 u=4068  tmp=2.533494e-08 $ Fuel meat section 2                         
406810  4068 -5.909109 302306 -302309  311301 -311304  imp:n=1 u=4068  tmp=2.533494e-08 $ Fuel meat section 3                         
406811  4068 -5.909109 302309 -302312  311301 -311304  imp:n=1 u=4068  tmp=2.533494e-08 $ Fuel meat section 4                         
406812  4068 -5.909109 302312 -312304  311301 -311304  imp:n=1 u=4068  tmp=2.533494e-08 $ Fuel meat section 5                         
406813   106 -1.698     312304 -312305 -311304          imp:n=1 u=4068  $ Upper graphite spacer                         
406814   105 -7.85     312305 -312306 -311305          imp:n=1 u=4068  $ SS top cap                          
406815   105 -7.85     312306 -312307 -311303          imp:n=1 u=4068  $ Tri-flute                          
406816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4068 tmp=2.526170e-08 $ Water around tri-flute                          
406817   105 -7.85     312307 -312308 -311302          imp:n=1 u=4068  $ Fuel tip                         
406818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4068 tmp=2.526170e-08 $ Water around fuel tip                         
406819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4068 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4069 - SS clad (T0S210D210) universe --- 
c                         
406901   105 -7.85     312300 -312301 -311302          imp:n=1 u=4069  $ Lower grid plate pin                         
406902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4069 tmp=2.526170e-08 $ Water around grid plate pin                          
406903   105 -7.85     312301 -312302 -311305          imp:n=1 u=4069  $ Bottom casing                          
406904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4069 tmp=2.526170e-08 $ Water around fuel element                         
406905   106 -1.698     312302 -312303 -311304          imp:n=1 u=4069  $ Lower graphite slug                          
406906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4069  $ Fuel cladding                         
406907   108  0.042234 312303 -312304 -311301          imp:n=1 u=4069  tmp=2.533494e-08 $ Zirc pin                          
406908  4069 -5.763906 312303 -302303  311301 -311304  imp:n=1 u=4069  tmp=2.533494e-08 $ Fuel meat section 1                         
406909  4069 -5.763906 302303 -302306  311301 -311304  imp:n=1 u=4069  tmp=2.533494e-08 $ Fuel meat section 2                         
406910  4069 -5.763906 302306 -302309  311301 -311304  imp:n=1 u=4069  tmp=2.533494e-08 $ Fuel meat section 3                         
406911  4069 -5.763906 302309 -302312  311301 -311304  imp:n=1 u=4069  tmp=2.533494e-08 $ Fuel meat section 4                         
406912  4069 -5.763906 302312 -312304  311301 -311304  imp:n=1 u=4069  tmp=2.533494e-08 $ Fuel meat section 5                         
406913   106 -1.698     312304 -312305 -311304          imp:n=1 u=4069  $ Upper graphite spacer                         
406914   105 -7.85     312305 -312306 -311305          imp:n=1 u=4069  $ SS top cap                          
406915   105 -7.85     312306 -312307 -311303          imp:n=1 u=4069  $ Tri-flute                          
406916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4069 tmp=2.526170e-08 $ Water around tri-flute                          
406917   105 -7.85     312307 -312308 -311302          imp:n=1 u=4069  $ Fuel tip                         
406918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4069 tmp=2.526170e-08 $ Water around fuel tip                         
406919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4069 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4070 - SS clad (T0S210D210) universe --- 
c                         
407001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4070  $ Lower grid plate pin                         
407002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4070 tmp=2.526170e-08 $ Water around grid plate pin                          
407003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4070  $ Bottom casing                          
407004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4070 tmp=2.526170e-08 $ Water around fuel element                         
407005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4070  $ Lower graphite slug                          
407006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4070  $ Fuel cladding                         
407007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4070  tmp=2.533494e-08 $ Zirc pin                          
407008  4070 -5.909872 312303 -302303  311301 -311304  imp:n=1 u=4070  tmp=2.533494e-08 $ Fuel meat section 1                         
407009  4070 -5.909872 302303 -302306  311301 -311304  imp:n=1 u=4070  tmp=2.533494e-08 $ Fuel meat section 2                         
407010  4070 -5.909872 302306 -302309  311301 -311304  imp:n=1 u=4070  tmp=2.533494e-08 $ Fuel meat section 3                         
407011  4070 -5.909872 302309 -302312  311301 -311304  imp:n=1 u=4070  tmp=2.533494e-08 $ Fuel meat section 4                         
407012  4070 -5.909872 302312 -312304  311301 -311304  imp:n=1 u=4070  tmp=2.533494e-08 $ Fuel meat section 5                         
407013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4070  $ Upper graphite spacer                         
407014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4070  $ SS top cap                          
407015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4070  $ Tri-flute                          
407016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4070 tmp=2.526170e-08 $ Water around tri-flute                          
407017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4070  $ Fuel tip                         
407018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4070 tmp=2.526170e-08 $ Water around fuel tip                         
407019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4070 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4071 - SS clad (T0S210D210) universe --- 
c                         
407101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4071  $ Lower grid plate pin                         
407102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4071 tmp=2.526170e-08 $ Water around grid plate pin                          
407103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4071  $ Bottom casing                          
407104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4071 tmp=2.526170e-08 $ Water around fuel element                         
407105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4071  $ Lower graphite slug                          
407106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4071  $ Fuel cladding                         
407107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4071  tmp=2.533494e-08 $ Zirc pin                          
407108  4071 -5.904785 312303 -302303  311301 -311304  imp:n=1 u=4071  tmp=2.533494e-08 $ Fuel meat section 1                         
407109  4071 -5.904785 302303 -302306  311301 -311304  imp:n=1 u=4071  tmp=2.533494e-08 $ Fuel meat section 2                         
407110  4071 -5.904785 302306 -302309  311301 -311304  imp:n=1 u=4071  tmp=2.533494e-08 $ Fuel meat section 3                         
407111  4071 -5.904785 302309 -302312  311301 -311304  imp:n=1 u=4071  tmp=2.533494e-08 $ Fuel meat section 4                         
407112  4071 -5.904785 302312 -312304  311301 -311304  imp:n=1 u=4071  tmp=2.533494e-08 $ Fuel meat section 5                         
407113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4071  $ Upper graphite spacer                         
407114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4071  $ SS top cap                          
407115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4071  $ Tri-flute                          
407116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4071 tmp=2.526170e-08 $ Water around tri-flute                          
407117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4071  $ Fuel tip                         
407118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4071 tmp=2.526170e-08 $ Water around fuel tip                         
407119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4071 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4074 - SS clad (T0S210D210) universe --- 
c                         
407401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4074  $ Lower grid plate pin                         
407402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4074 tmp=2.526170e-08 $ Water around grid plate pin                          
407403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4074  $ Bottom casing                          
407404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4074 tmp=2.526170e-08 $ Water around fuel element                         
407405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4074  $ Lower graphite slug                          
407406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4074  $ Fuel cladding                         
407407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4074  tmp=2.533494e-08 $ Zirc pin                          
407408  4074 -5.764527 312303 -302303  311301 -311304  imp:n=1 u=4074  tmp=2.533494e-08 $ Fuel meat section 1                         
407409  4074 -5.764527 302303 -302306  311301 -311304  imp:n=1 u=4074  tmp=2.533494e-08 $ Fuel meat section 2                         
407410  4074 -5.764527 302306 -302309  311301 -311304  imp:n=1 u=4074  tmp=2.533494e-08 $ Fuel meat section 3                         
407411  4074 -5.764527 302309 -302312  311301 -311304  imp:n=1 u=4074  tmp=2.533494e-08 $ Fuel meat section 4                         
407412  4074 -5.764527 302312 -312304  311301 -311304  imp:n=1 u=4074  tmp=2.533494e-08 $ Fuel meat section 5                         
407413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4074  $ Upper graphite spacer                         
407414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4074  $ SS top cap                          
407415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4074  $ Tri-flute                          
407416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4074 tmp=2.526170e-08 $ Water around tri-flute                          
407417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4074  $ Fuel tip                         
407418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4074 tmp=2.526170e-08 $ Water around fuel tip                         
407419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4074 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4077 - SS clad (T0S210D210) universe --- 
c                         
407701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4077  $ Lower grid plate pin                         
407702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4077 tmp=2.526170e-08 $ Water around grid plate pin                          
407703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4077  $ Bottom casing                          
407704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4077 tmp=2.526170e-08 $ Water around fuel element                         
407705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4077  $ Lower graphite slug                          
407706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4077  $ Fuel cladding                         
407707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4077  tmp=2.533494e-08 $ Zirc pin                          
407708  4077 -5.757898 312303 -302303  311301 -311304  imp:n=1 u=4077  tmp=2.533494e-08 $ Fuel meat section 1                         
407709  4077 -5.757898 302303 -302306  311301 -311304  imp:n=1 u=4077  tmp=2.533494e-08 $ Fuel meat section 2                         
407710  4077 -5.757898 302306 -302309  311301 -311304  imp:n=1 u=4077  tmp=2.533494e-08 $ Fuel meat section 3                         
407711  4077 -5.757898 302309 -302312  311301 -311304  imp:n=1 u=4077  tmp=2.533494e-08 $ Fuel meat section 4                         
407712  4077 -5.757898 302312 -312304  311301 -311304  imp:n=1 u=4077  tmp=2.533494e-08 $ Fuel meat section 5                         
407713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4077  $ Upper graphite spacer                         
407714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4077  $ SS top cap                          
407715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4077  $ Tri-flute                          
407716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4077 tmp=2.526170e-08 $ Water around tri-flute                          
407717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4077  $ Fuel tip                         
407718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4077 tmp=2.526170e-08 $ Water around fuel tip                         
407719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4077 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4081 - SS clad (T0S210D210) universe --- 
c                         
408101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4081  $ Lower grid plate pin                         
408102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4081 tmp=2.526170e-08 $ Water around grid plate pin                          
408103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4081  $ Bottom casing                          
408104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4081 tmp=2.526170e-08 $ Water around fuel element                         
408105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4081  $ Lower graphite slug                          
408106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4081  $ Fuel cladding                         
408107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4081  tmp=2.533494e-08 $ Zirc pin                          
408108  4081 -5.758117 312303 -302303  311301 -311304  imp:n=1 u=4081  tmp=2.533494e-08 $ Fuel meat section 1                         
408109  4081 -5.758117 302303 -302306  311301 -311304  imp:n=1 u=4081  tmp=2.533494e-08 $ Fuel meat section 2                         
408110  4081 -5.758117 302306 -302309  311301 -311304  imp:n=1 u=4081  tmp=2.533494e-08 $ Fuel meat section 3                         
408111  4081 -5.758117 302309 -302312  311301 -311304  imp:n=1 u=4081  tmp=2.533494e-08 $ Fuel meat section 4                         
408112  4081 -5.758117 302312 -312304  311301 -311304  imp:n=1 u=4081  tmp=2.533494e-08 $ Fuel meat section 5                         
408113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4081  $ Upper graphite spacer                         
408114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4081  $ SS top cap                          
408115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4081  $ Tri-flute                          
408116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4081 tmp=2.526170e-08 $ Water around tri-flute                          
408117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4081  $ Fuel tip                         
408118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4081 tmp=2.526170e-08 $ Water around fuel tip                         
408119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4081 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4082 - SS clad (T0S210D210) universe --- 
c                         
408201   105 -7.85     312300 -312301 -311302          imp:n=1 u=4082  $ Lower grid plate pin                         
408202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4082 tmp=2.526170e-08 $ Water around grid plate pin                          
408203   105 -7.85     312301 -312302 -311305          imp:n=1 u=4082  $ Bottom casing                          
408204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4082 tmp=2.526170e-08 $ Water around fuel element                         
408205   106 -1.698     312302 -312303 -311304          imp:n=1 u=4082  $ Lower graphite slug                          
408206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4082  $ Fuel cladding                         
408207   108  0.042234 312303 -312304 -311301          imp:n=1 u=4082  tmp=2.533494e-08 $ Zirc pin                          
408208  4082 -5.758727 312303 -302303  311301 -311304  imp:n=1 u=4082  tmp=2.533494e-08 $ Fuel meat section 1                         
408209  4082 -5.758727 302303 -302306  311301 -311304  imp:n=1 u=4082  tmp=2.533494e-08 $ Fuel meat section 2                         
408210  4082 -5.758727 302306 -302309  311301 -311304  imp:n=1 u=4082  tmp=2.533494e-08 $ Fuel meat section 3                         
408211  4082 -5.758727 302309 -302312  311301 -311304  imp:n=1 u=4082  tmp=2.533494e-08 $ Fuel meat section 4                         
408212  4082 -5.758727 302312 -312304  311301 -311304  imp:n=1 u=4082  tmp=2.533494e-08 $ Fuel meat section 5                         
408213   106 -1.698     312304 -312305 -311304          imp:n=1 u=4082  $ Upper graphite spacer                         
408214   105 -7.85     312305 -312306 -311305          imp:n=1 u=4082  $ SS top cap                          
408215   105 -7.85     312306 -312307 -311303          imp:n=1 u=4082  $ Tri-flute                          
408216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4082 tmp=2.526170e-08 $ Water around tri-flute                          
408217   105 -7.85     312307 -312308 -311302          imp:n=1 u=4082  $ Fuel tip                         
408218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4082 tmp=2.526170e-08 $ Water around fuel tip                         
408219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4082 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4083 - SS clad (T0S210D210) universe --- 
c                         
408301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4083  $ Lower grid plate pin                         
408302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4083 tmp=2.526170e-08 $ Water around grid plate pin                          
408303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4083  $ Bottom casing                          
408304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4083 tmp=2.526170e-08 $ Water around fuel element                         
408305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4083  $ Lower graphite slug                          
408306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4083  $ Fuel cladding                         
408307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4083  tmp=2.533494e-08 $ Zirc pin                          
408308  4083 -5.90739 312303 -302303  311301 -311304  imp:n=1 u=4083  tmp=2.533494e-08 $ Fuel meat section 1                         
408309  4083 -5.90739 302303 -302306  311301 -311304  imp:n=1 u=4083  tmp=2.533494e-08 $ Fuel meat section 2                         
408310  4083 -5.90739 302306 -302309  311301 -311304  imp:n=1 u=4083  tmp=2.533494e-08 $ Fuel meat section 3                         
408311  4083 -5.90739 302309 -302312  311301 -311304  imp:n=1 u=4083  tmp=2.533494e-08 $ Fuel meat section 4                         
408312  4083 -5.90739 302312 -312304  311301 -311304  imp:n=1 u=4083  tmp=2.533494e-08 $ Fuel meat section 5                         
408313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4083  $ Upper graphite spacer                         
408314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4083  $ SS top cap                          
408315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4083  $ Tri-flute                          
408316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4083 tmp=2.526170e-08 $ Water around tri-flute                          
408317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4083  $ Fuel tip                         
408318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4083 tmp=2.526170e-08 $ Water around fuel tip                         
408319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4083 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4085 - SS clad (T0S210D210) universe --- 
c                         
408501   105 -7.85     312300 -312301 -311302          imp:n=1 u=4085  $ Lower grid plate pin                         
408502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4085 tmp=2.526170e-08 $ Water around grid plate pin                          
408503   105 -7.85     312301 -312302 -311305          imp:n=1 u=4085  $ Bottom casing                          
408504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4085 tmp=2.526170e-08 $ Water around fuel element                         
408505   106 -1.698     312302 -312303 -311304          imp:n=1 u=4085  $ Lower graphite slug                          
408506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4085  $ Fuel cladding                         
408507   108  0.042234 312303 -312304 -311301          imp:n=1 u=4085  tmp=2.533494e-08 $ Zirc pin                          
408508  4085 -5.613857 312303 -302303  311301 -311304  imp:n=1 u=4085  tmp=2.533494e-08 $ Fuel meat section 1                         
408509  4085 -5.613857 302303 -302306  311301 -311304  imp:n=1 u=4085  tmp=2.533494e-08 $ Fuel meat section 2                         
408510  4085 -5.613857 302306 -302309  311301 -311304  imp:n=1 u=4085  tmp=2.533494e-08 $ Fuel meat section 3                         
408511  4085 -5.613857 302309 -302312  311301 -311304  imp:n=1 u=4085  tmp=2.533494e-08 $ Fuel meat section 4                         
408512  4085 -5.613857 302312 -312304  311301 -311304  imp:n=1 u=4085  tmp=2.533494e-08 $ Fuel meat section 5                         
408513   106 -1.698     312304 -312305 -311304          imp:n=1 u=4085  $ Upper graphite spacer                         
408514   105 -7.85     312305 -312306 -311305          imp:n=1 u=4085  $ SS top cap                          
408515   105 -7.85     312306 -312307 -311303          imp:n=1 u=4085  $ Tri-flute                          
408516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4085 tmp=2.526170e-08 $ Water around tri-flute                          
408517   105 -7.85     312307 -312308 -311302          imp:n=1 u=4085  $ Fuel tip                         
408518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4085 tmp=2.526170e-08 $ Water around fuel tip                         
408519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4085 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4086 - SS clad (T0S210D210) universe --- 
c                         
408601   105 -7.85     312300 -312301 -311302          imp:n=1 u=4086  $ Lower grid plate pin                         
408602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4086 tmp=2.526170e-08 $ Water around grid plate pin                          
408603   105 -7.85     312301 -312302 -311305          imp:n=1 u=4086  $ Bottom casing                          
408604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4086 tmp=2.526170e-08 $ Water around fuel element                         
408605   106 -1.698     312302 -312303 -311304          imp:n=1 u=4086  $ Lower graphite slug                          
408606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4086  $ Fuel cladding                         
408607   108  0.042234 312303 -312304 -311301          imp:n=1 u=4086  tmp=2.533494e-08 $ Zirc pin                          
408608  4086 -5.757715 312303 -302303  311301 -311304  imp:n=1 u=4086  tmp=2.533494e-08 $ Fuel meat section 1                         
408609  4086 -5.757715 302303 -302306  311301 -311304  imp:n=1 u=4086  tmp=2.533494e-08 $ Fuel meat section 2                         
408610  4086 -5.757715 302306 -302309  311301 -311304  imp:n=1 u=4086  tmp=2.533494e-08 $ Fuel meat section 3                         
408611  4086 -5.757715 302309 -302312  311301 -311304  imp:n=1 u=4086  tmp=2.533494e-08 $ Fuel meat section 4                         
408612  4086 -5.757715 302312 -312304  311301 -311304  imp:n=1 u=4086  tmp=2.533494e-08 $ Fuel meat section 5                         
408613   106 -1.698     312304 -312305 -311304          imp:n=1 u=4086  $ Upper graphite spacer                         
408614   105 -7.85     312305 -312306 -311305          imp:n=1 u=4086  $ SS top cap                          
408615   105 -7.85     312306 -312307 -311303          imp:n=1 u=4086  $ Tri-flute                          
408616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4086 tmp=2.526170e-08 $ Water around tri-flute                          
408617   105 -7.85     312307 -312308 -311302          imp:n=1 u=4086  $ Fuel tip                         
408618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4086 tmp=2.526170e-08 $ Water around fuel tip                         
408619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4086 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4087 - SS clad (T0S210D210) universe --- 
c                         
408701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4087  $ Lower grid plate pin                         
408702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4087 tmp=2.526170e-08 $ Water around grid plate pin                          
408703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4087  $ Bottom casing                          
408704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4087 tmp=2.526170e-08 $ Water around fuel element                         
408705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4087  $ Lower graphite slug                          
408706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4087  $ Fuel cladding                         
408707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4087  tmp=2.533494e-08 $ Zirc pin                          
408708  4087 -5.761648 312303 -302303  311301 -311304  imp:n=1 u=4087  tmp=2.533494e-08 $ Fuel meat section 1                         
408709  4087 -5.761648 302303 -302306  311301 -311304  imp:n=1 u=4087  tmp=2.533494e-08 $ Fuel meat section 2                         
408710  4087 -5.761648 302306 -302309  311301 -311304  imp:n=1 u=4087  tmp=2.533494e-08 $ Fuel meat section 3                         
408711  4087 -5.761648 302309 -302312  311301 -311304  imp:n=1 u=4087  tmp=2.533494e-08 $ Fuel meat section 4                         
408712  4087 -5.761648 302312 -312304  311301 -311304  imp:n=1 u=4087  tmp=2.533494e-08 $ Fuel meat section 5                         
408713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4087  $ Upper graphite spacer                         
408714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4087  $ SS top cap                          
408715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4087  $ Tri-flute                          
408716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4087 tmp=2.526170e-08 $ Water around tri-flute                          
408717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4087  $ Fuel tip                         
408718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4087 tmp=2.526170e-08 $ Water around fuel tip                         
408719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4087 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4088 - SS clad (T0S210D210) universe --- 
c                         
408801   105 -7.85     312300 -312301 -311302          imp:n=1 u=4088  $ Lower grid plate pin                         
408802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4088 tmp=2.526170e-08 $ Water around grid plate pin                          
408803   105 -7.85     312301 -312302 -311305          imp:n=1 u=4088  $ Bottom casing                          
408804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4088 tmp=2.526170e-08 $ Water around fuel element                         
408805   106 -1.698     312302 -312303 -311304          imp:n=1 u=4088  $ Lower graphite slug                          
408806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4088  $ Fuel cladding                         
408807   108  0.042234 312303 -312304 -311301          imp:n=1 u=4088  tmp=2.533494e-08 $ Zirc pin                          
408808  4088 -5.606623 312303 -302303  311301 -311304  imp:n=1 u=4088  tmp=2.533494e-08 $ Fuel meat section 1                         
408809  4088 -5.606623 302303 -302306  311301 -311304  imp:n=1 u=4088  tmp=2.533494e-08 $ Fuel meat section 2                         
408810  4088 -5.606623 302306 -302309  311301 -311304  imp:n=1 u=4088  tmp=2.533494e-08 $ Fuel meat section 3                         
408811  4088 -5.606623 302309 -302312  311301 -311304  imp:n=1 u=4088  tmp=2.533494e-08 $ Fuel meat section 4                         
408812  4088 -5.606623 302312 -312304  311301 -311304  imp:n=1 u=4088  tmp=2.533494e-08 $ Fuel meat section 5                         
408813   106 -1.698     312304 -312305 -311304          imp:n=1 u=4088  $ Upper graphite spacer                         
408814   105 -7.85     312305 -312306 -311305          imp:n=1 u=4088  $ SS top cap                          
408815   105 -7.85     312306 -312307 -311303          imp:n=1 u=4088  $ Tri-flute                          
408816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4088 tmp=2.526170e-08 $ Water around tri-flute                          
408817   105 -7.85     312307 -312308 -311302          imp:n=1 u=4088  $ Fuel tip                         
408818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4088 tmp=2.526170e-08 $ Water around fuel tip                         
408819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4088 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4090 - SS clad (T0S210D210) universe --- 
c                         
409001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4090  $ Lower grid plate pin                         
409002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4090 tmp=2.526170e-08 $ Water around grid plate pin                          
409003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4090  $ Bottom casing                          
409004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4090 tmp=2.526170e-08 $ Water around fuel element                         
409005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4090  $ Lower graphite slug                          
409006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4090  $ Fuel cladding                         
409007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4090  tmp=2.533494e-08 $ Zirc pin                          
409008  4090 -5.90985 312303 -302303  311301 -311304  imp:n=1 u=4090  tmp=2.533494e-08 $ Fuel meat section 1                         
409009  4090 -5.90985 302303 -302306  311301 -311304  imp:n=1 u=4090  tmp=2.533494e-08 $ Fuel meat section 2                         
409010  4090 -5.90985 302306 -302309  311301 -311304  imp:n=1 u=4090  tmp=2.533494e-08 $ Fuel meat section 3                         
409011  4090 -5.90985 302309 -302312  311301 -311304  imp:n=1 u=4090  tmp=2.533494e-08 $ Fuel meat section 4                         
409012  4090 -5.90985 302312 -312304  311301 -311304  imp:n=1 u=4090  tmp=2.533494e-08 $ Fuel meat section 5                         
409013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4090  $ Upper graphite spacer                         
409014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4090  $ SS top cap                          
409015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4090  $ Tri-flute                          
409016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4090 tmp=2.526170e-08 $ Water around tri-flute                          
409017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4090  $ Fuel tip                         
409018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4090 tmp=2.526170e-08 $ Water around fuel tip                         
409019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4090 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4091 - SS clad (T0S210D210) universe --- 
c                         
409101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4091  $ Lower grid plate pin                         
409102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4091 tmp=2.526170e-08 $ Water around grid plate pin                          
409103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4091  $ Bottom casing                          
409104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4091 tmp=2.526170e-08 $ Water around fuel element                         
409105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4091  $ Lower graphite slug                          
409106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4091  $ Fuel cladding                         
409107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4091  tmp=2.533494e-08 $ Zirc pin                          
409108  4091 -5.915099 312303 -302303  311301 -311304  imp:n=1 u=4091  tmp=2.533494e-08 $ Fuel meat section 1                         
409109  4091 -5.915099 302303 -302306  311301 -311304  imp:n=1 u=4091  tmp=2.533494e-08 $ Fuel meat section 2                         
409110  4091 -5.915099 302306 -302309  311301 -311304  imp:n=1 u=4091  tmp=2.533494e-08 $ Fuel meat section 3                         
409111  4091 -5.915099 302309 -302312  311301 -311304  imp:n=1 u=4091  tmp=2.533494e-08 $ Fuel meat section 4                         
409112  4091 -5.915099 302312 -312304  311301 -311304  imp:n=1 u=4091  tmp=2.533494e-08 $ Fuel meat section 5                         
409113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4091  $ Upper graphite spacer                         
409114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4091  $ SS top cap                          
409115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4091  $ Tri-flute                          
409116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4091 tmp=2.526170e-08 $ Water around tri-flute                          
409117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4091  $ Fuel tip                         
409118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4091 tmp=2.526170e-08 $ Water around fuel tip                         
409119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4091 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4094 - SS clad (T0S210D210) universe --- 
c                         
409401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4094  $ Lower grid plate pin                         
409402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4094 tmp=2.526170e-08 $ Water around grid plate pin                          
409403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4094  $ Bottom casing                          
409404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4094 tmp=2.526170e-08 $ Water around fuel element                         
409405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4094  $ Lower graphite slug                          
409406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4094  $ Fuel cladding                         
409407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4094  tmp=2.533494e-08 $ Zirc pin                          
409408  4094 -5.764454 312303 -302303  311301 -311304  imp:n=1 u=4094  tmp=2.533494e-08 $ Fuel meat section 1                         
409409  4094 -5.764454 302303 -302306  311301 -311304  imp:n=1 u=4094  tmp=2.533494e-08 $ Fuel meat section 2                         
409410  4094 -5.764454 302306 -302309  311301 -311304  imp:n=1 u=4094  tmp=2.533494e-08 $ Fuel meat section 3                         
409411  4094 -5.764454 302309 -302312  311301 -311304  imp:n=1 u=4094  tmp=2.533494e-08 $ Fuel meat section 4                         
409412  4094 -5.764454 302312 -312304  311301 -311304  imp:n=1 u=4094  tmp=2.533494e-08 $ Fuel meat section 5                         
409413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4094  $ Upper graphite spacer                         
409414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4094  $ SS top cap                          
409415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4094  $ Tri-flute                          
409416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4094 tmp=2.526170e-08 $ Water around tri-flute                          
409417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4094  $ Fuel tip                         
409418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4094 tmp=2.526170e-08 $ Water around fuel tip                         
409419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4094 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4095 - SS clad (T0S210D210) universe --- 
c                         
409501   105 -7.85     312300 -312301 -311302          imp:n=1 u=4095  $ Lower grid plate pin                         
409502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4095 tmp=2.526170e-08 $ Water around grid plate pin                          
409503   105 -7.85     312301 -312302 -311305          imp:n=1 u=4095  $ Bottom casing                          
409504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4095 tmp=2.526170e-08 $ Water around fuel element                         
409505   106 -1.698     312302 -312303 -311304          imp:n=1 u=4095  $ Lower graphite slug                          
409506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4095  $ Fuel cladding                         
409507   108  0.042234 312303 -312304 -311301          imp:n=1 u=4095  tmp=2.533494e-08 $ Zirc pin                          
409508  4095 -5.760724 312303 -302303  311301 -311304  imp:n=1 u=4095  tmp=2.533494e-08 $ Fuel meat section 1                         
409509  4095 -5.760724 302303 -302306  311301 -311304  imp:n=1 u=4095  tmp=2.533494e-08 $ Fuel meat section 2                         
409510  4095 -5.760724 302306 -302309  311301 -311304  imp:n=1 u=4095  tmp=2.533494e-08 $ Fuel meat section 3                         
409511  4095 -5.760724 302309 -302312  311301 -311304  imp:n=1 u=4095  tmp=2.533494e-08 $ Fuel meat section 4                         
409512  4095 -5.760724 302312 -312304  311301 -311304  imp:n=1 u=4095  tmp=2.533494e-08 $ Fuel meat section 5                         
409513   106 -1.698     312304 -312305 -311304          imp:n=1 u=4095  $ Upper graphite spacer                         
409514   105 -7.85     312305 -312306 -311305          imp:n=1 u=4095  $ SS top cap                          
409515   105 -7.85     312306 -312307 -311303          imp:n=1 u=4095  $ Tri-flute                          
409516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4095 tmp=2.526170e-08 $ Water around tri-flute                          
409517   105 -7.85     312307 -312308 -311302          imp:n=1 u=4095  $ Fuel tip                         
409518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4095 tmp=2.526170e-08 $ Water around fuel tip                         
409519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4095 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4103 - SS clad (T0S210D210) universe --- 
c                         
410301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4103  $ Lower grid plate pin                         
410302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4103 tmp=2.526170e-08 $ Water around grid plate pin                          
410303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4103  $ Bottom casing                          
410304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4103 tmp=2.526170e-08 $ Water around fuel element                         
410305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4103  $ Lower graphite slug                          
410306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4103  $ Fuel cladding                         
410307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4103  tmp=2.533494e-08 $ Zirc pin                          
410308  4103 -5.758342 312303 -302303  311301 -311304  imp:n=1 u=4103  tmp=2.533494e-08 $ Fuel meat section 1                         
410309  4103 -5.758342 302303 -302306  311301 -311304  imp:n=1 u=4103  tmp=2.533494e-08 $ Fuel meat section 2                         
410310  4103 -5.758342 302306 -302309  311301 -311304  imp:n=1 u=4103  tmp=2.533494e-08 $ Fuel meat section 3                         
410311  4103 -5.758342 302309 -302312  311301 -311304  imp:n=1 u=4103  tmp=2.533494e-08 $ Fuel meat section 4                         
410312  4103 -5.758342 302312 -312304  311301 -311304  imp:n=1 u=4103  tmp=2.533494e-08 $ Fuel meat section 5                         
410313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4103  $ Upper graphite spacer                         
410314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4103  $ SS top cap                          
410315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4103  $ Tri-flute                          
410316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4103 tmp=2.526170e-08 $ Water around tri-flute                          
410317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4103  $ Fuel tip                         
410318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4103 tmp=2.526170e-08 $ Water around fuel tip                         
410319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4103 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4104 - SS clad (T0S210D210) universe --- 
c                         
410401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4104  $ Lower grid plate pin                         
410402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4104 tmp=2.526170e-08 $ Water around grid plate pin                          
410403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4104  $ Bottom casing                          
410404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4104 tmp=2.526170e-08 $ Water around fuel element                         
410405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4104  $ Lower graphite slug                          
410406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4104  $ Fuel cladding                         
410407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4104  tmp=2.533494e-08 $ Zirc pin                          
410408  4104 -5.757734 312303 -302303  311301 -311304  imp:n=1 u=4104  tmp=2.533494e-08 $ Fuel meat section 1                         
410409  4104 -5.757734 302303 -302306  311301 -311304  imp:n=1 u=4104  tmp=2.533494e-08 $ Fuel meat section 2                         
410410  4104 -5.757734 302306 -302309  311301 -311304  imp:n=1 u=4104  tmp=2.533494e-08 $ Fuel meat section 3                         
410411  4104 -5.757734 302309 -302312  311301 -311304  imp:n=1 u=4104  tmp=2.533494e-08 $ Fuel meat section 4                         
410412  4104 -5.757734 302312 -312304  311301 -311304  imp:n=1 u=4104  tmp=2.533494e-08 $ Fuel meat section 5                         
410413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4104  $ Upper graphite spacer                         
410414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4104  $ SS top cap                          
410415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4104  $ Tri-flute                          
410416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4104 tmp=2.526170e-08 $ Water around tri-flute                          
410417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4104  $ Fuel tip                         
410418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4104 tmp=2.526170e-08 $ Water around fuel tip                         
410419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4104 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4106 - SS clad (T0S210D210) universe --- 
c                         
410601   105 -7.85     312300 -312301 -311302          imp:n=1 u=4106  $ Lower grid plate pin                         
410602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4106 tmp=2.526170e-08 $ Water around grid plate pin                          
410603   105 -7.85     312301 -312302 -311305          imp:n=1 u=4106  $ Bottom casing                          
410604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4106 tmp=2.526170e-08 $ Water around fuel element                         
410605   106 -1.698     312302 -312303 -311304          imp:n=1 u=4106  $ Lower graphite slug                          
410606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4106  $ Fuel cladding                         
410607   108  0.042234 312303 -312304 -311301          imp:n=1 u=4106  tmp=2.533494e-08 $ Zirc pin                          
410608  4106 -5.609121 312303 -302303  311301 -311304  imp:n=1 u=4106  tmp=2.533494e-08 $ Fuel meat section 1                         
410609  4106 -5.609121 302303 -302306  311301 -311304  imp:n=1 u=4106  tmp=2.533494e-08 $ Fuel meat section 2                         
410610  4106 -5.609121 302306 -302309  311301 -311304  imp:n=1 u=4106  tmp=2.533494e-08 $ Fuel meat section 3                         
410611  4106 -5.609121 302309 -302312  311301 -311304  imp:n=1 u=4106  tmp=2.533494e-08 $ Fuel meat section 4                         
410612  4106 -5.609121 302312 -312304  311301 -311304  imp:n=1 u=4106  tmp=2.533494e-08 $ Fuel meat section 5                         
410613   106 -1.698     312304 -312305 -311304          imp:n=1 u=4106  $ Upper graphite spacer                         
410614   105 -7.85     312305 -312306 -311305          imp:n=1 u=4106  $ SS top cap                          
410615   105 -7.85     312306 -312307 -311303          imp:n=1 u=4106  $ Tri-flute                          
410616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4106 tmp=2.526170e-08 $ Water around tri-flute                          
410617   105 -7.85     312307 -312308 -311302          imp:n=1 u=4106  $ Fuel tip                         
410618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4106 tmp=2.526170e-08 $ Water around fuel tip                         
410619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4106 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4107 - SS clad (T0S210D210) universe --- 
c                         
410701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4107  $ Lower grid plate pin                         
410702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4107 tmp=2.526170e-08 $ Water around grid plate pin                          
410703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4107  $ Bottom casing                          
410704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4107 tmp=2.526170e-08 $ Water around fuel element                         
410705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4107  $ Lower graphite slug                          
410706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4107  $ Fuel cladding                         
410707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4107  tmp=2.533494e-08 $ Zirc pin                          
410708  4107 -5.761044 312303 -302303  311301 -311304  imp:n=1 u=4107  tmp=2.533494e-08 $ Fuel meat section 1                         
410709  4107 -5.761044 302303 -302306  311301 -311304  imp:n=1 u=4107  tmp=2.533494e-08 $ Fuel meat section 2                         
410710  4107 -5.761044 302306 -302309  311301 -311304  imp:n=1 u=4107  tmp=2.533494e-08 $ Fuel meat section 3                         
410711  4107 -5.761044 302309 -302312  311301 -311304  imp:n=1 u=4107  tmp=2.533494e-08 $ Fuel meat section 4                         
410712  4107 -5.761044 302312 -312304  311301 -311304  imp:n=1 u=4107  tmp=2.533494e-08 $ Fuel meat section 5                         
410713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4107  $ Upper graphite spacer                         
410714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4107  $ SS top cap                          
410715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4107  $ Tri-flute                          
410716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4107 tmp=2.526170e-08 $ Water around tri-flute                          
410717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4107  $ Fuel tip                         
410718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4107 tmp=2.526170e-08 $ Water around fuel tip                         
410719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4107 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4110 - SS clad (T0S210D210) universe --- 
c                         
411001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4110  $ Lower grid plate pin                         
411002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4110 tmp=2.526170e-08 $ Water around grid plate pin                          
411003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4110  $ Bottom casing                          
411004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4110 tmp=2.526170e-08 $ Water around fuel element                         
411005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4110  $ Lower graphite slug                          
411006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4110  $ Fuel cladding                         
411007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4110  tmp=2.533494e-08 $ Zirc pin                          
411008  4110 -5.912645 312303 -302303  311301 -311304  imp:n=1 u=4110  tmp=2.533494e-08 $ Fuel meat section 1                         
411009  4110 -5.912645 302303 -302306  311301 -311304  imp:n=1 u=4110  tmp=2.533494e-08 $ Fuel meat section 2                         
411010  4110 -5.912645 302306 -302309  311301 -311304  imp:n=1 u=4110  tmp=2.533494e-08 $ Fuel meat section 3                         
411011  4110 -5.912645 302309 -302312  311301 -311304  imp:n=1 u=4110  tmp=2.533494e-08 $ Fuel meat section 4                         
411012  4110 -5.912645 302312 -312304  311301 -311304  imp:n=1 u=4110  tmp=2.533494e-08 $ Fuel meat section 5                         
411013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4110  $ Upper graphite spacer                         
411014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4110  $ SS top cap                          
411015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4110  $ Tri-flute                          
411016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4110 tmp=2.526170e-08 $ Water around tri-flute                          
411017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4110  $ Fuel tip                         
411018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4110 tmp=2.526170e-08 $ Water around fuel tip                         
411019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4110 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4111 - SS clad (T0S210D210) universe --- 
c                         
411101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4111  $ Lower grid plate pin                         
411102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4111 tmp=2.526170e-08 $ Water around grid plate pin                          
411103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4111  $ Bottom casing                          
411104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4111 tmp=2.526170e-08 $ Water around fuel element                         
411105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4111  $ Lower graphite slug                          
411106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4111  $ Fuel cladding                         
411107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4111  tmp=2.533494e-08 $ Zirc pin                          
411108  4111 -5.76177 312303 -302303  311301 -311304  imp:n=1 u=4111  tmp=2.533494e-08 $ Fuel meat section 1                         
411109  4111 -5.76177 302303 -302306  311301 -311304  imp:n=1 u=4111  tmp=2.533494e-08 $ Fuel meat section 2                         
411110  4111 -5.76177 302306 -302309  311301 -311304  imp:n=1 u=4111  tmp=2.533494e-08 $ Fuel meat section 3                         
411111  4111 -5.76177 302309 -302312  311301 -311304  imp:n=1 u=4111  tmp=2.533494e-08 $ Fuel meat section 4                         
411112  4111 -5.76177 302312 -312304  311301 -311304  imp:n=1 u=4111  tmp=2.533494e-08 $ Fuel meat section 5                         
411113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4111  $ Upper graphite spacer                         
411114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4111  $ SS top cap                          
411115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4111  $ Tri-flute                          
411116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4111 tmp=2.526170e-08 $ Water around tri-flute                          
411117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4111  $ Fuel tip                         
411118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4111 tmp=2.526170e-08 $ Water around fuel tip                         
411119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4111 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4113 - SS clad (T0S210D210) universe --- 
c                         
411301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4113  $ Lower grid plate pin                         
411302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4113 tmp=2.526170e-08 $ Water around grid plate pin                          
411303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4113  $ Bottom casing                          
411304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4113 tmp=2.526170e-08 $ Water around fuel element                         
411305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4113  $ Lower graphite slug                          
411306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4113  $ Fuel cladding                         
411307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4113  tmp=2.533494e-08 $ Zirc pin                          
411308  4113 -5.911109 312303 -302303  311301 -311304  imp:n=1 u=4113  tmp=2.533494e-08 $ Fuel meat section 1                         
411309  4113 -5.911109 302303 -302306  311301 -311304  imp:n=1 u=4113  tmp=2.533494e-08 $ Fuel meat section 2                         
411310  4113 -5.911109 302306 -302309  311301 -311304  imp:n=1 u=4113  tmp=2.533494e-08 $ Fuel meat section 3                         
411311  4113 -5.911109 302309 -302312  311301 -311304  imp:n=1 u=4113  tmp=2.533494e-08 $ Fuel meat section 4                         
411312  4113 -5.911109 302312 -312304  311301 -311304  imp:n=1 u=4113  tmp=2.533494e-08 $ Fuel meat section 5                         
411313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4113  $ Upper graphite spacer                         
411314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4113  $ SS top cap                          
411315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4113  $ Tri-flute                          
411316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4113 tmp=2.526170e-08 $ Water around tri-flute                          
411317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4113  $ Fuel tip                         
411318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4113 tmp=2.526170e-08 $ Water around fuel tip                         
411319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4113 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4114 - SS clad (T0S210D210) universe --- 
c                         
411401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4114  $ Lower grid plate pin                         
411402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4114 tmp=2.526170e-08 $ Water around grid plate pin                          
411403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4114  $ Bottom casing                          
411404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4114 tmp=2.526170e-08 $ Water around fuel element                         
411405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4114  $ Lower graphite slug                          
411406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4114  $ Fuel cladding                         
411407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4114  tmp=2.533494e-08 $ Zirc pin                          
411408  4114 -5.764488 312303 -302303  311301 -311304  imp:n=1 u=4114  tmp=2.533494e-08 $ Fuel meat section 1                         
411409  4114 -5.764488 302303 -302306  311301 -311304  imp:n=1 u=4114  tmp=2.533494e-08 $ Fuel meat section 2                         
411410  4114 -5.764488 302306 -302309  311301 -311304  imp:n=1 u=4114  tmp=2.533494e-08 $ Fuel meat section 3                         
411411  4114 -5.764488 302309 -302312  311301 -311304  imp:n=1 u=4114  tmp=2.533494e-08 $ Fuel meat section 4                         
411412  4114 -5.764488 302312 -312304  311301 -311304  imp:n=1 u=4114  tmp=2.533494e-08 $ Fuel meat section 5                         
411413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4114  $ Upper graphite spacer                         
411414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4114  $ SS top cap                          
411415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4114  $ Tri-flute                          
411416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4114 tmp=2.526170e-08 $ Water around tri-flute                          
411417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4114  $ Fuel tip                         
411418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4114 tmp=2.526170e-08 $ Water around fuel tip                         
411419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4114 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4117 - SS clad (T0S210D210) universe --- 
c                         
411701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4117  $ Lower grid plate pin                         
411702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4117 tmp=2.526170e-08 $ Water around grid plate pin                          
411703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4117  $ Bottom casing                          
411704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4117 tmp=2.526170e-08 $ Water around fuel element                         
411705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4117  $ Lower graphite slug                          
411706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4117  $ Fuel cladding                         
411707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4117  tmp=2.533494e-08 $ Zirc pin                          
411708  4117 -5.764705 312303 -302303  311301 -311304  imp:n=1 u=4117  tmp=2.533494e-08 $ Fuel meat section 1                         
411709  4117 -5.764705 302303 -302306  311301 -311304  imp:n=1 u=4117  tmp=2.533494e-08 $ Fuel meat section 2                         
411710  4117 -5.764705 302306 -302309  311301 -311304  imp:n=1 u=4117  tmp=2.533494e-08 $ Fuel meat section 3                         
411711  4117 -5.764705 302309 -302312  311301 -311304  imp:n=1 u=4117  tmp=2.533494e-08 $ Fuel meat section 4                         
411712  4117 -5.764705 302312 -312304  311301 -311304  imp:n=1 u=4117  tmp=2.533494e-08 $ Fuel meat section 5                         
411713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4117  $ Upper graphite spacer                         
411714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4117  $ SS top cap                          
411715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4117  $ Tri-flute                          
411716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4117 tmp=2.526170e-08 $ Water around tri-flute                          
411717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4117  $ Fuel tip                         
411718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4117 tmp=2.526170e-08 $ Water around fuel tip                         
411719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4117 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4118 - SS clad (T0S210D210) universe --- 
c                         
411801   105 -7.85     312300 -312301 -311302          imp:n=1 u=4118  $ Lower grid plate pin                         
411802   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4118 tmp=2.526170e-08 $ Water around grid plate pin                          
411803   105 -7.85     312301 -312302 -311305          imp:n=1 u=4118  $ Bottom casing                          
411804   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4118 tmp=2.526170e-08 $ Water around fuel element                         
411805   106 -1.698     312302 -312303 -311304          imp:n=1 u=4118  $ Lower graphite slug                          
411806   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4118  $ Fuel cladding                         
411807   108  0.042234 312303 -312304 -311301          imp:n=1 u=4118  tmp=2.533494e-08 $ Zirc pin                          
411808  4118 -5.916015 312303 -302303  311301 -311304  imp:n=1 u=4118  tmp=2.533494e-08 $ Fuel meat section 1                         
411809  4118 -5.916015 302303 -302306  311301 -311304  imp:n=1 u=4118  tmp=2.533494e-08 $ Fuel meat section 2                         
411810  4118 -5.916015 302306 -302309  311301 -311304  imp:n=1 u=4118  tmp=2.533494e-08 $ Fuel meat section 3                         
411811  4118 -5.916015 302309 -302312  311301 -311304  imp:n=1 u=4118  tmp=2.533494e-08 $ Fuel meat section 4                         
411812  4118 -5.916015 302312 -312304  311301 -311304  imp:n=1 u=4118  tmp=2.533494e-08 $ Fuel meat section 5                         
411813   106 -1.698     312304 -312305 -311304          imp:n=1 u=4118  $ Upper graphite spacer                         
411814   105 -7.85     312305 -312306 -311305          imp:n=1 u=4118  $ SS top cap                          
411815   105 -7.85     312306 -312307 -311303          imp:n=1 u=4118  $ Tri-flute                          
411816   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4118 tmp=2.526170e-08 $ Water around tri-flute                          
411817   105 -7.85     312307 -312308 -311302          imp:n=1 u=4118  $ Fuel tip                         
411818   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4118 tmp=2.526170e-08 $ Water around fuel tip                         
411819   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4118 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4119 - SS clad (T0S210D210) universe --- 
c                         
411901   105 -7.85     312300 -312301 -311302          imp:n=1 u=4119  $ Lower grid plate pin                         
411902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4119 tmp=2.526170e-08 $ Water around grid plate pin                          
411903   105 -7.85     312301 -312302 -311305          imp:n=1 u=4119  $ Bottom casing                          
411904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4119 tmp=2.526170e-08 $ Water around fuel element                         
411905   106 -1.698     312302 -312303 -311304          imp:n=1 u=4119  $ Lower graphite slug                          
411906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4119  $ Fuel cladding                         
411907   108  0.042234 312303 -312304 -311301          imp:n=1 u=4119  tmp=2.533494e-08 $ Zirc pin                          
411908  4119 -5.758865 312303 -302303  311301 -311304  imp:n=1 u=4119  tmp=2.533494e-08 $ Fuel meat section 1                         
411909  4119 -5.758865 302303 -302306  311301 -311304  imp:n=1 u=4119  tmp=2.533494e-08 $ Fuel meat section 2                         
411910  4119 -5.758865 302306 -302309  311301 -311304  imp:n=1 u=4119  tmp=2.533494e-08 $ Fuel meat section 3                         
411911  4119 -5.758865 302309 -302312  311301 -311304  imp:n=1 u=4119  tmp=2.533494e-08 $ Fuel meat section 4                         
411912  4119 -5.758865 302312 -312304  311301 -311304  imp:n=1 u=4119  tmp=2.533494e-08 $ Fuel meat section 5                         
411913   106 -1.698     312304 -312305 -311304          imp:n=1 u=4119  $ Upper graphite spacer                         
411914   105 -7.85     312305 -312306 -311305          imp:n=1 u=4119  $ SS top cap                          
411915   105 -7.85     312306 -312307 -311303          imp:n=1 u=4119  $ Tri-flute                          
411916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4119 tmp=2.526170e-08 $ Water around tri-flute                          
411917   105 -7.85     312307 -312308 -311302          imp:n=1 u=4119  $ Fuel tip                         
411918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4119 tmp=2.526170e-08 $ Water around fuel tip                         
411919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4119 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4120 - SS clad (T0S210D210) universe --- 
c                         
412001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4120  $ Lower grid plate pin                         
412002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4120 tmp=2.526170e-08 $ Water around grid plate pin                          
412003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4120  $ Bottom casing                          
412004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4120 tmp=2.526170e-08 $ Water around fuel element                         
412005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4120  $ Lower graphite slug                          
412006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4120  $ Fuel cladding                         
412007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4120  tmp=2.533494e-08 $ Zirc pin                          
412008  4120 -5.915418 312303 -302303  311301 -311304  imp:n=1 u=4120  tmp=2.533494e-08 $ Fuel meat section 1                         
412009  4120 -5.915418 302303 -302306  311301 -311304  imp:n=1 u=4120  tmp=2.533494e-08 $ Fuel meat section 2                         
412010  4120 -5.915418 302306 -302309  311301 -311304  imp:n=1 u=4120  tmp=2.533494e-08 $ Fuel meat section 3                         
412011  4120 -5.915418 302309 -302312  311301 -311304  imp:n=1 u=4120  tmp=2.533494e-08 $ Fuel meat section 4                         
412012  4120 -5.915418 302312 -312304  311301 -311304  imp:n=1 u=4120  tmp=2.533494e-08 $ Fuel meat section 5                         
412013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4120  $ Upper graphite spacer                         
412014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4120  $ SS top cap                          
412015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4120  $ Tri-flute                          
412016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4120 tmp=2.526170e-08 $ Water around tri-flute                          
412017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4120  $ Fuel tip                         
412018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4120 tmp=2.526170e-08 $ Water around fuel tip                         
412019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4120 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4121 - SS clad (T0S210D210) universe --- 
c                         
412101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4121  $ Lower grid plate pin                         
412102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4121 tmp=2.526170e-08 $ Water around grid plate pin                          
412103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4121  $ Bottom casing                          
412104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4121 tmp=2.526170e-08 $ Water around fuel element                         
412105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4121  $ Lower graphite slug                          
412106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4121  $ Fuel cladding                         
412107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4121  tmp=2.533494e-08 $ Zirc pin                          
412108  4121 -5.915912 312303 -302303  311301 -311304  imp:n=1 u=4121  tmp=2.533494e-08 $ Fuel meat section 1                         
412109  4121 -5.915912 302303 -302306  311301 -311304  imp:n=1 u=4121  tmp=2.533494e-08 $ Fuel meat section 2                         
412110  4121 -5.915912 302306 -302309  311301 -311304  imp:n=1 u=4121  tmp=2.533494e-08 $ Fuel meat section 3                         
412111  4121 -5.915912 302309 -302312  311301 -311304  imp:n=1 u=4121  tmp=2.533494e-08 $ Fuel meat section 4                         
412112  4121 -5.915912 302312 -312304  311301 -311304  imp:n=1 u=4121  tmp=2.533494e-08 $ Fuel meat section 5                         
412113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4121  $ Upper graphite spacer                         
412114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4121  $ SS top cap                          
412115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4121  $ Tri-flute                          
412116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4121 tmp=2.526170e-08 $ Water around tri-flute                          
412117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4121  $ Fuel tip                         
412118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4121 tmp=2.526170e-08 $ Water around fuel tip                         
412119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4121 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4122 - SS clad (T0S210D210) universe --- 
c                         
412201   105 -7.85     312300 -312301 -311302          imp:n=1 u=4122  $ Lower grid plate pin                         
412202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4122 tmp=2.526170e-08 $ Water around grid plate pin                          
412203   105 -7.85     312301 -312302 -311305          imp:n=1 u=4122  $ Bottom casing                          
412204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4122 tmp=2.526170e-08 $ Water around fuel element                         
412205   106 -1.698     312302 -312303 -311304          imp:n=1 u=4122  $ Lower graphite slug                          
412206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4122  $ Fuel cladding                         
412207   108  0.042234 312303 -312304 -311301          imp:n=1 u=4122  tmp=2.533494e-08 $ Zirc pin                          
412208  4122 -5.608894 312303 -302303  311301 -311304  imp:n=1 u=4122  tmp=2.533494e-08 $ Fuel meat section 1                         
412209  4122 -5.608894 302303 -302306  311301 -311304  imp:n=1 u=4122  tmp=2.533494e-08 $ Fuel meat section 2                         
412210  4122 -5.608894 302306 -302309  311301 -311304  imp:n=1 u=4122  tmp=2.533494e-08 $ Fuel meat section 3                         
412211  4122 -5.608894 302309 -302312  311301 -311304  imp:n=1 u=4122  tmp=2.533494e-08 $ Fuel meat section 4                         
412212  4122 -5.608894 302312 -312304  311301 -311304  imp:n=1 u=4122  tmp=2.533494e-08 $ Fuel meat section 5                         
412213   106 -1.698     312304 -312305 -311304          imp:n=1 u=4122  $ Upper graphite spacer                         
412214   105 -7.85     312305 -312306 -311305          imp:n=1 u=4122  $ SS top cap                          
412215   105 -7.85     312306 -312307 -311303          imp:n=1 u=4122  $ Tri-flute                          
412216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4122 tmp=2.526170e-08 $ Water around tri-flute                          
412217   105 -7.85     312307 -312308 -311302          imp:n=1 u=4122  $ Fuel tip                         
412218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4122 tmp=2.526170e-08 $ Water around fuel tip                         
412219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4122 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4123 - SS clad (T0S210D210) universe --- 
c                         
412301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4123  $ Lower grid plate pin                         
412302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4123 tmp=2.526170e-08 $ Water around grid plate pin                          
412303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4123  $ Bottom casing                          
412304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4123 tmp=2.526170e-08 $ Water around fuel element                         
412305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4123  $ Lower graphite slug                          
412306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4123  $ Fuel cladding                         
412307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4123  tmp=2.533494e-08 $ Zirc pin                          
412308  4123 -5.90375 312303 -302303  311301 -311304  imp:n=1 u=4123  tmp=2.533494e-08 $ Fuel meat section 1                         
412309  4123 -5.90375 302303 -302306  311301 -311304  imp:n=1 u=4123  tmp=2.533494e-08 $ Fuel meat section 2                         
412310  4123 -5.90375 302306 -302309  311301 -311304  imp:n=1 u=4123  tmp=2.533494e-08 $ Fuel meat section 3                         
412311  4123 -5.90375 302309 -302312  311301 -311304  imp:n=1 u=4123  tmp=2.533494e-08 $ Fuel meat section 4                         
412312  4123 -5.90375 302312 -312304  311301 -311304  imp:n=1 u=4123  tmp=2.533494e-08 $ Fuel meat section 5                         
412313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4123  $ Upper graphite spacer                         
412314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4123  $ SS top cap                          
412315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4123  $ Tri-flute                          
412316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4123 tmp=2.526170e-08 $ Water around tri-flute                          
412317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4123  $ Fuel tip                         
412318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4123 tmp=2.526170e-08 $ Water around fuel tip                         
412319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4123 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4125 - SS clad (T0S210D210) universe --- 
c                         
412501   105 -7.85     312300 -312301 -311302          imp:n=1 u=4125  $ Lower grid plate pin                         
412502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4125 tmp=2.526170e-08 $ Water around grid plate pin                          
412503   105 -7.85     312301 -312302 -311305          imp:n=1 u=4125  $ Bottom casing                          
412504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4125 tmp=2.526170e-08 $ Water around fuel element                         
412505   106 -1.698     312302 -312303 -311304          imp:n=1 u=4125  $ Lower graphite slug                          
412506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4125  $ Fuel cladding                         
412507   108  0.042234 312303 -312304 -311301          imp:n=1 u=4125  tmp=2.533494e-08 $ Zirc pin                          
412508  4125 -5.754676 312303 -302303  311301 -311304  imp:n=1 u=4125  tmp=2.533494e-08 $ Fuel meat section 1                         
412509  4125 -5.754676 302303 -302306  311301 -311304  imp:n=1 u=4125  tmp=2.533494e-08 $ Fuel meat section 2                         
412510  4125 -5.754676 302306 -302309  311301 -311304  imp:n=1 u=4125  tmp=2.533494e-08 $ Fuel meat section 3                         
412511  4125 -5.754676 302309 -302312  311301 -311304  imp:n=1 u=4125  tmp=2.533494e-08 $ Fuel meat section 4                         
412512  4125 -5.754676 302312 -312304  311301 -311304  imp:n=1 u=4125  tmp=2.533494e-08 $ Fuel meat section 5                         
412513   106 -1.698     312304 -312305 -311304          imp:n=1 u=4125  $ Upper graphite spacer                         
412514   105 -7.85     312305 -312306 -311305          imp:n=1 u=4125  $ SS top cap                          
412515   105 -7.85     312306 -312307 -311303          imp:n=1 u=4125  $ Tri-flute                          
412516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4125 tmp=2.526170e-08 $ Water around tri-flute                          
412517   105 -7.85     312307 -312308 -311302          imp:n=1 u=4125  $ Fuel tip                         
412518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4125 tmp=2.526170e-08 $ Water around fuel tip                         
412519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4125 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4126 - SS clad (T0S210D210) universe --- 
c                         
412601   105 -7.85     312300 -312301 -311302          imp:n=1 u=4126  $ Lower grid plate pin                         
412602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4126 tmp=2.526170e-08 $ Water around grid plate pin                          
412603   105 -7.85     312301 -312302 -311305          imp:n=1 u=4126  $ Bottom casing                          
412604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4126 tmp=2.526170e-08 $ Water around fuel element                         
412605   106 -1.698     312302 -312303 -311304          imp:n=1 u=4126  $ Lower graphite slug                          
412606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4126  $ Fuel cladding                         
412607   108  0.042234 312303 -312304 -311301          imp:n=1 u=4126  tmp=2.533494e-08 $ Zirc pin                          
412608  4126 -5.760188 312303 -302303  311301 -311304  imp:n=1 u=4126  tmp=2.533494e-08 $ Fuel meat section 1                         
412609  4126 -5.760188 302303 -302306  311301 -311304  imp:n=1 u=4126  tmp=2.533494e-08 $ Fuel meat section 2                         
412610  4126 -5.760188 302306 -302309  311301 -311304  imp:n=1 u=4126  tmp=2.533494e-08 $ Fuel meat section 3                         
412611  4126 -5.760188 302309 -302312  311301 -311304  imp:n=1 u=4126  tmp=2.533494e-08 $ Fuel meat section 4                         
412612  4126 -5.760188 302312 -312304  311301 -311304  imp:n=1 u=4126  tmp=2.533494e-08 $ Fuel meat section 5                         
412613   106 -1.698     312304 -312305 -311304          imp:n=1 u=4126  $ Upper graphite spacer                         
412614   105 -7.85     312305 -312306 -311305          imp:n=1 u=4126  $ SS top cap                          
412615   105 -7.85     312306 -312307 -311303          imp:n=1 u=4126  $ Tri-flute                          
412616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4126 tmp=2.526170e-08 $ Water around tri-flute                          
412617   105 -7.85     312307 -312308 -311302          imp:n=1 u=4126  $ Fuel tip                         
412618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4126 tmp=2.526170e-08 $ Water around fuel tip                         
412619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4126 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4127 - SS clad (T0S210D210) universe --- 
c                         
412701   105 -7.85     312300 -312301 -311302          imp:n=1 u=4127  $ Lower grid plate pin                         
412702   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4127 tmp=2.526170e-08 $ Water around grid plate pin                          
412703   105 -7.85     312301 -312302 -311305          imp:n=1 u=4127  $ Bottom casing                          
412704   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4127 tmp=2.526170e-08 $ Water around fuel element                         
412705   106 -1.698     312302 -312303 -311304          imp:n=1 u=4127  $ Lower graphite slug                          
412706   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4127  $ Fuel cladding                         
412707   108  0.042234 312303 -312304 -311301          imp:n=1 u=4127  tmp=2.533494e-08 $ Zirc pin                          
412708  4127 -5.76225 312303 -302303  311301 -311304  imp:n=1 u=4127  tmp=2.533494e-08 $ Fuel meat section 1                         
412709  4127 -5.76225 302303 -302306  311301 -311304  imp:n=1 u=4127  tmp=2.533494e-08 $ Fuel meat section 2                         
412710  4127 -5.76225 302306 -302309  311301 -311304  imp:n=1 u=4127  tmp=2.533494e-08 $ Fuel meat section 3                         
412711  4127 -5.76225 302309 -302312  311301 -311304  imp:n=1 u=4127  tmp=2.533494e-08 $ Fuel meat section 4                         
412712  4127 -5.76225 302312 -312304  311301 -311304  imp:n=1 u=4127  tmp=2.533494e-08 $ Fuel meat section 5                         
412713   106 -1.698     312304 -312305 -311304          imp:n=1 u=4127  $ Upper graphite spacer                         
412714   105 -7.85     312305 -312306 -311305          imp:n=1 u=4127  $ SS top cap                          
412715   105 -7.85     312306 -312307 -311303          imp:n=1 u=4127  $ Tri-flute                          
412716   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4127 tmp=2.526170e-08 $ Water around tri-flute                          
412717   105 -7.85     312307 -312308 -311302          imp:n=1 u=4127  $ Fuel tip                         
412718   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4127 tmp=2.526170e-08 $ Water around fuel tip                         
412719   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4127 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4129 - SS clad (T0S210D210) universe --- 
c                         
412901   105 -7.85     312300 -312301 -311302          imp:n=1 u=4129  $ Lower grid plate pin                         
412902   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4129 tmp=2.526170e-08 $ Water around grid plate pin                          
412903   105 -7.85     312301 -312302 -311305          imp:n=1 u=4129  $ Bottom casing                          
412904   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4129 tmp=2.526170e-08 $ Water around fuel element                         
412905   106 -1.698     312302 -312303 -311304          imp:n=1 u=4129  $ Lower graphite slug                          
412906   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4129  $ Fuel cladding                         
412907   108  0.042234 312303 -312304 -311301          imp:n=1 u=4129  tmp=2.533494e-08 $ Zirc pin                          
412908  4129 -5.767111 312303 -302303  311301 -311304  imp:n=1 u=4129  tmp=2.533494e-08 $ Fuel meat section 1                         
412909  4129 -5.767111 302303 -302306  311301 -311304  imp:n=1 u=4129  tmp=2.533494e-08 $ Fuel meat section 2                         
412910  4129 -5.767111 302306 -302309  311301 -311304  imp:n=1 u=4129  tmp=2.533494e-08 $ Fuel meat section 3                         
412911  4129 -5.767111 302309 -302312  311301 -311304  imp:n=1 u=4129  tmp=2.533494e-08 $ Fuel meat section 4                         
412912  4129 -5.767111 302312 -312304  311301 -311304  imp:n=1 u=4129  tmp=2.533494e-08 $ Fuel meat section 5                         
412913   106 -1.698     312304 -312305 -311304          imp:n=1 u=4129  $ Upper graphite spacer                         
412914   105 -7.85     312305 -312306 -311305          imp:n=1 u=4129  $ SS top cap                          
412915   105 -7.85     312306 -312307 -311303          imp:n=1 u=4129  $ Tri-flute                          
412916   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4129 tmp=2.526170e-08 $ Water around tri-flute                          
412917   105 -7.85     312307 -312308 -311302          imp:n=1 u=4129  $ Fuel tip                         
412918   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4129 tmp=2.526170e-08 $ Water around fuel tip                         
412919   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4129 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4130 - SS clad (T0S210D210) universe --- 
c                         
413001   105 -7.85     312300 -312301 -311302          imp:n=1 u=4130  $ Lower grid plate pin                         
413002   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4130 tmp=2.526170e-08 $ Water around grid plate pin                          
413003   105 -7.85     312301 -312302 -311305          imp:n=1 u=4130  $ Bottom casing                          
413004   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4130 tmp=2.526170e-08 $ Water around fuel element                         
413005   106 -1.698     312302 -312303 -311304          imp:n=1 u=4130  $ Lower graphite slug                          
413006   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4130  $ Fuel cladding                         
413007   108  0.042234 312303 -312304 -311301          imp:n=1 u=4130  tmp=2.533494e-08 $ Zirc pin                          
413008  4130 -5.916023 312303 -302303  311301 -311304  imp:n=1 u=4130  tmp=2.533494e-08 $ Fuel meat section 1                         
413009  4130 -5.916023 302303 -302306  311301 -311304  imp:n=1 u=4130  tmp=2.533494e-08 $ Fuel meat section 2                         
413010  4130 -5.916023 302306 -302309  311301 -311304  imp:n=1 u=4130  tmp=2.533494e-08 $ Fuel meat section 3                         
413011  4130 -5.916023 302309 -302312  311301 -311304  imp:n=1 u=4130  tmp=2.533494e-08 $ Fuel meat section 4                         
413012  4130 -5.916023 302312 -312304  311301 -311304  imp:n=1 u=4130  tmp=2.533494e-08 $ Fuel meat section 5                         
413013   106 -1.698     312304 -312305 -311304          imp:n=1 u=4130  $ Upper graphite spacer                         
413014   105 -7.85     312305 -312306 -311305          imp:n=1 u=4130  $ SS top cap                          
413015   105 -7.85     312306 -312307 -311303          imp:n=1 u=4130  $ Tri-flute                          
413016   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4130 tmp=2.526170e-08 $ Water around tri-flute                          
413017   105 -7.85     312307 -312308 -311302          imp:n=1 u=4130  $ Fuel tip                         
413018   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4130 tmp=2.526170e-08 $ Water around fuel tip                         
413019   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4130 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4131 - SS clad (T0S210D210) universe --- 
c                         
413101   105 -7.85     312300 -312301 -311302          imp:n=1 u=4131  $ Lower grid plate pin                         
413102   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4131 tmp=2.526170e-08 $ Water around grid plate pin                          
413103   105 -7.85     312301 -312302 -311305          imp:n=1 u=4131  $ Bottom casing                          
413104   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4131 tmp=2.526170e-08 $ Water around fuel element                         
413105   106 -1.698     312302 -312303 -311304          imp:n=1 u=4131  $ Lower graphite slug                          
413106   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4131  $ Fuel cladding                         
413107   108  0.042234 312303 -312304 -311301          imp:n=1 u=4131  tmp=2.533494e-08 $ Zirc pin                          
413108  4131 -5.766426 312303 -302303  311301 -311304  imp:n=1 u=4131  tmp=2.533494e-08 $ Fuel meat section 1                         
413109  4131 -5.766426 302303 -302306  311301 -311304  imp:n=1 u=4131  tmp=2.533494e-08 $ Fuel meat section 2                         
413110  4131 -5.766426 302306 -302309  311301 -311304  imp:n=1 u=4131  tmp=2.533494e-08 $ Fuel meat section 3                         
413111  4131 -5.766426 302309 -302312  311301 -311304  imp:n=1 u=4131  tmp=2.533494e-08 $ Fuel meat section 4                         
413112  4131 -5.766426 302312 -312304  311301 -311304  imp:n=1 u=4131  tmp=2.533494e-08 $ Fuel meat section 5                         
413113   106 -1.698     312304 -312305 -311304          imp:n=1 u=4131  $ Upper graphite spacer                         
413114   105 -7.85     312305 -312306 -311305          imp:n=1 u=4131  $ SS top cap                          
413115   105 -7.85     312306 -312307 -311303          imp:n=1 u=4131  $ Tri-flute                          
413116   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4131 tmp=2.526170e-08 $ Water around tri-flute                          
413117   105 -7.85     312307 -312308 -311302          imp:n=1 u=4131  $ Fuel tip                         
413118   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4131 tmp=2.526170e-08 $ Water around fuel tip                         
413119   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4131 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4132 - SS clad (T0S210D210) universe --- 
c                         
413201   105 -7.85     312300 -312301 -311302          imp:n=1 u=4132  $ Lower grid plate pin                         
413202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4132 tmp=2.526170e-08 $ Water around grid plate pin                          
413203   105 -7.85     312301 -312302 -311305          imp:n=1 u=4132  $ Bottom casing                          
413204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4132 tmp=2.526170e-08 $ Water around fuel element                         
413205   106 -1.698     312302 -312303 -311304          imp:n=1 u=4132  $ Lower graphite slug                          
413206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4132  $ Fuel cladding                         
413207   108  0.042234 312303 -312304 -311301          imp:n=1 u=4132  tmp=2.533494e-08 $ Zirc pin                          
413208  4132 -5.613955 312303 -302303  311301 -311304  imp:n=1 u=4132  tmp=2.533494e-08 $ Fuel meat section 1                         
413209  4132 -5.613955 302303 -302306  311301 -311304  imp:n=1 u=4132  tmp=2.533494e-08 $ Fuel meat section 2                         
413210  4132 -5.613955 302306 -302309  311301 -311304  imp:n=1 u=4132  tmp=2.533494e-08 $ Fuel meat section 3                         
413211  4132 -5.613955 302309 -302312  311301 -311304  imp:n=1 u=4132  tmp=2.533494e-08 $ Fuel meat section 4                         
413212  4132 -5.613955 302312 -312304  311301 -311304  imp:n=1 u=4132  tmp=2.533494e-08 $ Fuel meat section 5                         
413213   106 -1.698     312304 -312305 -311304          imp:n=1 u=4132  $ Upper graphite spacer                         
413214   105 -7.85     312305 -312306 -311305          imp:n=1 u=4132  $ SS top cap                          
413215   105 -7.85     312306 -312307 -311303          imp:n=1 u=4132  $ Tri-flute                          
413216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4132 tmp=2.526170e-08 $ Water around tri-flute                          
413217   105 -7.85     312307 -312308 -311302          imp:n=1 u=4132  $ Fuel tip                         
413218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4132 tmp=2.526170e-08 $ Water around fuel tip                         
413219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4132 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4133 - SS clad (T0S210D210) universe --- 
c                         
413301   105 -7.85     312300 -312301 -311302          imp:n=1 u=4133  $ Lower grid plate pin                         
413302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4133 tmp=2.526170e-08 $ Water around grid plate pin                          
413303   105 -7.85     312301 -312302 -311305          imp:n=1 u=4133  $ Bottom casing                          
413304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4133 tmp=2.526170e-08 $ Water around fuel element                         
413305   106 -1.698     312302 -312303 -311304          imp:n=1 u=4133  $ Lower graphite slug                          
413306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4133  $ Fuel cladding                         
413307   108  0.042234 312303 -312304 -311301          imp:n=1 u=4133  tmp=2.533494e-08 $ Zirc pin                          
413308  4133 -5.91768 312303 -302303  311301 -311304  imp:n=1 u=4133  tmp=2.533494e-08 $ Fuel meat section 1                         
413309  4133 -5.91768 302303 -302306  311301 -311304  imp:n=1 u=4133  tmp=2.533494e-08 $ Fuel meat section 2                         
413310  4133 -5.91768 302306 -302309  311301 -311304  imp:n=1 u=4133  tmp=2.533494e-08 $ Fuel meat section 3                         
413311  4133 -5.91768 302309 -302312  311301 -311304  imp:n=1 u=4133  tmp=2.533494e-08 $ Fuel meat section 4                         
413312  4133 -5.91768 302312 -312304  311301 -311304  imp:n=1 u=4133  tmp=2.533494e-08 $ Fuel meat section 5                         
413313   106 -1.698     312304 -312305 -311304          imp:n=1 u=4133  $ Upper graphite spacer                         
413314   105 -7.85     312305 -312306 -311305          imp:n=1 u=4133  $ SS top cap                          
413315   105 -7.85     312306 -312307 -311303          imp:n=1 u=4133  $ Tri-flute                          
413316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4133 tmp=2.526170e-08 $ Water around tri-flute                          
413317   105 -7.85     312307 -312308 -311302          imp:n=1 u=4133  $ Fuel tip                         
413318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4133 tmp=2.526170e-08 $ Water around fuel tip                         
413319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4133 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 4134 - SS clad (T0S210D210) universe --- 
c                         
413401   105 -7.85     312300 -312301 -311302          imp:n=1 u=4134  $ Lower grid plate pin                         
413402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=4134 tmp=2.526170e-08 $ Water around grid plate pin                          
413403   105 -7.85     312301 -312302 -311305          imp:n=1 u=4134  $ Bottom casing                          
413404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=4134 tmp=2.526170e-08 $ Water around fuel element                         
413405   106 -1.698     312302 -312303 -311304          imp:n=1 u=4134  $ Lower graphite slug                          
413406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=4134  $ Fuel cladding                         
413407   108  0.042234 312303 -312304 -311301          imp:n=1 u=4134  tmp=2.533494e-08 $ Zirc pin                          
413408  4134 -5.763247 312303 -302303  311301 -311304  imp:n=1 u=4134  tmp=2.533494e-08 $ Fuel meat section 1                         
413409  4134 -5.763247 302303 -302306  311301 -311304  imp:n=1 u=4134  tmp=2.533494e-08 $ Fuel meat section 2                         
413410  4134 -5.763247 302306 -302309  311301 -311304  imp:n=1 u=4134  tmp=2.533494e-08 $ Fuel meat section 3                         
413411  4134 -5.763247 302309 -302312  311301 -311304  imp:n=1 u=4134  tmp=2.533494e-08 $ Fuel meat section 4                         
413412  4134 -5.763247 302312 -312304  311301 -311304  imp:n=1 u=4134  tmp=2.533494e-08 $ Fuel meat section 5                         
413413   106 -1.698     312304 -312305 -311304          imp:n=1 u=4134  $ Upper graphite spacer                         
413414   105 -7.85     312305 -312306 -311305          imp:n=1 u=4134  $ SS top cap                          
413415   105 -7.85     312306 -312307 -311303          imp:n=1 u=4134  $ Tri-flute                          
413416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=4134 tmp=2.526170e-08 $ Water around tri-flute                          
413417   105 -7.85     312307 -312308 -311302          imp:n=1 u=4134  $ Fuel tip                         
413418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=4134 tmp=2.526170e-08 $ Water around fuel tip                         
413419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=4134 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8732 - SS clad (T13S210D210) universe --- 
c                         
873201   105 -7.85     312300 -312301 -311302          imp:n=1 u=8732  $ Lower grid plate pin                         
873202   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8732 tmp=2.526170e-08 $ Water around grid plate pin                          
873203   105 -7.85     312301 -312302 -311305          imp:n=1 u=8732  $ Bottom casing                          
873204   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8732 tmp=2.526170e-08 $ Water around fuel element                         
873205   106 -1.698     312302 -312303 -311304          imp:n=1 u=8732  $ Lower graphite slug                          
873206   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8732  $ Fuel cladding                         
873207   108  0.042234 312303 -312304 -311301          imp:n=1 u=8732  tmp=2.533494e-08 $ Zirc pin                          
873208  8732 -5.665043 312303 -302303  311301 -311304  imp:n=1 u=8732  tmp=2.533494e-08 $ Fuel meat section 1                         
873209  8732 -5.665043 302303 -302306  311301 -311304  imp:n=1 u=8732  tmp=2.533494e-08 $ Fuel meat section 2                         
873210  8732 -5.665043 302306 -302309  311301 -311304  imp:n=1 u=8732  tmp=2.533494e-08 $ Fuel meat section 3                         
873211  8732 -5.665043 302309 -302312  311301 -311304  imp:n=1 u=8732  tmp=2.533494e-08 $ Fuel meat section 4                         
873212  8732 -5.665043 302312 -312304  311301 -311304  imp:n=1 u=8732  tmp=2.533494e-08 $ Fuel meat section 5                         
873213   106 -1.698     312304 -312305 -311304          imp:n=1 u=8732  $ Upper graphite spacer                         
873214   105 -7.85     312305 -312306 -311305          imp:n=1 u=8732  $ SS top cap                          
873215   105 -7.85     312306 -312307 -311303          imp:n=1 u=8732  $ Tri-flute                          
873216   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8732 tmp=2.526170e-08 $ Water around tri-flute                          
873217   105 -7.85     312307 -312308 -311302          imp:n=1 u=8732  $ Fuel tip                         
873218   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8732 tmp=2.526170e-08 $ Water around fuel tip                         
873219   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8732 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8733 - SS clad (T13S210D210) universe --- 
c                         
873301   105 -7.85     312300 -312301 -311302          imp:n=1 u=8733  $ Lower grid plate pin                         
873302   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8733 tmp=2.526170e-08 $ Water around grid plate pin                          
873303   105 -7.85     312301 -312302 -311305          imp:n=1 u=8733  $ Bottom casing                          
873304   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8733 tmp=2.526170e-08 $ Water around fuel element                         
873305   106 -1.698     312302 -312303 -311304          imp:n=1 u=8733  $ Lower graphite slug                          
873306   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8733  $ Fuel cladding                         
873307   108  0.042234 312303 -312304 -311301          imp:n=1 u=8733  tmp=2.533494e-08 $ Zirc pin                          
873308  8733 -5.686293 312303 -302303  311301 -311304  imp:n=1 u=8733  tmp=2.533494e-08 $ Fuel meat section 1                         
873309  8733 -5.686293 302303 -302306  311301 -311304  imp:n=1 u=8733  tmp=2.533494e-08 $ Fuel meat section 2                         
873310  8733 -5.686293 302306 -302309  311301 -311304  imp:n=1 u=8733  tmp=2.533494e-08 $ Fuel meat section 3                         
873311  8733 -5.686293 302309 -302312  311301 -311304  imp:n=1 u=8733  tmp=2.533494e-08 $ Fuel meat section 4                         
873312  8733 -5.686293 302312 -312304  311301 -311304  imp:n=1 u=8733  tmp=2.533494e-08 $ Fuel meat section 5                         
873313   106 -1.698     312304 -312305 -311304          imp:n=1 u=8733  $ Upper graphite spacer                         
873314   105 -7.85     312305 -312306 -311305          imp:n=1 u=8733  $ SS top cap                          
873315   105 -7.85     312306 -312307 -311303          imp:n=1 u=8733  $ Tri-flute                          
873316   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8733 tmp=2.526170e-08 $ Water around tri-flute                          
873317   105 -7.85     312307 -312308 -311302          imp:n=1 u=8733  $ Fuel tip                         
873318   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8733 tmp=2.526170e-08 $ Water around fuel tip                         
873319   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8733 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8734 - SS clad (T13S210D210) universe --- 
c                         
873401   105 -7.85     312300 -312301 -311302          imp:n=1 u=8734  $ Lower grid plate pin                         
873402   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8734 tmp=2.526170e-08 $ Water around grid plate pin                          
873403   105 -7.85     312301 -312302 -311305          imp:n=1 u=8734  $ Bottom casing                          
873404   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8734 tmp=2.526170e-08 $ Water around fuel element                         
873405   106 -1.698     312302 -312303 -311304          imp:n=1 u=8734  $ Lower graphite slug                          
873406   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8734  $ Fuel cladding                         
873407   108  0.042234 312303 -312304 -311301          imp:n=1 u=8734  tmp=2.533494e-08 $ Zirc pin                          
873408  8734 -5.663521 312303 -302303  311301 -311304  imp:n=1 u=8734  tmp=2.533494e-08 $ Fuel meat section 1                         
873409  8734 -5.663521 302303 -302306  311301 -311304  imp:n=1 u=8734  tmp=2.533494e-08 $ Fuel meat section 2                         
873410  8734 -5.663521 302306 -302309  311301 -311304  imp:n=1 u=8734  tmp=2.533494e-08 $ Fuel meat section 3                         
873411  8734 -5.663521 302309 -302312  311301 -311304  imp:n=1 u=8734  tmp=2.533494e-08 $ Fuel meat section 4                         
873412  8734 -5.663521 302312 -312304  311301 -311304  imp:n=1 u=8734  tmp=2.533494e-08 $ Fuel meat section 5                         
873413   106 -1.698     312304 -312305 -311304          imp:n=1 u=8734  $ Upper graphite spacer                         
873414   105 -7.85     312305 -312306 -311305          imp:n=1 u=8734  $ SS top cap                          
873415   105 -7.85     312306 -312307 -311303          imp:n=1 u=8734  $ Tri-flute                          
873416   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8734 tmp=2.526170e-08 $ Water around tri-flute                          
873417   105 -7.85     312307 -312308 -311302          imp:n=1 u=8734  $ Fuel tip                         
873418   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8734 tmp=2.526170e-08 $ Water around fuel tip                         
873419   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8734 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8735 - SS clad (T13S210D210) universe --- 
c                         
873501   105 -7.85     312300 -312301 -311302          imp:n=1 u=8735  $ Lower grid plate pin                         
873502   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8735 tmp=2.526170e-08 $ Water around grid plate pin                          
873503   105 -7.85     312301 -312302 -311305          imp:n=1 u=8735  $ Bottom casing                          
873504   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8735 tmp=2.526170e-08 $ Water around fuel element                         
873505   106 -1.698     312302 -312303 -311304          imp:n=1 u=8735  $ Lower graphite slug                          
873506   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8735  $ Fuel cladding                         
873507   108  0.042234 312303 -312304 -311301          imp:n=1 u=8735  tmp=2.533494e-08 $ Zirc pin                          
873508  8735 -5.775854 312303 -302303  311301 -311304  imp:n=1 u=8735  tmp=2.533494e-08 $ Fuel meat section 1                         
873509  8735 -5.775854 302303 -302306  311301 -311304  imp:n=1 u=8735  tmp=2.533494e-08 $ Fuel meat section 2                         
873510  8735 -5.775854 302306 -302309  311301 -311304  imp:n=1 u=8735  tmp=2.533494e-08 $ Fuel meat section 3                         
873511  8735 -5.775854 302309 -302312  311301 -311304  imp:n=1 u=8735  tmp=2.533494e-08 $ Fuel meat section 4                         
873512  8735 -5.775854 302312 -312304  311301 -311304  imp:n=1 u=8735  tmp=2.533494e-08 $ Fuel meat section 5                         
873513   106 -1.698     312304 -312305 -311304          imp:n=1 u=8735  $ Upper graphite spacer                         
873514   105 -7.85     312305 -312306 -311305          imp:n=1 u=8735  $ SS top cap                          
873515   105 -7.85     312306 -312307 -311303          imp:n=1 u=8735  $ Tri-flute                          
873516   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8735 tmp=2.526170e-08 $ Water around tri-flute                          
873517   105 -7.85     312307 -312308 -311302          imp:n=1 u=8735  $ Fuel tip                         
873518   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8735 tmp=2.526170e-08 $ Water around fuel tip                         
873519   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8735 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --- 8736 - SS clad (T13S210D210) universe --- 
c                         
873601   105 -7.85     312300 -312301 -311302          imp:n=1 u=8736  $ Lower grid plate pin                         
873602   102 -0.997903     312300 -312301  311302 -311306  imp:n=1 u=8736 tmp=2.526170e-08 $ Water around grid plate pin                          
873603   105 -7.85     312301 -312302 -311305          imp:n=1 u=8736  $ Bottom casing                          
873604   102 -0.997903     312301 -312306  311305 -311306  imp:n=1 u=8736 tmp=2.526170e-08 $ Water around fuel element                         
873605   106 -1.698     312302 -312303 -311304          imp:n=1 u=8736  $ Lower graphite slug                          
873606   105 -7.85     312302 -312305  311304 -311305  imp:n=1 u=8736  $ Fuel cladding                         
873607   108  0.042234 312303 -312304 -311301          imp:n=1 u=8736  tmp=2.533494e-08 $ Zirc pin                          
873608  8736 -5.756112 312303 -302303  311301 -311304  imp:n=1 u=8736  tmp=2.533494e-08 $ Fuel meat section 1                         
873609  8736 -5.756112 302303 -302306  311301 -311304  imp:n=1 u=8736  tmp=2.533494e-08 $ Fuel meat section 2                         
873610  8736 -5.756112 302306 -302309  311301 -311304  imp:n=1 u=8736  tmp=2.533494e-08 $ Fuel meat section 3                         
873611  8736 -5.756112 302309 -302312  311301 -311304  imp:n=1 u=8736  tmp=2.533494e-08 $ Fuel meat section 4                         
873612  8736 -5.756112 302312 -312304  311301 -311304  imp:n=1 u=8736  tmp=2.533494e-08 $ Fuel meat section 5                         
873613   106 -1.698     312304 -312305 -311304          imp:n=1 u=8736  $ Upper graphite spacer                         
873614   105 -7.85     312305 -312306 -311305          imp:n=1 u=8736  $ SS top cap                          
873615   105 -7.85     312306 -312307 -311303          imp:n=1 u=8736  $ Tri-flute                          
873616   102 -0.997903     312306 -312307  311303 -311306  imp:n=1 u=8736 tmp=2.526170e-08 $ Water around tri-flute                          
873617   105 -7.85     312307 -312308 -311302          imp:n=1 u=8736  $ Fuel tip                         
873618   102 -0.997903     312307 -312308  311302 -311306  imp:n=1 u=8736 tmp=2.526170e-08 $ Water around fuel tip                         
873619   102 -0.997903     312308 -312309 -311306          imp:n=1 u=8736 tmp=2.526170e-08 $ Water above fuel element                         
c                         
c
c --End Fuel Cells--
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
2000 102 -0.997903 312300 -312309 -311306 imp:n=1 u=2 tmp=2.526170e-08 $ Water test cell
c
c
c
c
c ------------------------------
c --------- Void cells ---------
c ------------------------------
c
10001  0  -192399                  imp:n=0  $ void below model
10002  0   192399 -192301  191301  imp:n=0  $ void around model
10003  0   192301                  imp:n=0  $ void above model
c
c
c
c ------------------------------
c --------- Grid plates --------
c ------------------------------
c
c
c ------------- upper grid plate -------------
c
11001   103  -2.70  112304 -112305 -132008 -132034  111300 -131302
      902019                                                         imp:n=1  $ Upper grid plate above B1
c
11002   103  -2.70  112304 -112305  132008 -132021  111300 -131302  
      902029  111312                                                 imp:n=1  $ Upper grid plate above B2
c
11003   103  -2.70  112304 -112305 -132034  132021  111300 -131302  
      902039  111312  111307  111306                                 imp:n=1  $ Upper grid plate above B3
c
11004   103  -2.70  112304 -112305  132008  132034  111300 -131302
      902049                                                         imp:n=1  $ Upper grid plate above B4
c
11005   103  -2.70  112304 -112305 -132008  132021  111300 -131302  
      902059  111301                                                 imp:n=1  $ Upper grid plate above B5
c
11006   103  -2.70  112304 -112305  132034 -132021  111300 -131302  
      902069  111301                                                 imp:n=1  $ Upper grid plate above B6
c
c
c
c
11007   103  -2.70  112304 -112305 -132037 -132005  131302 -131303
      903019                                                         imp:n=1  $ Upper grid plate above C1
c
11008   103  -2.70  112304 -112305  132005 -132011  131302 -131303
      903029                                                         imp:n=1  $ Upper grid plate above C2
c
11009   103  -2.70  112304 -112305  132011 -132018  131302 -131303
      903039                                                         imp:n=1  $ Upper grid plate above C3
c
11010   103  -2.70  112304 -112305  132018 -132024  131302 -131303
      903049  111307                                                 imp:n=1  $ Upper grid plate above C4
c
11011   103  -2.70  112304 -112305  132024 -132031  131302 -131303
      903059  111306  111307  111308                                 imp:n=1  $ Upper grid plate above C5
c
11012   103  -2.70  112304 -112305  132031 -132037  131302 -131303
      903069  111306                                                 imp:n=1  $ Upper grid plate above C6
c
11013   103  -2.70  112304 -112305  132037  132005  131302 -131303
      903079                                                         imp:n=1  $ Upper grid plate above C7
c
11014   103  -2.70  112304 -112305 -132005  132011  131302 -131303
      903089                                                         imp:n=1  $ Upper grid plate above C8
c
11015   103  -2.70  112304 -112305 -132011  132018  131302 -131303
      903099                                                         imp:n=1  $ Upper grid plate above C9
c
11016   103  -2.70  112304 -112305 -132018  132024  131302 -131303
      903109                                                         imp:n=1  $ Upper grid plate above C10
c
11017   103  -2.70  112304 -112305 -132024  132031  131302 -131303
      903119                                                         imp:n=1  $ Upper grid plate above C11
c
11018   103  -2.70  112304 -112305 -132031  132037  131302 -131303
      903129                                                         imp:n=1  $ Upper grid plate above C12
c
c
c
c
11019   103  -2.70  112304 -112305 -132004 -132038  131303 -131304
      904019                                                         imp:n=1  $ Upper grid plate above D1
c
11020   103  -2.70  112304 -112305  132004 -132008  131303 -131304
      904029                                                         imp:n=1  $ Upper grid plate above D2
c
11021   103  -2.70  112304 -112305  132008 -132012  131303 -131304
      904039                                                         imp:n=1  $ Upper grid plate above D3
c
11022   103  -2.70  112304 -112305  132012 -132017  131303 -131304
      904049                                                         imp:n=1  $ Upper grid plate above D4
c
11023   103  -2.70  112304 -112305  132017 -132021  131303 -131304
      904059  111313  111314                                         imp:n=1  $ Upper grid plate above D5
c
11024   103  -2.70  112304 -112305  132021 -132025  131303 -131304
      904069  111308  111309  111313  111314                         imp:n=1  $ Upper grid plate above D6
c
11025   103  -2.70  112304 -112305  132025 -132030  131303 -131304
      904079  111308  111309                                         imp:n=1  $ Upper grid plate above D7
c
11026   103  -2.70  112304 -112305  132030 -132034  131303 -131304
      904089                                                         imp:n=1  $ Upper grid plate above D8
c
11027   103  -2.70  112304 -112305  132034 -132038  131303 -131304
      904099                                                         imp:n=1  $ Upper grid plate above D9
c
11028   103  -2.70  112304 -112305  132004  132038  131303 -131304
      904109                                                         imp:n=1  $ Upper grid plate above D10
c
11029   103  -2.70  112304 -112305 -132004  132008  131303 -131304
      904119                                                         imp:n=1  $ Upper grid plate above D11
c
11030   103  -2.70  112304 -112305 -132008  132012  131303 -131304
      904129                                                         imp:n=1  $ Upper grid plate above D12
c
11031   103  -2.70  112304 -112305 -132012  132017  131303 -131304
      904139                                                         imp:n=1  $ Upper grid plate above D13
c
11032   103  -2.70  112304 -112305 -132017  132021  131303 -131304
      904149  111302  111303                                         imp:n=1  $ Upper grid plate above D14
c
11033   103  -2.70  112304 -112305 -132021  132025  131303 -131304
      904159  111302  111303                                         imp:n=1  $ Upper grid plate above D15
c
11034   103  -2.70  112304 -112305 -132025  132030  131303 -131304
      904169                                                         imp:n=1  $ Upper grid plate above D16
c
11035   103  -2.70  112304 -112305 -132030  132034  131303 -131304
      904179                                                         imp:n=1  $ Upper grid plate above D17
c
11036   103  -2.70  112304 -112305 -132034  132038  131303 -131304
      904189                                                         imp:n=1  $ Upper grid plate above D18
c
c
c
c
11037   103  -2.70  112304 -112305 -132003 -132039  131304 -131305
      905019                                                         imp:n=1  $ Upper grid plate above E1
c
11038   103  -2.70  112304 -112305  132003 -132007  131304 -131305
      905029                                                         imp:n=1  $ Upper grid plate above E2
c
11039   103  -2.70  112304 -112305  132007 -132009  131304 -131305
      905039                                                         imp:n=1  $ Upper grid plate above E3
c
11040   103  -2.70  112304 -112305  132009 -132013  131304 -131305
      905049                                                         imp:n=1  $ Upper grid plate above E4
c
11041   103  -2.70  112304 -112305  132013 -132016  131304 -131305
      905059                                                         imp:n=1  $ Upper grid plate above E5
c
11042   103  -2.70  112304 -112305  132016 -132020  131304 -131305
      905069                                                         imp:n=1  $ Upper grid plate above E6
c
11043   103  -2.70  112304 -112305  132020 -132022  131304 -131305
      905079                                                         imp:n=1  $ Upper grid plate above E7
c
11044   103  -2.70  112304 -112305  132022 -132026  131304 -131305
      905089  111309  111310                                         imp:n=1  $ Upper grid plate above E8
c
11045   103  -2.70  112304 -112305  132026 -132029  131304 -131305
      905099  111309  111310                                         imp:n=1  $ Upper grid plate above E9
c
11046   103  -2.70  112304 -112305  132029 -132033  131304 -131305
      905109                                                         imp:n=1  $ Upper grid plate above E10
c
11047   103  -2.70  112304 -112305  132033 -132035  131304 -131305
      905119                                                         imp:n=1  $ Upper grid plate above E11
c
11048   103  -2.70  112304 -112305  132035 -132039  131304 -131305
      905129                                                         imp:n=1  $ Upper grid plate above E12
c
11049   103  -2.70  112304 -112305  132003  132039  131304 -131305
      905139                                                         imp:n=1  $ Upper grid plate above E13
c
11050   103  -2.70  112304 -112305 -132003  132007  131304 -131305
      905149                                                         imp:n=1  $ Upper grid plate above E14
c
11051   103  -2.70  112304 -112305 -132007  132009  131304 -131305
      905159                                                         imp:n=1  $ Upper grid plate above E15
c
11052   103  -2.70  112304 -112305 -132009  132013  131304 -131305
      905169                                                         imp:n=1  $ Upper grid plate above E16
c
11053   103  -2.70  112304 -112305 -132013  132016  131304 -131305
      905179                                                         imp:n=1  $ Upper grid plate above E17
c
11054   103  -2.70  112304 -112305 -132016  132020  131304 -131305
      905189                                                         imp:n=1  $ Upper grid plate above E18
c
11055   103  -2.70  112304 -112305 -132020  132022  131304 -131305
      905199                                                         imp:n=1  $ Upper grid plate above E19
c
11056   103  -2.70  112304 -112305 -132022  132026  131304 -131305
      905209                                                         imp:n=1  $ Upper grid plate above E20
c
11057   103  -2.70  112304 -112305 -132026  132029  131304 -131305
      905219                                                         imp:n=1  $ Upper grid plate above E21
c
11058   103  -2.70  112304 -112305 -132029  132033  131304 -131305
      905229                                                         imp:n=1  $ Upper grid plate above E22
c
11059   103  -2.70  112304 -112305 -132033  132035  131304 -131305
      905239                                                         imp:n=1  $ Upper grid plate above E23
c
11060   103  -2.70  112304 -112305 -132035  132039  131304 -131305
      905249                                                         imp:n=1  $ Upper grid plate above E24
c
c
c
c
11061   103  -2.70  112304 -112305 -132040 -132002  131305 -111399
      906019                                                         imp:n=1  $ Upper grid plate above F1
c
11062   103  -2.70  112304 -112305  132002 -132006  131305 -111399
      906029                                                         imp:n=1  $ Upper grid plate above F2
c
11063   103  -2.70  112304 -112305  132006 -132008  131305 -111399
      906039                                                         imp:n=1  $ Upper grid plate above F3
c
11064   103  -2.70  112304 -112305  132008 -132010  131305 -111399
      906049                                                         imp:n=1  $ Upper grid plate above F4
c
11065   103  -2.70  112304 -112305  132010 -132014  131305 -111399
      906059                                                         imp:n=1  $ Upper grid plate above F5
c
11066   103  -2.70  112304 -112305  132014 -132015  131305 -111399
      906069                                                         imp:n=1  $ Upper grid plate above F6
c
11067   103  -2.70  112304 -112305  132015 -132019  131305 -111399
      906079  111316                                                 imp:n=1  $ Upper grid plate above F7
c
11068   103  -2.70  112304 -112305  132019 -132021  131305 -111399
      906089  111315  111316                                         imp:n=1  $ Upper grid plate above F8
c
11069   103  -2.70  112304 -112305  132021 -132023  131305 -111399
      906099  111315                                                 imp:n=1  $ Upper grid plate above F9
c
11070   103  -2.70  112304 -112305  132023 -132027  131305 -111399
      906109  111310  111311                                         imp:n=1  $ Upper grid plate above F10
c
11071   103  -2.70  112304 -112305  132027 -132028  131305 -111399
      906119  111310  111311                                         imp:n=1  $ Upper grid plate above F11
c
11072   103  -2.70  112304 -112305  132028 -132032  131305 -111399
      906129                                                         imp:n=1  $ Upper grid plate above F12
c
11073   103  -2.70  112304 -112305  132032 -132034  131305 -111399
      906139                                                         imp:n=1  $ Upper grid plate above F13
c
11074   103  -2.70  112304 -112305  132034 -132036  131305 -111399
      906149                                                         imp:n=1  $ Upper grid plate above F14
c
11075   103  -2.70  112304 -112305  132036 -132040  131305 -111399
      906159                                                         imp:n=1  $ Upper grid plate above F15
c
11076   103  -2.70  112304 -112305  132040  132002  131305 -111399
      906169                                                         imp:n=1  $ Upper grid plate above F16
c
11077   103  -2.70  112304 -112305 -132002  132006  131305 -111399
      906179                                                         imp:n=1  $ Upper grid plate above F17
c
11078   103  -2.70  112304 -112305 -132006  132008  131305 -111399
      906189                                                         imp:n=1  $ Upper grid plate above F18
c
11079   103  -2.70  112304 -112305 -132008  132010  131305 -111399
      906199                                                         imp:n=1  $ Upper grid plate above F19
c
11080   103  -2.70  112304 -112305 -132010  132014  131305 -111399
      906209                                                         imp:n=1  $ Upper grid plate above F20
c
11081   103  -2.70  112304 -112305 -132014  132015  131305 -111399
      906219                                                         imp:n=1  $ Upper grid plate above F21
c
11082   103  -2.70  112304 -112305 -132015  132019  131305 -111399
      906229  111305                                                 imp:n=1  $ Upper grid plate above F22
c
11083   103  -2.70  112304 -112305 -132019  132021  131305 -111399
      906239  111304  111305                                         imp:n=1  $ Upper grid plate above F23
c
11084   103  -2.70  112304 -112305 -132021  132023  131305 -111399  
      906249  111304                                                 imp:n=1  $ Upper grid plate above F24
c
11085   103  -2.70  112304 -112305 -132023  132027  131305 -111399
      906259                                                         imp:n=1  $ Upper grid plate above F25
c
11086   103  -2.70  112304 -112305 -132027  132028  131305 -111399
      906269                                                         imp:n=1  $ Upper grid plate above F26
c
11087   103  -2.70  112304 -112305 -132028  132032  131305 -111399
      906279                                                         imp:n=1  $ Upper grid plate above F27
c
11088   103  -2.70  112304 -112305 -132032  132034  131305 -111399
      906289                                                         imp:n=1  $ Upper grid plate above F28
c
11089   103  -2.70  112304 -112305 -132034  132036  131305 -111399
      906299                                                         imp:n=1  $ Upper grid plate above F20
c
11090   103  -2.70  112304 -112305 -132036  132040  131305 -111399
      906309                                                         imp:n=1  $ Upper grid plate above F30
c
c
c  ---- alternate lower grid plate for error reduction ----
c
77001  103  -2.70  112301 -10  111397 -131302   imp:n=1   $ Lower grid plate B ring
77002  103  -2.70  112301 -10  131302 -131303   imp:n=1   $ Lower grid plate C ring
77003  103  -2.70  112301 -10  131303 -131304   imp:n=1   $ Lower grid plate D ring
77004  103  -2.70  112301 -10  131304 -131305   imp:n=1   $ Lower grid plate E ring
77005  103  -2.70  112301 -10  131305 -111398   imp:n=1   $ Lower grid plate E ring
c
c
c
c ------------------------------
c ----- Graphite reflector -----
c ------------------------------
c
12001  106  -1.60      122302 -122305  121302 -121303   imp:n=1  $ Inner graphite blank
12002  106  -1.60      122302 -122303  121303 -121306   imp:n=1  $ LS channel region graphite blank
12003  106  -1.60      122302 -122305  121306 -121307   imp:n=1  $ Outer graphite blank
c
12004  103  -2.70      122301 -122306  121301 -121302   imp:n=1  $ Inner reflector container wall
12005  103  -2.70      122303 -122306  121303 -121304   imp:n=1  $ Inner LS channel container wall
12006  103  -2.70      122303 -122306  121305 -121306   imp:n=1  $ Outer LS channel container wall
12007  103  -2.70      122301 -122306  121307 -121308   imp:n=1  $ Outer reclector assembly container wall
c
12008  103  -2.70      122301 -122302  121302 -121307   imp:n=1  $ Reflector assembly bottom container annulus 
12009  103  -2.70      122305 -122306  121302 -121303   imp:n=1  $ Reflector assembly top inner container annulus
12010  103  -2.70      122303 -122304  121304 -121305   imp:n=1  $ LS channel bottom container annulus
12011  103  -2.70      122305 -122306  121306 -121307   imp:n=1  $ Reflector assembly top outer container annulus
c
c
c
c ------------------------------
c ---- Rotary specimen rack ----
c ------------------------------
c
c
c ------ Rotary rack enclosure ------
c
12012  103  -2.70      122309 -122310  121390 -121305   imp:n=1   $ Top cap of enclosure
12013  103  -2.70      122306 -122309  121390 -121391   imp:n=1   $ Lip wall of enclosure
12014  103  -2.70      122304 -122309  121392 -121305   imp:n=1   $ Outer wall of enclosure
12015  103  -2.70      122306 -122308  121391 -121393   imp:n=1   $ Bottom of LS lip
12016  103  -2.70      122304 -122306  121304 -121393   imp:n=1   $ Inner wall of enclosure
12017  103  -2.70      122304 -122307  121393 -121392   imp:n=1   $ Bottom wall of enclosure
c
12018  101  -0.001225  122307 -122311  121393 -121392   imp:n=1   $ Air under specimen holders
12019  101  -0.001225  122315 -122309  121391 -121392   imp:n=1   $ Air above rotary rack
12020  101  -0.001225  122313 -122315  121395 -121392   imp:n=1   $ Air around rack 
12021  101  -0.001225  122308 -122313  121391 -121393   imp:n=1   $ Air under rack support annulus
c
12022  103  -2.70      122313 -122315  121391 -121394   imp:n=1   $ Rack support annulus
c
c
c ------- Specimen holders ------- 
c
c ---- Position 1 ----
c
12101  101  -0.001225    122312 -122314 -121310            imp:n=1   $ Air inside sample tube
12201  103  -2.70        122311 -122312 -121310            imp:n=1   $ Bottom cap of tube  
12301  103  -2.70        122311 -122314  121310 -121311    imp:n=1   $ Sample tube         
c
12401  103  -2.70        122313  123301  121394 -121395  
                         122001 -122315  122020  121311    imp:n=1   $ Sample ring around position
c
12501  101  -0.001225    122314 -122315 -123301  121394 
                        -121395  122001  122020            imp:n=1   $ air above sample tube bevel
c
12601  101  -0.001225    122311 -122313  121393 -121392  
                         121311  122001  122020            imp:n=1   $ air around sample tube
c
c
c ---- Position 2 ----
c
12102  101  -0.001225    122312 -122314 -121350            imp:n=1   $ Air inside sample tube
12202  103  -2.70        122311 -122312 -121350            imp:n=1   $ Bottom cap of tube  
12302  103  -2.70        122311 -122314  121350 -121351    imp:n=1   $ Sample tube         
c
12402  103  -2.70        122313  123321  121394 -121395  
                        -122020 -122315  122019  121351    imp:n=1   $ Sample ring around position
c
12502  101  -0.001225    122314 -122315 -123321  121394 
                        -121395 -122020  122019            imp:n=1   $ air above sample tube bevel
c
12602  101  -0.001225    122311 -122313  121393 -121392  
                         121351 -122020  122019            imp:n=1   $ air around sample tube
c
c
c ---- Position 3 ----
c
12103  101  -0.001225    122312 -122314 -121312            imp:n=1   $ Air inside sample tube
12203  103  -2.70        122311 -122312 -121312            imp:n=1   $ Bottom cap of tube  
12303  103  -2.70        122311 -122314  121312 -121313    imp:n=1   $ Sample tube         
c
12403  103  -2.70        122313  123302  121394 -121395  
                        -122019 -122315  122018  121313    imp:n=1   $ Sample ring around position
c
12503  101  -0.001225    122314 -122315 -123302  121394 
                        -121395 -122019  122018            imp:n=1   $ air above sample tube bevel
c
12603  101  -0.001225    122311 -122313  121393 -121392  
                         121313 -122019  122018            imp:n=1   $ air around sample tube
c
c
c ---- Position 4 ----
c
12104  101  -0.001225    122312 -122314 -121352            imp:n=1   $ Air inside sample tube
12204  103  -2.70        122311 -122312 -121352            imp:n=1   $ Bottom cap of tube  
12304  103  -2.70        122311 -122314  121352 -121353    imp:n=1   $ Sample tube         
c
12404  103  -2.70        122313  123322  121394 -121395  
                        -122018 -122315  122017  121353    imp:n=1   $ Sample ring around position
c
12504  101  -0.001225    122314 -122315 -123322  121394 
                        -121395 -122018  122017            imp:n=1   $ air above sample tube bevel
c
12604  101  -0.001225    122311 -122313  121393 -121392  
                         121353 -122018  122017            imp:n=1   $ air around sample tube
c
c
c ---- Position 5 ----
c
12105  101  -0.001225    122312 -122314 -121314            imp:n=1   $ Air inside sample tube
12205  103  -2.70        122311 -122312 -121314            imp:n=1   $ Bottom cap of tube  
12305  103  -2.70        122311 -122314  121314 -121315    imp:n=1   $ Sample tube         
c
12405  103  -2.70        122313  123303  121394 -121395  
                        -122017 -122315  122016  121315    imp:n=1   $ Sample ring around position
c
12505  101  -0.001225    122314 -122315 -123303  121394 
                        -121395 -122017  122016            imp:n=1   $ air above sample tube bevel
c
12605  101  -0.001225    122311 -122313  121393 -121392  
                         121315 -122017  122016            imp:n=1   $ air around sample tube
c
c
c ---- Position 6 ----
c
12106  101  -0.001225    122312 -122314 -121354            imp:n=1   $ Air inside sample tube
12206  103  -2.70        122311 -122312 -121354            imp:n=1   $ Bottom cap of tube  
12306  103  -2.70        122311 -122314  121354 -121355    imp:n=1   $ Sample tube         
c
12406  103  -2.70        122313  123323  121394 -121395  
                        -122016 -122315  122015  121355    imp:n=1   $ Sample ring around position
c
12506  101  -0.001225    122314 -122315 -123323  121394 
                        -121395 -122016  122015            imp:n=1   $ air above sample tube bevel
c
12606  101  -0.001225    122311 -122313  121393 -121392  
                         121355 -122016  122015            imp:n=1   $ air around sample tube
c
c
c ---- Position 7 ----
c
12107  101  -0.001225    122312 -122314 -121316            imp:n=1   $ Air inside sample tube
12207  103  -2.70        122311 -122312 -121316            imp:n=1   $ Bottom cap of tube  
12307  103  -2.70        122311 -122314  121316 -121317    imp:n=1   $ Sample tube         
c
12407  103  -2.70        122313  123304  121394 -121395  
                        -122015 -122315  122014  121317    imp:n=1   $ Sample ring around position
c
12507  101  -0.001225    122314 -122315 -123304  121394 
                        -121395 -122015  122014            imp:n=1   $ air above sample tube bevel
c
12607  101  -0.001225    122311 -122313  121393 -121392  
                         121317 -122015  122014            imp:n=1   $ air around sample tube
c
c
c ---- Position 8 ----
c
12108  101  -0.001225    122312 -122314 -121356            imp:n=1   $ Air inside sample tube
12208  103  -2.70        122311 -122312 -121356            imp:n=1   $ Bottom cap of tube  
12308  103  -2.70        122311 -122314  121356 -121357    imp:n=1   $ Sample tube         
c
12408  103  -2.70        122313  123324  121394 -121395  
                        -122014 -122315  122013  121357    imp:n=1   $ Sample ring around position
c
12508  101  -0.001225    122314 -122315 -123324  121394 
                        -121395 -122014  122013            imp:n=1   $ air above sample tube bevel
c
12608  101  -0.001225    122311 -122313  121393 -121392  
                         121357 -122014  122013            imp:n=1   $ air around sample tube
c
c
c ---- Position 9 ----
c
12109  101  -0.001225    122312 -122314 -121318            imp:n=1   $ Air inside sample tube
12209  103  -2.70        122311 -122312 -121318            imp:n=1   $ Bottom cap of tube  
12309  103  -2.70        122311 -122314  121318 -121319    imp:n=1   $ Sample tube         
c
12409  103  -2.70        122313  123305  121394 -121395  
                        -122013 -122315  122012  121319    imp:n=1   $ Sample ring around position
c
12509  101  -0.001225    122314 -122315 -123305  121394 
                        -121395 -122013  122012            imp:n=1   $ air above sample tube bevel
c
12609  101  -0.001225    122311 -122313  121393 -121392  
                         121319 -122013  122012            imp:n=1   $ air around sample tube
c
c
c ---- Position 10 ----
c
12110  101  -0.001225    122312 -122314 -121358            imp:n=1   $ Air inside sample tube
12210  103  -2.70        122311 -122312 -121358            imp:n=1   $ Bottom cap of tube  
12310  103  -2.70        122311 -122314  121358 -121359    imp:n=1   $ Sample tube         
c
12410  103  -2.70        122313  123325  121394 -121395  
                        -122012 -122315  122011  121359    imp:n=1   $ Sample ring around position
c
12510  101  -0.001225    122314 -122315 -123325  121394 
                        -121395 -122012  122011            imp:n=1   $ air above sample tube bevel
c
12610  101  -0.001225    122311 -122313  121393 -121392  
                         121359 -122012  122011            imp:n=1   $ air around sample tube
c
c
c ---- Position 11 ----
c
12111  101  -0.001225    122312 -122314 -121320            imp:n=1   $ Air inside sample tube
12211  103  -2.70        122311 -122312 -121320            imp:n=1   $ Bottom cap of tube  
12311  103  -2.70        122311 -122314  121320 -121321    imp:n=1   $ Sample tube         
c
12411  103  -2.70        122313  123306  121394 -121395  
                        -122011 -122315  122010  121321    imp:n=1   $ Sample ring around position
c
12511  101  -0.001225    122314 -122315 -123306  121394 
                        -121395 -122011  122010            imp:n=1   $ air above sample tube bevel
c
12611  101  -0.001225    122311 -122313  121393 -121392  
                         121321 -122011  122010            imp:n=1   $ air around sample tube
c
c
c ---- Position 12 ----
c
12112  101  -0.001225    122312 -122314 -121360            imp:n=1   $ Air inside sample tube
12212  103  -2.70        122311 -122312 -121360            imp:n=1   $ Bottom cap of tube  
12312  103  -2.70        122311 -122314  121360 -121361    imp:n=1   $ Sample tube         
c
12412  103  -2.70        122313  123326  121394 -121395  
                        -122010 -122315  122009  121361    imp:n=1   $ Sample ring around position
c
12512  101  -0.001225    122314 -122315 -123326  121394 
                        -121395 -122010  122009            imp:n=1   $ air above sample tube bevel
c
12612  101  -0.001225    122311 -122313  121393 -121392  
                         121361 -122010  122009            imp:n=1   $ air around sample tube
c
c
c ---- Position 13 ----
c
12113  101  -0.001225    122312 -122314 -121322            imp:n=1   $ Air inside sample tube
12213  103  -2.70        122311 -122312 -121322            imp:n=1   $ Bottom cap of tube  
12313  103  -2.70        122311 -122314  121322 -121323    imp:n=1   $ Sample tube         
c
12413  103  -2.70        122313  123307  121394 -121395  
                        -122009 -122315  122008  121323    imp:n=1   $ Sample ring around position
c
12513  101  -0.001225    122314 -122315 -123307  121394 
                        -121395 -122009  122008            imp:n=1   $ air above sample tube bevel
c
12613  101  -0.001225    122311 -122313  121393 -121392  
                         121323 -122009  122008            imp:n=1   $ air around sample tube
c
c
c ---- Position 14 ----
c
12114  101  -0.001225    122312 -122314 -121362            imp:n=1   $ Air inside sample tube
12214  103  -2.70        122311 -122312 -121362            imp:n=1   $ Bottom cap of tube  
12314  103  -2.70        122311 -122314  121362 -121363    imp:n=1   $ Sample tube         
c
12414  103  -2.70        122313  123327  121394 -121395  
                        -122008 -122315  122007  121363    imp:n=1   $ Sample ring around position
c
12514  101  -0.001225    122314 -122315 -123327  121394 
                        -121395 -122008  122007            imp:n=1   $ air above sample tube bevel
c
12614  101  -0.001225    122311 -122313  121393 -121392  
                         121363 -122008  122007            imp:n=1   $ air around sample tube
c
c
c ---- Position 15 ----
c
12115  101  -0.001225    122312 -122314 -121324            imp:n=1   $ Air inside sample tube
12215  103  -2.70        122311 -122312 -121324            imp:n=1   $ Bottom cap of tube  
12315  103  -2.70        122311 -122314  121324 -121325    imp:n=1   $ Sample tube         
c
12415  103  -2.70        122313  123308  121394 -121395  
                        -122007 -122315  122006  121325    imp:n=1   $ Sample ring around position
c
12515  101  -0.001225    122314 -122315 -123308  121394 
                        -121395 -122007  122006            imp:n=1   $ air above sample tube bevel
c
12615  101  -0.001225    122311 -122313  121393 -121392  
                         121325 -122007  122006            imp:n=1   $ air around sample tube
c
12715  103  -2.70       -122314  121325 -123308  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 16 ----
c
12116  101  -0.001225    122312 -122314 -121364            imp:n=1   $ Air inside sample tube
12216  103  -2.70        122311 -122312 -121364            imp:n=1   $ Bottom cap of tube  
12316  103  -2.70        122311 -122314  121364 -121365    imp:n=1   $ Sample tube         
c
12416  103  -2.70        122313  123328  121394 -121395  
                        -122006 -122315  122005  121365    imp:n=1   $ Sample ring around position
c
12516  101  -0.001225    122314 -122315 -123328  121394 
                        -121395 -122006  122005            imp:n=1   $ air above sample tube bevel
c
12616  101  -0.001225    122311 -122313  121393 -121392  
                         121365 -122006  122005            imp:n=1   $ air around sample tube
c
12716  103  -2.70       -122314  121365 -123328  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 17 ----
c
12117  101  -0.001225    122312 -122314 -121326            imp:n=1   $ Air inside sample tube
12217  103  -2.70        122311 -122312 -121326            imp:n=1   $ Bottom cap of tube  
12317  103  -2.70        122311 -122314  121326 -121327    imp:n=1   $ Sample tube         
c
12417  103  -2.70        122313  123309  121394 -121395  
                        -122005 -122315  122004  121327    imp:n=1   $ Sample ring around position
c
12517  101  -0.001225    122314 -122315 -123309  121394 
                        -121395 -122005  122004            imp:n=1   $ air above sample tube bevel
c
12617  101  -0.001225    122311 -122313  121393 -121392  
                         121327 -122005  122004            imp:n=1   $ air around sample tube
c
12717  103  -2.70       -122314  121327 -123309  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 18 ----
c
12118  101  -0.001225    122312 -122314 -121366            imp:n=1   $ Air inside sample tube
12218  103  -2.70        122311 -122312 -121366            imp:n=1   $ Bottom cap of tube  
12318  103  -2.70        122311 -122314  121366 -121367    imp:n=1   $ Sample tube         
c
12418  103  -2.70        122313  123329  121394 -121395  
                        -122004 -122315  122003  121367    imp:n=1   $ Sample ring around position
c
12518  101  -0.001225    122314 -122315 -123329  121394 
                        -121395 -122004  122003            imp:n=1   $ air above sample tube bevel
c
12618  101  -0.001225    122311 -122313  121393 -121392  
                         121367 -122004  122003            imp:n=1   $ air around sample tube
c
12718  103  -2.70       -122314  121367 -123329  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 19 ----
c
12119  101  -0.001225    122312 -122314 -121328            imp:n=1   $ Air inside sample tube
12219  103  -2.70        122311 -122312 -121328            imp:n=1   $ Bottom cap of tube  
12319  103  -2.70        122311 -122314  121328 -121329    imp:n=1   $ Sample tube         
c
12419  103  -2.70        122313  123310  121394 -121395  
                        -122003 -122315  122002  121329    imp:n=1   $ Sample ring around position
c
12519  101  -0.001225    122314 -122315 -123310  121394 
                        -121395 -122003  122002            imp:n=1   $ air above sample tube bevel
c
12619  101  -0.001225    122311 -122313  121393 -121392  
                         121329 -122003  122002            imp:n=1   $ air around sample tube
c
12719  103  -2.70       -122314  121329 -123310  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 20 ----
c
12120  101  -0.001225    122312 -122314 -121368            imp:n=1   $ Air inside sample tube
12220  103  -2.70        122311 -122312 -121368            imp:n=1   $ Bottom cap of tube  
12320  103  -2.70        122311 -122314  121368 -121369    imp:n=1   $ Sample tube         
c
12420  103  -2.70        122313  123330  121394 -121395  
                        -122002 -122315  122001  121369    imp:n=1   $ Sample ring around position
c
12520  101  -0.001225    122314 -122315 -123330  121394 
                        -121395 -122002  122001            imp:n=1   $ air above sample tube bevel
c
12620  101  -0.001225    122311 -122313  121393 -121392  
                         121369 -122002  122001            imp:n=1   $ air around sample tube
c
12720  103  -2.70       -122314  121369 -123330  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 21 ----
c
12121  101  -0.001225    122312 -122314 -121330            imp:n=1   $ Air inside sample tube
12221  103  -2.70        122311 -122312 -121330            imp:n=1   $ Bottom cap of tube  
12321  103  -2.70        122311 -122314  121330 -121331    imp:n=1   $ Sample tube         
c
12421  103  -2.70        122313  123311  121394 -121395  
                        -122001 -122315 -122020  121331    imp:n=1   $ Sample ring around position
c
12521  101  -0.001225    122314 -122315 -123311  121394 
                        -121395 -122001 -122020            imp:n=1   $ air above sample tube bevel
c
12621  101  -0.001225    122311 -122313  121393 -121392  
                         121331 -122001 -122020            imp:n=1   $ air around sample tube
c
12721  103  -2.70       -122314  121331 -123311  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 22 ----
c
12122  101  -0.001225    122312 -122314 -121370            imp:n=1   $ Air inside sample tube
12222  103  -2.70        122311 -122312 -121370            imp:n=1   $ Bottom cap of tube  
12322  103  -2.70        122311 -122314  121370 -121371    imp:n=1   $ Sample tube         
c
12422  103  -2.70        122313  123331  121394 -121395  
                         122020 -122315 -122019  121371    imp:n=1   $ Sample ring around position
c
12522  101  -0.001225    122314 -122315 -123331  121394 
                        -121395  122020 -122019            imp:n=1   $ air above sample tube bevel
c
12622  101  -0.001225    122311 -122313  121393 -121392  
                         121371  122020 -122019            imp:n=1   $ air around sample tube
c
12722  103  -2.70       -122314  121371 -123331  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 23 ----
c
12123  101  -0.001225    122312 -122314 -121332            imp:n=1   $ Air inside sample tube
12223  103  -2.70        122311 -122312 -121332            imp:n=1   $ Bottom cap of tube  
12323  103  -2.70        122311 -122314  121332 -121333    imp:n=1   $ Sample tube         
c
12423  103  -2.70        122313  123312  121394 -121395  
                         122019 -122315 -122018  121333    imp:n=1   $ Sample ring around position
c
12523  101  -0.001225    122314 -122315 -123312  121394 
                        -121395  122019 -122018            imp:n=1   $ air above sample tube bevel
c
12623  101  -0.001225    122311 -122313  121393 -121392  
                         121333  122019 -122018            imp:n=1   $ air around sample tube
c
12723  103  -2.70       -122314  121333 -123312  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 24 ----
c
12124  101  -0.001225    122312 -122314 -121372            imp:n=1   $ Air inside sample tube
12224  103  -2.70        122311 -122312 -121372            imp:n=1   $ Bottom cap of tube  
12324  103  -2.70        122311 -122314  121372 -121373    imp:n=1   $ Sample tube         
c
12424  103  -2.70        122313  123332  121394 -121395  
                         122018 -122315 -122017  121373    imp:n=1   $ Sample ring around position
c
12524  101  -0.001225    122314 -122315 -123332  121394 
                        -121395  122018 -122017            imp:n=1   $ air above sample tube bevel
c
12624  101  -0.001225    122311 -122313  121393 -121392  
                         121373  122018 -122017            imp:n=1   $ air around sample tube
c
12724  103  -2.70       -122314  121373 -123332  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 25 ----
c
12125  101  -0.001225    122312 -122314 -121334            imp:n=1   $ Air inside sample tube
12225  103  -2.70        122311 -122312 -121334            imp:n=1   $ Bottom cap of tube  
12325  103  -2.70        122311 -122314  121334 -121335    imp:n=1   $ Sample tube         
c
12425  103  -2.70        122313  123313  121394 -121395  
                         122017 -122315 -122016  121335    imp:n=1   $ Sample ring around position
c
12525  101  -0.001225    122314 -122315 -123313  121394 
                        -121395  122017 -122016            imp:n=1   $ air above sample tube bevel
c
12625  101  -0.001225    122311 -122313  121393 -121392  
                         121335  122017 -122016            imp:n=1   $ air around sample tube
c
12725  103  -2.70       -122314  121335 -123313  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 26 ----
c
12126  101  -0.001225    122312 -122314 -121374            imp:n=1   $ Air inside sample tube
12226  103  -2.70        122311 -122312 -121374            imp:n=1   $ Bottom cap of tube  
12326  103  -2.70        122311 -122314  121374 -121375    imp:n=1   $ Sample tube         
c
12426  103  -2.70        122313  123333  121394 -121395  
                         122016 -122315 -122015  121375    imp:n=1   $ Sample ring around position
c
12526  101  -0.001225    122314 -122315 -123333  121394 
                        -121395  122016 -122015            imp:n=1   $ air above sample tube bevel
c
12626  101  -0.001225    122311 -122313  121393 -121392  
                         121375  122016 -122015            imp:n=1   $ air around sample tube
c
12726  103  -2.70       -122314  121375 -123333  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 27 ----
c
12127  101  -0.001225    122312 -122314 -121336            imp:n=1   $ Air inside sample tube
12227  103  -2.70        122311 -122312 -121336            imp:n=1   $ Bottom cap of tube  
12327  103  -2.70        122311 -122314  121336 -121337    imp:n=1   $ Sample tube         
c
12427  103  -2.70        122313  123314  121394 -121395  
                         122015 -122315 -122014  121337    imp:n=1   $ Sample ring around position
c
12527  101  -0.001225    122314 -122315 -123314  121394 
                        -121395  122015 -122014            imp:n=1   $ air above sample tube bevel
c
12627  101  -0.001225    122311 -122313  121393 -121392  
                         121337  122015 -122014            imp:n=1   $ air around sample tube
c
12727  103  -2.70       -122314  121337 -123314  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 28 ----
c
12128  101  -0.001225    122312 -122314 -121376            imp:n=1   $ Air inside sample tube
12228  103  -2.70        122311 -122312 -121376            imp:n=1   $ Bottom cap of tube  
12328  103  -2.70        122311 -122314  121376 -121377    imp:n=1   $ Sample tube         
c
12428  103  -2.70        122313  123334  121394 -121395  
                         122014 -122315 -122013  121377    imp:n=1   $ Sample ring around position
c
12528  101  -0.001225    122314 -122315 -123334  121394 
                        -121395  122014 -122013            imp:n=1   $ air above sample tube bevel
c
12628  101  -0.001225    122311 -122313  121393 -121392  
                         121377  122014 -122013            imp:n=1   $ air around sample tube
c
12728  103  -2.70       -122314  121377 -123334  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 29 ----
c
12129  101  -0.001225    122312 -122314 -121338            imp:n=1   $ Air inside sample tube
12229  103  -2.70        122311 -122312 -121338            imp:n=1   $ Bottom cap of tube  
12329  103  -2.70        122311 -122314  121338 -121339    imp:n=1   $ Sample tube         
c
12429  103  -2.70        122313  123315  121394 -121395  
                         122013 -122315 -122012  121339    imp:n=1   $ Sample ring around position
c
12529  101  -0.001225    122314 -122315 -123315  121394 
                        -121395  122013 -122012            imp:n=1   $ air above sample tube bevel
c
12629  101  -0.001225    122311 -122313  121393 -121392  
                         121339  122013 -122012            imp:n=1   $ air around sample tube
c
12729  103  -2.70       -122314  121339 -123315  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 30 ----
c
12130  101  -0.001225    122312 -122314 -121378            imp:n=1   $ Air inside sample tube
12230  103  -2.70        122311 -122312 -121378            imp:n=1   $ Bottom cap of tube  
12330  103  -2.70        122311 -122314  121378 -121379    imp:n=1   $ Sample tube         
c
12430  103  -2.70        122313  123335  121394 -121395  
                         122012 -122315 -122011  121379    imp:n=1   $ Sample ring around position
c
12530  101  -0.001225    122314 -122315 -123335  121394 
                        -121395  122012 -122011            imp:n=1   $ air above sample tube bevel
c
12630  101  -0.001225    122311 -122313  121393 -121392  
                         121379  122012 -122011            imp:n=1   $ air around sample tube
c
12730  103  -2.70       -122314  121379 -123335  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 31 ----
c
12131  101  -0.001225    122312 -122314 -121340            imp:n=1   $ Air inside sample tube
12231  103  -2.70        122311 -122312 -121340            imp:n=1   $ Bottom cap of tube  
12331  103  -2.70        122311 -122314  121340 -121341    imp:n=1   $ Sample tube         
c
12431  103  -2.70        122313  123316  121394 -121395  
                         122011 -122315 -122010  121341    imp:n=1   $ Sample ring around position
c
12531  101  -0.001225    122314 -122315 -123316  121394 
                        -121395  122011 -122010            imp:n=1   $ air above sample tube bevel
c
12631  101  -0.001225    122311 -122313  121393 -121392  
                         121341  122011 -122010            imp:n=1   $ air around sample tube
c
12731  103  -2.70       -122314  121341 -123316  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 32 ----
c
12132  101  -0.001225    122312 -122314 -121380             imp:n=1   $ Air inside sample tube
12232  103  -2.70        122311 -122312 -121380            imp:n=1   $ Bottom cap of tube  
12332  103  -2.70        122311 -122314  121380 -121381    imp:n=1   $ Sample tube         
c
12432  103  -2.70        122313  123336  121394 -121395  
                         122010 -122315 -122009  121381    imp:n=1   $ Sample ring around position
c
12532  101  -0.001225    122314 -122315 -123336  121394 
                        -121395  122010 -122009            imp:n=1   $ air above sample tube bevel
c
12632  101  -0.001225    122311 -122313  121393 -121392  
                         121381  122010 -122009            imp:n=1   $ air around sample tube
c
12732  103  -2.70       -122314  121381 -123336  192350    imp:n=1   $ sample tube hole fix
c
c ---- Position 33 ----
c
12133  101  -0.001225    122312 -122314 -121342            imp:n=1   $ Air inside sample tube
12233  103  -2.70        122311 -122312 -121342            imp:n=1   $ Bottom cap of tube  
12333  103  -2.70        122311 -122314  121342 -121343    imp:n=1   $ Sample tube         
c
12433  103  -2.70        122313  123317  121394 -121395  
                         122009 -122315 -122008  121343    imp:n=1   $ Sample ring around position
c
12533  101  -0.001225    122314 -122315 -123317  121394 
                        -121395  122009 -122008            imp:n=1   $ air above sample tube bevel
c
12633  101  -0.001225    122311 -122313  121393 -121392  
                         121343  122009 -122008            imp:n=1   $ air around sample tube
c
12733  103  -2.70       -122314  121343 -123317  192350    imp:n=1   $ sample tube hole fix
c
c ---- Position 34 ----
c
12134  101  -0.001225    122312 -122314 -121382            imp:n=1   $ Air inside sample tube
12234  103  -2.70        122311 -122312 -121382            imp:n=1   $ Bottom cap of tube  
12334  103  -2.70        122311 -122314  121382 -121383    imp:n=1   $ Sample tube         
c
12434  103  -2.70        122313  123337  121394 -121395  
                         122008 -122315 -122007  121383    imp:n=1   $ Sample ring around position
c
12534  101  -0.001225    122314 -122315 -123337  121394 
                        -121395  122008 -122007            imp:n=1   $ air above sample tube bevel
c
12634  101  -0.001225    122311 -122313  121393 -121392  
                         121383  122008 -122007            imp:n=1   $ air around sample tube
c
12734  103  -2.70       -122314  121383 -123337  192350    imp:n=1   $ sample tube hole fix
c
c ---- Position 35 ----
c
12135  101  -0.001225    122312 -122314 -121344            imp:n=1   $ Air inside sample tube
12235  103  -2.70        122311 -122312 -121344            imp:n=1   $ Bottom cap of tube  
12335  103  -2.70        122311 -122314  121344 -121345    imp:n=1   $ Sample tube         
c
12435  103  -2.70        122313  123318  121394 -121395  
                         122007 -122315 -122006  121345    imp:n=1   $ Sample ring around position
c
12535  101  -0.001225    122314 -122315 -123318  121394 
                        -121395  122007 -122006            imp:n=1   $ air above sample tube bevel
c
12635  101  -0.001225    122311 -122313  121393 -121392  
                         121345  122007 -122006            imp:n=1   $ air around sample tube
c
12735  103  -2.70       -122314  121345 -123318  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 36 ----
c
12136  101  -0.001225    122312 -122314 -121384            imp:n=1   $ Air inside sample tube
12236  103  -2.70        122311 -122312 -121384            imp:n=1   $ Bottom cap of tube  
12336  103  -2.70        122311 -122314  121384 -121385    imp:n=1   $ Sample tube         
c
12436  103  -2.70        122313  123338  121394 -121395  
                         122006 -122315 -122005  121385    imp:n=1   $ Sample ring around position
c
12536  101  -0.001225    122314 -122315 -123338  121394 
                        -121395  122006 -122005            imp:n=1   $ air above sample tube bevel
c
12636  101  -0.001225    122311 -122313  121393 -121392  
                         121385  122006 -122005            imp:n=1   $ air around sample tube
c
12736  103  -2.70       -122314  121385 -123338  192350    imp:n=1   $ sample tube hole fix
c
c ---- Position 37 ----
c
12137  101  -0.001225    122312 -122314 -121346            imp:n=1   $ Air inside sample tube
12237  103  -2.70        122311 -122312 -121346            imp:n=1   $ Bottom cap of tube  
12337  103  -2.70        122311 -122314  121346 -121347    imp:n=1   $ Sample tube         
c
12437  103  -2.70        122313  123319  121394 -121395  
                         122005 -122315 -122004  121347    imp:n=1   $ Sample ring around position
c
12537  101  -0.001225    122314 -122315 -123319  121394 
                        -121395  122005 -122004            imp:n=1   $ air above sample tube bevel
c
12637  101  -0.001225    122311 -122313  121393 -121392  
                         121347  122005 -122004            imp:n=1   $ air around sample tube
c
12737  103  -2.70       -122314  121347 -123319  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 38 ----
c
12138  101  -0.001225    122312 -122314 -121386            imp:n=1   $ Air inside sample tube
12238  103  -2.70        122311 -122312 -121386            imp:n=1   $ Bottom cap of tube  
12338  103  -2.70        122311 -122314  121386 -121387    imp:n=1   $ Sample tube         
c
12438  103  -2.70        122313  123339  121394 -121395  
                         122004 -122315 -122003  121387    imp:n=1   $ Sample ring around position
c
12538  101  -0.001225    122314 -122315 -123339  121394 
                        -121395  122004 -122003            imp:n=1   $ air above sample tube bevel
c
12638  101  -0.001225    122311 -122313  121393 -121392  
                         121387  122004 -122003            imp:n=1   $ air around sample tube
c
12738  103  -2.70       -122314  121387 -123339  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 39 ----
c
12139  101  -0.001225    122312 -122314 -121348            imp:n=1   $ Air inside sample tube
12239  103  -2.70        122311 -122312 -121348            imp:n=1   $ Bottom cap of tube  
12339  103  -2.70        122311 -122314  121348 -121349    imp:n=1   $ Sample tube         
c
12439  103  -2.70        122313  123320  121394 -121395  
                         122003 -122315 -122002  121349    imp:n=1   $ Sample ring around position
c
12539  101  -0.001225    122314 -122315 -123320  121394 
                        -121395  122003 -122002            imp:n=1   $ air above sample tube bevel
c
12639  101  -0.001225    122311 -122313  121393 -121392  
                         121349  122003 -122002            imp:n=1   $ air around sample tube
c
12739  103  -2.70       -122314  121349 -123320  192350    imp:n=1   $ sample tube hole fix
c
c
c ---- Position 40 ----
c
12140  101  -0.001225    122312 -122314 -121388            imp:n=1   $ Air inside sample tube
12240  103  -2.70        122311 -122312 -121388            imp:n=1   $ Bottom cap of tube  
12340  103  -2.70        122311 -122314  121388 -121389    imp:n=1   $ Sample tube         
c
12440  103  -2.70        122313  123340  121394 -121395  
                         122002 -122315 -122001  121389    imp:n=1   $ Sample ring around position
c
12540  101  -0.001225    122314 -122315 -123340  121394 
                        -121395  122002 -122001            imp:n=1   $ air above sample tube bevel
c
12640  101  -0.001225    122311 -122313  121393 -121392  
                         121389  122002 -122001            imp:n=1   $ air around sample tube
c
12740  103  -2.70       -122314  121389 -123340  192350    imp:n=1   $ sample tube hole fix
c
c
c --Begin Core Water Cells--
c ------------------------------
c --------- Core water ---------
c ------------------------------
c
c  ---- replacement water for debugging ----
c
13501  102  -0.997903   10     -112304  111397 -131302
                   902019  902029  902039  902049  902059  902069   imp:n=1 tmp=2.526170e-08   $ Inner core water B ring
c
c
13502  102  -0.997903   10     -112304  131302 -131303
                   903019  903029  903039  903049  903059  903069
                   903079  903089  903099  903109  903119  903129   imp:n=1  tmp=2.526170e-08  $ Inner core water C ring
c
c
13503  102  -0.997903   10     -112304  131303 -131304
                   904019  904029  904039  904049  904059  904069
                   904079  904089  904099  904109  904119  904129
                   904139  904149  904159  904169  904179  904189   imp:n=1  tmp=2.526170e-08  $ Inner core water D ring
c
c
13504  102  -0.997903   10     -112304  131304 -131305
                   905019  905029  905039  905049  905059  905069
                   905079  905089  905099  905109  905119  905129
                   905139  905149  905159  905169  905179  905189
                   905199  905209  905219  905229  905239  905249   imp:n=1  tmp=2.526170e-08  $ Inner core water E ring
c
c
13505  102  -0.997903   10     -112304  131305 -121301
                   906019  906029  906039  906049  906059  906069
                   906079  906089  906099  906109  906119  906129
                   906139  906149  906159  906169  906179  906189
                   906199  906209  906219  906229  906239  906249
                   906259  906269  906279  906289  906299  906309   imp:n=1 tmp=2.526170e-08   $ Inner core water E ring
c
c
c
c
c
13601  102  -0.997903   112305 -11      111397 -131302
                   902019  902029  902039  902049  902059  902069   imp:n=1 tmp=2.526170e-08   $ upper core water B ring
c
c
13602  102  -0.997903   112305 -11      131302 -131303
                   903019  903029  903039  903049  903059  903069
                   903079  903089  903099  903109  903119  903129   imp:n=1  tmp=2.526170e-08  $ upper core water C ring
c
c
13603  102  -0.997903   112305 -11      131303 -131304
                   904019  904029  904039  904049  904059  904069
                   904079  904089  904099  904109  904119  904129
                   904139  904149  904159  904169  904179  904189   imp:n=1  tmp=2.526170e-08  $ upper core water D ring
c
c
13604  102  -0.997903   112305 -11      131304 -131305  501307
                   905019  905029  905039  905049  905059  905069
                   905079  905089  905099  905109  905119  905129
                   905139  905149  905159  905169  905179  905189
                   905199  905209  905219  905229  905239  905249   imp:n=1  tmp=2.526170e-08  $ upper core water E ring
c
c
13605  102  -0.997903   112305 -11      131305 -121390
                   906019  906029  906039  906049  906059  906069
                   906079  906089  501307  906109  906119  906129
                   906139  906149  906159  906169  906179  906189
                   906199  906209  906219  906229  906239  906249
                   906259  906269  906279  906289  906299  906309   imp:n=1  tmp=2.526170e-08  $ upper core water E ring
c
c
c
c
c
c ------ Main outer core water cells ------- 
c
c
13301  102   -0.997903   11     -192301  111397 -121390  
                  903059  903099  905019  501307   imp:n=1 tmp=2.526170e-08   $ Water above upper grid plate
c
13302  102   -0.997903   122306 -112304  121301 -121390   imp:n=1  tmp=2.526170e-08 $ Water under upper grid plate
13303  102   -0.997903   112304 -112305  111399 -121390   imp:n=1  tmp=2.526170e-08 $ Water above upper grid plate
c
13304  102   -0.997903   122310 -192301  121390 -121305   imp:n=1  tmp=2.526170e-08 $ Water above LS assy
13305  102   -0.997903   122306 -192301  121305 -121308   imp:n=1  tmp=2.526170e-08 $ Water above outer section of reflector assy
13306  102   -0.997903   192399 -192301  121308 -191301   imp:n=1  tmp=2.526170e-08 $ Water around reflector assy
c
13307  102   -0.997903   192399 -112301  111397 -121308   imp:n=1  tmp=2.526170e-08 $ Water below lower grid plate
13308  102   -0.997903   112301 -122301  121301 -121308   imp:n=1  tmp=2.526170e-08 $ Water below reflector assy
13309  102   -0.997903   112301 -10      111398 -121301   imp:n=1  tmp=2.526170e-08 $ Water around lower grid plate
c
c --End Core Water Cells--
c
c ------------------------------
c ------ Central Thimble -------
c ------------------------------
c
14000  103  -2.7   142302 -192301  141300 -111300   imp:n=1   $ Central thimble main tube
14001  102  -0.997903   142302 -142303 -141300           imp:n=1  tmp=2.526170e-08 $ Central thimble inevacuable water
c
14002  102  -0.997903   142303 -192301 -141300  imp:n=1   tmp=2.526170e-08 $ Central thimble evacuable water      ------ change material to air to open beam ------
c
14003  103  -2.7   142301 -142302 -111300           imp:n=1   $ Central thimble bottom cap
14004  102   -0.997903    142301 -112304  111300 -111397   imp:n=1  tmp=2.526170e-08 $ Water around central thimble below upper grid plate
14005  102   -0.997903    112305 -192301  111300 -111397   imp:n=1  tmp=2.526170e-08 $ Water around central thimble above upper grid plate
14006  102   -0.997903    192399 -142301 -111397           imp:n=1  tmp=2.526170e-08 $ Water below central thimble
c
c
c
c ------------------------------
c --------- Flux wires ---------
c ------------------------------
c
17001  102  -0.997903  -111301  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole A  upper grid area
17002  102  -0.997903  -111302  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole B  upper grid area
17003  102  -0.997903  -111303  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole C  upper grid area
17004  102  -0.997903  -111304  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole D  upper grid area
17005  102  -0.997903  -111305  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole E  upper grid area
17006  102  -0.997903  -111306  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole F  upper grid area
17007  102  -0.997903  -111307  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole G  upper grid area
17008  102  -0.997903  -111308  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole H  upper grid area
17009  102  -0.997903  -111309  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole J  upper grid area
17010  102  -0.997903  -111310  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole K  upper grid area
17011  102  -0.997903  -111311  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole L  upper grid area
17012  102  -0.997903  -111312  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole A1 upper grid area
17013  102  -0.997903  -111313  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole B1 upper grid area
17014  102  -0.997903  -111314  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole C1 upper grid area
17015  102  -0.997903  -111315  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole D1 upper grid area
17016  102  -0.997903  -111316  112304 -112305  imp:n=1 tmp=2.526170e-08 $ Flux wire insertion hole E1 upper grid area
c
c
c
c ------------------------------
c ----------- Rabbit -----------
c ------------------------------
c
c ----- Alumunum components -----
c
60901  103  -2.70  10     -502301 -503301   imp:n=1   $ Lower taper 
60902  103  -2.70  502301 -502302 -501306   imp:n=1   $ Lower section
60903  103  -2.70  502302 -502303 -503302   imp:n=1   $ Lower section upper taper
c
60904  103  -2.70  502303 -502304 -503303   imp:n=1   $ Mid section lower taper
60905  103  -2.70  502304 -502305 -501306   imp:n=1   $ Mid section
60906  103  -2.70  502305 -502306 -503304   imp:n=1   $ Mid section upper taper
60907  103  -2.70  502306 -502307 -501301   imp:n=1   $ Upper post
60908  103  -2.70  503304 -502306 -501301   imp:n=1   $ Upper post correction             ------ big problems here ---- 
c
c
60909  103  -2.70  502307 -502308 -501306           imp:n=1   $ Main section lower portion
60910  103  -2.70  502308 -502309  501304 -501306   imp:n=1   $ Main section lower bezel
60911  103  -2.70  502309 -502310  501305 -501306   imp:n=1   $ Main section thin tube
60912  103  -2.70  502310 -192301  501305 -501307   imp:n=1   $ Main section thick tube    ------ big problems here ----  
c
60913  103  -2.70  502311 -502312  501308 -501303   imp:n=1   $ Sample holder annulus
60914  103  -2.70  502312 -192301  501302 -501303   imp:n=1   $ Inner tube
c
c 
c ----- Water components -----
c
60920  102  -0.997903   10     -502301  503301 -906099          imp:n=1  tmp=2.526170e-08 $ Water around lower bevel
60921  102  -0.997903   502301 -502302  501306 -906099          imp:n=1  tmp=2.526170e-08 $ Water around lower section
60922  102  -0.997903   502302 -502303  503302 -906099          imp:n=1  tmp=2.526170e-08 $ Water around lower section upper bevel
60923  102  -0.997903   502303 -502304  503303 -906099          imp:n=1  tmp=2.526170e-08 $ Water around mid section lower bevel
60924  102  -0.997903   502304 -502305  501306 -906099          imp:n=1  tmp=2.526170e-08 $ Water around mid section
60925  102  -0.997903   502305 -502306  503304 -906099  501301  imp:n=1  tmp=2.526170e-08 $ Water around mid section upper bevel
60926  102  -0.997903   502306 -502307  501301 -906099          imp:n=1  tmp=2.526170e-08 $ Water around post
60927  102  -0.997903   502307 -502310  501306 -906099          imp:n=1  tmp=2.526170e-08 $ Water around rabbit tube
60928  102  -0.997903   112305 -502310  906099 -501307          imp:n=1  tmp=2.526170e-08 $ Water above upper grid plate around thin tube    ----- so many problems ----- 
c
c
c ----- Air elements ---- 
c
60930  101  -0.001225   502308 -502309 -501304           imp:n=1   $ Air in bezel
60931  101  -0.001225   502309 -502311 -501305           imp:n=1   $ Air under sample holder
60932  101  -0.001225   502311 -502312 -501308           imp:n=1   $ Air in sample holder 
60933  101  -0.001225   502311 -192301  501303 -501305   imp:n=1   $ Air b/w inside and outside tube
c
42069  101  -0.001225   552305 -552307 -501311           imp:n=1   $ Air inside inner vial    ----- this is the cell on which to do the F4 tally -----
60935  101  -0.001225   552303 -552308  501312 -501313   imp:n=1   $ Air around inner vial
60936  101  -0.001225   552308 -552309 -501313           imp:n=1   $ Air inside outer vial
60937  101  -0.001225   552310 -552314 -501308           imp:n=1   $ Air inside rabbit tube
c
60950  101  -0.001225   502312 -552304  553301 -501302           imp:n=1   $ Air around lower bevel lower section
60951  101  -0.001225   552304 -552306  553302 -501302           imp:n=1   $ Air around lower bevel upper section
60952  101  -0.001225   552306 -502313  501301 -501302           imp:n=1   $ Air around rabbit tube
60953  101  -0.001225   502313 -552311  501301  553303 -501302   imp:n=1   $ Air around upper bevel lower section
60954  101  -0.001225   552311  553303 -501302 -552313           imp:n=1   $ Air around upper bevel mid section
60955  101  -0.001225   501317 -552313 -553303  552311 -501302   imp:n=1   $ Air around upper bevel top section
60956  101  -0.001225   552313 -552315  501318 -501302           imp:n=1   $ Air around rabbit tube cap
60957  101  -0.001225   552315 -192301 -501302                   imp:n=1   $ Air in rabbit
c
c
c
c ---- Poly elements -----  (Comment out to make empty rabbit terminus)
c
c 60940  109  -0.97   502312 -552302 -501308                   imp:n=1   $ bottom of rabbit tube
c 60941  109  -0.97   502312 -552312  501308 -501301           imp:n=1   $ Main section rabbit tube
c 60942  109  -0.97   502312 -552304  501301 -501318 -553301   imp:n=1   $ Rabbit tube lower bevel lower section
c 60943  109  -0.97   552304 -552306  501301 -501318 -553302   imp:n=1   $ Rabbit tube lower bevel upper section
c 60944  109  -0.97  -552312  501301 -553303  552310 -501317   imp:n=1   $ Rabbit tube upper bevel
c 60945  109  -0.97   552312 -552313  501308 -501317           imp:n=1   $ Rabbit tube upper section
c 60946  109  -0.97   552314 -552315 -501318                   imp:n=1   $ Rabbit tube cap upper section
c 60947  109  -0.97   552313 -552314  501308 -501318           imp:n=1   $ Rabbit tube tube
c
c 60960  109  -0.97   552302 -552303 -501308                   imp:n=1   $ Outer vial bottom
c 60961  109  -0.97   552303 -552309  501313 -501308           imp:n=1   $ Outer vial tube
c 60962  109  -0.97   552309 -552310 -501308                   imp:n=1   $ Outer vial top
c
c 60963  109  -0.97   552303 -552305 -501312                   imp:n=1   $ Inner vial bottom
c 60964  109  -0.97   552305 -552307  501311 -501312           imp:n=1   $ Inner vial tube
c 60965  109  -0.97   552307 -552308 -501312                   imp:n=1   $ Inner vial top
c
c
c
c ----- Air replacement elements ----- (Comment out to make put sample in terminus)
c
60940  101  -0.001225   502312 -552302 -501308                   imp:n=1   $ bottom of rabbit tube
60941  101  -0.001225   502312 -552312  501308 -501301           imp:n=1   $ Main section rabbit tube
60942  101  -0.001225   502312 -552304  501301 -501318 -553301   imp:n=1   $ Rabbit tube lower bevel lower section
60943  101  -0.001225   552304 -552306  501301 -501318 -553302   imp:n=1   $ Rabbit tube lower bevel upper section
60944  101  -0.001225  -552312  501301 -553303  552310 -501317   imp:n=1   $ Rabbit tube upper bevel
60945  101  -0.001225   552312 -552313  501308 -501317           imp:n=1   $ Rabbit tube upper section
60946  101  -0.001225   552314 -552315 -501318                   imp:n=1   $ Rabbit tube cap upper section
60947  101  -0.001225   552313 -552314  501308 -501318           imp:n=1   $ Rabbit tube tube
c
60960  101  -0.001225   552302 -552303 -501308                   imp:n=1   $ Outer vial bottom
60961  101  -0.001225   552303 -552309  501313 -501308           imp:n=1   $ Outer vial tube
60962  101  -0.001225   552309 -552310 -501308                   imp:n=1   $ Outer vial top
  c
60963  101  -0.001225   552303 -552305 -501312                   imp:n=1   $ Inner vial bottom
60964  101  -0.001225   552305 -552307  501311 -501312           imp:n=1   $ Inner vial tube
60965  101  -0.001225   552307 -552308 -501312                   imp:n=1   $ Inner vial top
c
c
c
c
c
c
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c 
c
c
c
c
c
c
c ------------------------------
c ------ Installed sources -----
c ------------------------------
c
c
c
c
c
c
c
c ---- AmBe source (F23) ----
c
62301   103  -2.7        -172303  172302 -171301           imp:n=1 u=60   $ cylindrical section beneath cavity
62302   103  -2.7        -172304  172303 -171301  173301   imp:n=1 u=60   $ cylindrical section containing bottommost cavity cone
62303   103  -2.7        -172305  172304 -171301  171302   imp:n=1 u=60   $ aluminum encasing cylindrical part of cavity
62304   101  -0.0012922  -172306  172305 -173302           imp:n=1 u=60   $ half cone atop source cavity
62305   103  -2.7        -172306  172305 -171301  173302   imp:n=1 u=60   $ aluminum around half cone part of cavity
62306   101  -0.0012922  -172308  172306 -171303           imp:n=1 u=60   $ cylinder component of source cavity cap
62307   103  -2.7        -172308  172306 -171301  171303   imp:n=1 u=60   $ aluminum around cylindrical component of source cavity cap
62308   101  -2.7        -172309  172308 -173303           imp:n=1 u=60   $ cone on top of cavity cap
62309   103  -2.7        -172309  172308 -171301  173303   imp:n=1 u=60   $ aluminum encasing cone on top of cavity cap
62310   101  -0.0012922  -172305  172304 -171302           imp:n=1 u=60   $ inner cavity cylinder
62311   101  -0.0012922  -172304  172303 -173301           imp:n=1 u=60   $ inner cavity bottom cone
62312   103  -2.7        -172311  172309 -171301           imp:n=1 u=60   $ source holder above cavity
62313   103  -2.7        -172312  172311 -171306           imp:n=1 u=60   $ cap on source holder that rests on grid plate
62314   103  -2.7        -172313  172312 -171305           imp:n=1 u=60   $ cylindrical base on knob
62315   103  -2.7        -172314  172313 -173304           imp:n=1 u=60   $ lower half of corset on knob
62316   103  -2.7        -172315  172314 -173305           imp:n=1 u=60   $ upper half of corset on knob
62317   103  -2.7        -172316  172315 -171305           imp:n=1 u=60   $ upper cylindrical part of knob
62318   103  -2.7        -172317  172316 -173306           imp:n=1 u=60   $ upper cone on knob
62319   102  -0.997903        -172314  172313 -171305  173304   imp:n=1 u=60  tmp=2.526170e-08 $ water in nook of bottom half of corset on knob 
62320   102  -0.997903        -172315  172314 -171305  173305   imp:n=1 u=60  tmp=2.526170e-08 $ water in nook of top half of corset on knob
62321   102  -0.997903        -172317  172316 -171305  173306   imp:n=1 u=60  tmp=2.526170e-08 $ water around cone on end of knob
62322   102  -0.997903         172302 -112305  171301 -171306   imp:n=1 u=60  tmp=2.526170e-08 $ water around source
62323   102  -0.997903         10 -172302 -171306               imp:n=1 u=60  tmp=2.526170e-08 $ water below source
62324   102  -0.997903         172312 -11  171305 -171306       imp:n=1 u=60  tmp=2.526170e-08 $ Water around top
62325   102  -0.997903         172317 -11 -171305               imp:n=1 u=60  tmp=2.526170e-08 $ Water above top
c
c
c
c ---- IR-192 source (F25) ----
c
62501   103  -2.7        -172303  172302 -171310          imp:n=1 u=70  $ cylindrical section beneath cavity
62502   103  -2.7        -172304  172303 -171310  173310  imp:n=1 u=70  $ cylindrical section containing bottommost cavity cone
62503   103  -2.7        -172305  172304 -171310  171311  imp:n=1 u=70  $ aluminum encasing cylindrical part of cavity
62504   101  -0.0012922  -172306  172305 -173311          imp:n=1 u=70  $ half cone atop source cavity
62505   103  -2.7        -172306  172305 -171310  173311  imp:n=1 u=70  $ aluminum around half cone part of cavity
62506   101  -0.0012922  -172308  172306 -171312          imp:n=1 u=70  $ cylinder component of source cavity cap
62507   103  -2.7        -172308  172306 -171310  171312  imp:n=1 u=70  $ aluminum around cylindrical component of source cavity cap
62508   101  -2.7        -172309  172308 -173312          imp:n=1 u=70  $ cone on top of cavity cap
62509   103  -2.7        -172309  172308 -171310  173312  imp:n=1 u=70  $ aluminum encasing cone on top of cavity cap
62510   101  -0.0012922  -172305  172304 -171311          imp:n=1 u=70  $ inner cavity cylinder
62511   101  -0.0012922  -172304  172303 -173310          imp:n=1 u=70  $ inner cavity bottom cone
62512   103  -2.7        -172311  172309 -171310          imp:n=1 u=70  $ source holder above cavity
62513   103  -2.7        -172312  172311 -171315          imp:n=1 u=70  $ cap on source holder that rests on grid plate
62514   103  -2.7        -172313  172312 -171314          imp:n=1 u=70  $ cylindrical base on knob
62515   103  -2.7        -172314  172313 -173313          imp:n=1 u=70  $ lower half of corset on knob
62516   103  -2.7        -172315  172314 -173314          imp:n=1 u=70  $ upper half of corset on knob
62517   103  -2.7        -172316  172315 -171314          imp:n=1 u=70  $ upper cylindrical part of knob
62518   103  -2.7        -172317  172316 -173315          imp:n=1 u=70  $ upper cone on knob
62519   102  -0.997903        -172314  172313 -171314  173313  imp:n=1 u=70 tmp=2.526170e-08 $ water in nook of bottom half of corset on knob 
62520   102  -0.997903        -172315  172314 -171314  173314  imp:n=1 u=70 tmp=2.526170e-08 $ water in nook of top half of corset on knob
62521   102  -0.997903        -172317  172316 -171314  173315  imp:n=1 u=70 tmp=2.526170e-08 $ water around cone on end of knob
62522   102  -0.997903         172302 -112305  171310 -171315  imp:n=1 u=70 tmp=2.526170e-08 $ water around source
62523   102  -0.997903         10 -172302 -171315              imp:n=1 u=70 tmp=2.526170e-08 $ water below source
62524   102  -0.997903         172312 -11  171314 -171315      imp:n=1 u=70 tmp=2.526170e-08 $ Water around top
62525   102  -0.997903         172317 -11 -171314              imp:n=1 u=70 tmp=2.526170e-08 $ Water above top
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------------------------------
c -------- Control rods --------
c ------------------------------
c
c
c
c
c --- safe rod ---
c
30501   103  -2.7      -192301  812301 -811301                  imp:n=1  $ control rod connecting rod
30502   102  -0.997903      -192301  812301 -811304  811301          imp:n=1 tmp=2.526170e-08 $ water ring above control rod
30503   102  -0.997903       812302 -812301 -811304  811302  813301  imp:n=1 tmp=2.526170e-08 $ water above upper bevel
30504   103  -2.7       812302 -812301 -811304  811302 -813301  imp:n=1  $ control rod upper bevel
30505   103  -2.7      -812301  812302 -811302                  imp:n=1  $ top control rod inactive region
30506   103  -2.7      -812302  812303 -811304                  imp:n=1  $ upper control rod inactive region
c
30507   107  -1.80772   -811303 -812303  812304                  imp:n=1  $ control rod poison section
30523   106  -1.698      811303 -811305 -812303  812304                  imp:n=1  $ control rod poison burnup (graphite)
30508   103  -2.7        812305 -812303  811305 -811304          imp:n=1  $ control rod cladding
c
30509   103  -2.7      -812304  812305 -811305                  imp:n=1  $ lower control rod inactive section
30510   103  -2.7      -812305  812306 -811302                  imp:n=1  $ bottom control rod inactive section
30511   103  -2.7       811302 -811304 -812305  812306 -813302  imp:n=1  $ Outer lower bevel  
30512   103  -2.7      -811302 -812306  812307 -813303          imp:n=1  $ inner lower bevel  
30513   102  -0.997903       811302 -811304 -812305  812306  813302  imp:n=1 tmp=2.526170e-08 $ water around outer lower bevel   
30514   102  -0.997903      -811302 -812306  812307  813303          imp:n=1 tmp=2.526170e-08 $ water around inner lower bevel  
30515   102  -0.997903       811302 -811304  812307 -812306          imp:n=1 tmp=2.526170e-08 $ water under control rod bevels
c
30516   102  -0.997903      -812307  902301 -811304                  imp:n=1 tmp=2.526170e-08 $ water under control rod
c
30517   102  -0.997903       811304 -903057  902303 -192301          imp:n=1 tmp=2.526170e-08 $ water between safe rod and gride tube
30518   103  -2.7       903057 -903058  902303 -902399          imp:n=1  $ control rod guide tube main section
30519   102  -0.997903       903057 -903058  902399 -192301          imp:n=1 tmp=2.526170e-08 $ water above guide tube
30520   102  -0.997903       903058 -903059  10     -192301          imp:n=1 tmp=2.526170e-08 $ water around guide tube
30521   103  -2.7       811304 -903058  902301 -902303          imp:n=1  $ guide tube thick section
30522   103  -2.7      -903058  10     -902301                  imp:n=1  $ guide tube grid plate adapter
c
c
c
c
c --- shim rod ---
c
30901   103  -2.7      -192301  822301 -821301                  imp:n=1  $ control rod connecting rod
30902   102  -0.997903      -192301  822301 -821304  821301          imp:n=1 tmp=2.526170e-08 $ water ring above control rod
30903   102  -0.997903       822302 -822301 -821304  821302  823301  imp:n=1 tmp=2.526170e-08 $ water above upper bevel
30904   103  -2.7       822302 -822301 -821304  821302 -823301  imp:n=1  $ control rod upper bevel
30905   103  -2.7      -822301  822302 -821302                  imp:n=1  $ top control rod inactive region
30906   103  -2.7      -822302  822303 -821304                  imp:n=1  $ upper control rod inactive region
c
30907   107  -1.80772  -821303 -822303  822304                imp:n=1  $ control rod poison section
30923   106  -1.698     821303 -821305 -822303  822304                imp:n=1  $ control rod poison burnup (graphite)
30908   103  -2.7       822305 -822303  821305 -821304         imp:n=1  $ control rod cladding
c
30909   103  -2.7      -822304  822305 -821305                  imp:n=1  $ lower control rod inactive section
30910   103  -2.7      -822305  822306 -821302                  imp:n=1  $ bottom control rod inactive section
30911   103  -2.7       821302 -821304 -822305  822306 -823302  imp:n=1  $ Outer lower bevel  
30912   103  -2.7      -821302 -822306  822307 -823303          imp:n=1  $ inner lower bevel  
30913   102  -0.997903       821302 -821304 -822305  822306  823302  imp:n=1 tmp=2.526170e-08 $ water around outer lower bevel   
30914   102  -0.997903      -821302 -822306  822307  823303          imp:n=1 tmp=2.526170e-08 $ water around inner lower bevel  
30915   102  -0.997903       821302 -821304  822307 -822306          imp:n=1 tmp=2.526170e-08 $ water under control rod bevels
c
30916   102  -0.997903      -822307  902301 -821304                  imp:n=1 tmp=2.526170e-08 $ water under control rod
c
30917   102  -0.997903       821304 -903097  902303 -192301          imp:n=1 tmp=2.526170e-08 $ water between safe rod and gride tube
30918   103  -2.7       903097 -903098  902303 -902399          imp:n=1  $ control rod guide tube main section
30919   102  -0.997903       903097 -903098  902399 -192301          imp:n=1 tmp=2.526170e-08 $ water above guide tube
30920   102  -0.997903       903098 -903099  10     -192301          imp:n=1 tmp=2.526170e-08 $ water around guide tube
30921   103  -2.7       821304 -903098  902301 -902303          imp:n=1  $ guide tube thick section
30922   103  -2.7      -903098  10     -902301                  imp:n=1  $ guide tube grid plate adapter
c
c
c
c --- reg rod ---
c
50101   103  -2.7      -192301  832301 -831301                  imp:n=1  $ control rod connecting rod
50102   102  -0.997903      -192301  832301 -831304  831301          imp:n=1 tmp=2.526170e-08 $ water ring above control rod
50103   102  -0.997903       832302 -832301 -831304  831302  833301  imp:n=1 tmp=2.526170e-08 $ water above upper bevel
50104   103  -2.7       832302 -832301 -831304  831302 -833301  imp:n=1  $ control rod upper bevel
50105   103  -2.7      -832301  832302 -831302                  imp:n=1  $ top control rod inactive region
50106   103  -2.7      -832302  832303 -831304                  imp:n=1  $ upper control rod inactive region
c
50107   107  -1.80772   -831303 -832303  832304                imp:n=1  $ control rod poison section
50123   106  -1.698      831303 -831305 -832303  832304                imp:n=1  $ control rod poison burnup (graphite)
50108   103  -2.7        832305 -832303  831305 -831304          imp:n=1  $ control rod cladding
c
50109   103  -2.7      -832304  832305 -831305                  imp:n=1  $ lower control rod inactive section
50110   103  -2.7      -832305  832306 -831302                  imp:n=1  $ bottom control rod inactive section
50111   103  -2.7       831302 -831304 -832305  832306 -833302  imp:n=1  $ Outer lower bevel  
50112   103  -2.7      -831302 -832306  832307 -833303          imp:n=1  $ inner lower bevel  
50113   102  -0.997903       831302 -831304 -832305  832306  833302  imp:n=1 tmp=2.526170e-08 $ water around outer lower bevel   
50114   102  -0.997903      -831302 -832306  832307  833303          imp:n=1 tmp=2.526170e-08 $ water around inner lower bevel  
50115   102  -0.997903       831302 -831304  832307 -832306          imp:n=1 tmp=2.526170e-08 $ water under control rod bevels
c
50116   102  -0.997903      -832307  902301 -831304                  imp:n=1 tmp=2.526170e-08 $ water under control rod
c
50117   102  -0.997903       831304 -905017  902303 -192301          imp:n=1 tmp=2.526170e-08 $ water between safe rod and gride tube
50118   103  -2.7       905017 -905018  902303 -902399          imp:n=1  $ control rod guide tube main section
50119   102  -0.997903       905017 -905018  902399 -192301          imp:n=1 tmp=2.526170e-08 $ water above guide tube
50120   102  -0.997903       905018 -905019  10     -192301          imp:n=1 tmp=2.526170e-08 $ water around guide tube
50121   103  -2.7       831304 -905018  902301 -902303          imp:n=1  $ guide tube thick section
50122   103  -2.7      -905018  10     -902301                  imp:n=1  $ guide tube grid plate adapter    FIXME (probably not actually broken, just the last cell)
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c -----------------------------------------------------------------------------
c -----------------------------------------------------------------------------

c -----------------------------------------------------------------------------
c -------------------------- SURFACE CARDS ------------------------------------
c -----------------------------------------------------------------------------
c --Begin Surfaces-- $ for NIST MCNP syntax
c
c
c
c
c
c
c ------------------------------
c ------------ Model -----------
c ------------------------------
c
c
192301  pz   170  $ Top of model    --- malcolm make this bigger when adding the center channel assy ---
192399  pz  -100  $ Bottom of model
c
191301  cz   150  $ Outer limit of model
c
192350  pz  66.8336  $ temporary rabbit fix 
c
20  cz  1.914525 $ Generic fuel supercell 
c
c
c ------------------------------
c --------- Grid plates --------
c ------------------------------
c
c ---------- Upper grid plate ----------
c
111300  cz  1.90500  $ central thimble hole
c
111399  cz  24.6888  $ upper grid plate radius
c
112304  pz  64.7700  $ bottom of upper grid plate
112305  pz  66.6750  $ top of upper grid plate
c
c
c --- Upper grid plate fuel assembly holes ---
c
902019       c/z  0.00000  4.05384  1.914525         $ upper grid plate hole - B1
902029       c/z  3.51053  2.02692  1.914525         $ upper grid plate hole - B2   ---- problem ---- 
902039       c/z  3.51053 -2.02692  1.914525         $ upper grid plate hole - B3
902049       c/z  0.00000 -4.05384  1.914525         $ upper grid plate hole - B4 
902059       c/z -3.51053 -2.02692  1.914525         $ upper grid plate hole - B5 
902069       c/z -3.51053  2.02692  1.914525         $ upper grid plate hole - B6 
c
903019       c/z  0.00000  7.98068  1.914525         $ upper grid plate hole - C1
903029       c/z  3.99034  6.91134  1.914525         $ upper grid plate hole - C2 
903039       c/z  6.91134  3.99034  1.914525         $ upper grid plate hole - C3
903049       c/z  7.98068  0.00000  1.914525         $ upper grid plate hole - C4
903059       c/z  6.91134 -3.99034  1.914525         $ upper grid plate hole - C5
903069       c/z  3.99034 -6.91134  1.914525         $ upper grid plate hole - C6 
903079       c/z  0.00000 -7.98068  1.914525         $ upper grid plate hole - C7 
903089       c/z -3.99034 -6.91134  1.914525         $ upper grid plate hole - C8  
903099       c/z -6.91134 -3.99034  1.914525         $ upper grid plate hole - C9
903109       c/z -7.98068  0.00000  1.914525         $ upper grid plate hole - C10
903119       c/z -6.91130  3.99030  1.914525         $ upper grid plate hole - C11 
903129       c/z -3.99030  6.91130  1.914525         $ upper grid plate hole - C12 
c
904019       c/z  0.00000  11.9456  1.914525         $ upper grid plate hole - D1
904029       c/z  4.08530  11.2253  1.914525         $ upper grid plate hole - D2 
904039       c/z  7.67870  9.15040  1.914525         $ upper grid plate hole - D3 
904049       c/z  10.3449  5.97280  1.914525         $ upper grid plate hole - D4 
904059       c/z  11.7640  2.07370  1.914525         $ upper grid plate hole - D5 
904069       c/z  11.7640 -2.07370  1.914525         $ upper grid plate hole - D6 
904079       c/z  10.3449 -5.97280  1.914525         $ upper grid plate hole - D7
904089       c/z  7.67870 -9.15040  1.914525         $ upper grid plate hole - D8 
904099       c/z  4.08530 -11.2253  1.914525         $ upper grid plate hole - D9
904109       c/z  0.00000 -11.9456  1.914525         $ upper grid plate hole - D10
904119       c/z -4.08530 -11.2253  1.914525         $ upper grid plate hole - D11 
904129       c/z -7.67870 -9.15040  1.914525         $ upper grid plate hole - D12 
904139       c/z -10.3449 -5.97280  1.914525         $ upper grid plate hole - D13 
904149       c/z -11.7640 -2.07370  1.914525         $ upper grid plate hole - D14 
904159       c/z -11.7640  2.07370  1.914525         $ upper grid plate hole - D15
904169       c/z -10.3449  5.97280  1.914525         $ upper grid plate hole - D16 
904179       c/z -7.67870  9.15040  1.914525         $ upper grid plate hole - D17 
904189       c/z -4.08530  11.2253  1.914525         $ upper grid plate hole - D18 
c
905019       c/z  0.0000000  15.915600 1.914525      $ upper grid plate hole - E1
905029       c/z  4.1189000  15.372800 1.914525      $ upper grid plate hole - E2
905039       c/z  7.9578000  13.782800 1.914525      $ upper grid plate hole - E3
905049       c/z  11.254000  11.254000 1.914525      $ upper grid plate hole - E4 
905059       c/z  13.874200  7.9578000 1.914525      $ upper grid plate hole - E5 
905069       c/z  15.372800  4.1189000 1.914525      $ upper grid plate hole - E6 
905079       c/z  15.915600  0.0000000 1.914525      $ upper grid plate hole - E7 
905089       c/z  15.372800 -4.1189000 1.914525      $ upper grid plate hole - E8 
905099       c/z  13.874200 -7.9578000 1.914525      $ upper grid plate hole - E9 
905109       c/z  11.254000 -11.254000 1.914525      $ upper grid plate hole - E10 
905119       c/z  7.9578000 -13.782800 1.914525      $ upper grid plate hole - E11 
905129       c/z  4.1189000 -15.372800 1.914525      $ upper grid plate hole - E12 
905139       c/z  0.0000000 -15.915600 1.914525      $ upper grid plate hole - E13 
905149       c/z -4.1189000 -15.372800 1.914525      $ upper grid plate hole - E14 
905159       c/z -7.9578000 -13.782800 1.914525      $ upper grid plate hole - E15 
905169       c/z -11.254000 -11.254000 1.914525      $ upper grid plate hole - E16 
905179       c/z -13.874200 -7.9578000 1.914525      $ upper grid plate hole - E17
905189       c/z -15.372800 -4.1189000 1.914525      $ upper grid plate hole - E18
905199       c/z -15.915600  0.0000000 1.914525      $ upper grid plate hole - E19 
905209       c/z -15.372800  4.1189000 1.914525      $ upper grid plate hole - E20
905219       c/z -13.874200  7.9578000 1.914525      $ upper grid plate hole - E21
905229       c/z -11.254000  11.254000 1.914525      $ upper grid plate hole - E22 
905239       c/z -7.9578000  13.782800 1.914525      $ upper grid plate hole - E23
905249       c/z -4.1189000  15.372800 1.914525      $ upper grid plate hole - E24 
c
906019       c/z  0.0000000  19.888200 1.914525      $ upper grid plate hole - F1
906029       c/z  4.1348660  19.452590 1.914525      $ upper grid plate hole - F2 
906039       c/z  8.0886300  18.157860 1.914525      $ upper grid plate hole - F3 
906049       c/z  11.690350  16.089630 1.914525      $ upper grid plate hole - F4 
906059       c/z  14.778990  13.307314 1.914525      $ upper grid plate hole - F5
906069       c/z  17.223232  9.9441000 1.914525      $ upper grid plate hole - F6    
906079       c/z  18.915634  6.1455300 1.914525      $ upper grid plate hole - F7 
906089       c/z  19.777202  2.0706080 1.914525      $ upper grid plate hole - F8 
906099       c/z  19.777202 -2.0706080 1.914525      $ upper grid plate hole - F9 
906109       c/z  18.915634 -6.1455300 1.914525      $ upper grid plate hole - F10 
906119       c/z  17.223232 -9.9441000 1.914525      $ upper grid plate hole - F11 
906129       c/z  14.778990 -13.307314 1.914525      $ upper grid plate hole - F12
906139       c/z  11.690350 -16.089630 1.914525      $ upper grid plate hole - F13 
906149       c/z  8.0886300 -18.167858 1.914525      $ upper grid plate hole - F14 
906159       c/z  4.1348660 -19.452590 1.914525      $ upper grid plate hole - F15 
906169       c/z  0.0000000 -19.888200 1.914525      $ upper grid plate hole - F16 
906179       c/z -4.1348660 -19.452590 1.914525      $ upper grid plate hole - F17
906189       c/z -8.0886300 -18.167858 1.914525      $ upper grid plate hole - F18 
906199       c/z -11.690350 -16.089630 1.914525      $ upper grid plate hole - F19 
906209       c/z -14.778990 -13.307314 1.914525      $ upper grid plate hole - F20 
906219       c/z -17.223232 -9.9441000 1.914525      $ upper grid plate hole - F21 
906229       c/z -18.915634 -6.1455300 1.914525      $ upper grid plate hole - F22
906239       c/z -19.777202 -2.0706080 1.914525      $ upper grid plate hole - F23 
906249       c/z -19.777202  2.0706080 1.914525      $ upper grid plate hole - F24 
906259       c/z -18.915634  6.1455300 1.914525      $ upper grid plate hole - F25 
906269       c/z -17.223232  9.9441000 1.914525      $ upper grid plate hole - F26 
906279       c/z -14.778990  13.307314 1.914525      $ upper grid plate hole - F27 
906289       c/z -11.690350  16.089630 1.914525      $ upper grid plate hole - F28 
906299       c/z -8.0886300  18.167858 1.914525      $ upper grid plate hole - F29
906309       c/z -4.1348660  19.452590 1.914525      $ upper grid plate hole - F30 
c
c
c --- Flux wire insertion holes ---
c
111301  c/z  -5.265420  0.000000  0.400685  $ Flux wire insertion hole A 
111302  c/z  -10.46226  0.000000  0.400685  $ Flux wire insertion hole B
111303  c/z  -13.35786  0.000000  0.400685  $ Flux wire insertion hole C
111304  c/z  -18.39468  0.000000  0.400685  $ Flux wire insertion hole D
111305  c/z  -21.06930 -4.480560  0.400685  $ Flux wire insertion hole E
111306  c/z   4.206240 -4.445000  0.400685  $ Flux wire insertion hole F
111307  c/z   5.991860 -1.478280  0.400685  $ Flux wire insertion hole G
111308  c/z   9.372600 -3.068320  0.400685  $ Flux wire insertion hole H
111309  c/z   12.90828 -5.080000  0.400685  $ Flux wire insertion hole J
111310  c/z   16.36522 -7.048500  0.400685  $ Flux wire insertion hole K
111311  c/z   19.66976 -8.768080  0.400685  $ Flux wire insertion hole L
111312  c/z   5.265420  0.000000  0.400685  $ Flux wire insertion hole A1 
111313  c/z   10.46226  0.000000  0.400685  $ Flux wire insertion hole B1
111314  c/z   13.35786  0.000000  0.400685  $ Flux wire insertion hole C1
111315  c/z   18.39468  0.000000  0.400685  $ Flux wire insertion hole D1
111316  c/z   21.06930  4.480560  0.400685  $ Flux wire insertion hole E1
c
c
c ---------- Lower grid plate ----------
c
111398  cz   21.14550   $ lower grid plate radius
c
111397  cz   1.983740   $ Lower grid plate CT holes
c
112301  pz  -1.905000   $ Bottom of lower grid plate
10  pz   0.1   $ Top of lower grid plate
c
c
c  --- Disabled for 2016 TRTR model ---
c
c  111360  c/z  0.000000  2.997200  0.793750  $ Lower grid plate water hole A1
c  111361  c/z  2.595651  1.498600  0.793750  $ Lower grid plate water hole A2
c  111362  c/z  2.595651 -1.498600  0.793750  $ Lower grid plate water hole A3
c  111363  c/z  0.000000 -2.997200  0.793750  $ Lower grid plate water hole A4
c  111364  c/z -2.595651 -1.498600  0.793750  $ Lower grid plate water hole A5
c  111365  c/z -2.595651  1.498600  0.793750  $ Lower grid plate water hole A6
c  c
c  111366  c/z  0.000000  6.019800  0.793750  $ Lower grid plate water hole B1
c  111367  c/z  3.538350  4.870121  0.793750  $ Lower grid plate water hole B2
c  111368  c/z  5.725170  1.860220  0.793750  $ Lower grid plate water hole B3
c  111369  c/z  5.725170 -1.860220  0.793750  $ Lower grid plate water hole B4
c  111370  c/z  3.538350 -4.870121  0.793750  $ Lower grid plate water hole B5
c  111371  c/z  0.000000 -6.019800  0.793750  $ Lower grid plate water hole B6
c  111372  c/z -3.538350 -4.870121  0.793750  $ Lower grid plate water hole B7
c  111373  c/z -5.725170 -1.860220  0.793750  $ Lower grid plate water hole B8
c  111374  c/z -5.725170  1.860220  0.793750  $ Lower grid plate water hole B9
c  111375  c/z -3.538350  4.870121  0.793750  $ Lower grid plate water hole B10
c  c
c  111376  c/z  0.000000  8.890000  0.793750  $ Lower grid plate water hole C1
c  111377  c/z  3.615944  8.121396  0.793750  $ Lower grid plate water hole C2
c  111378  c/z  6.606540  5.948680  0.793750  $ Lower grid plate water hole C3
c  111379  c/z  8.454898  2.747264  0.793750  $ Lower grid plate water hole C4
c  111380  c/z  8.841232 -0.929132  0.793750  $ Lower grid plate water hole C5
c  111381  c/z  7.698994 -4.445000  0.793750  $ Lower grid plate water hole C6
c  111382  c/z  5.225288 -7.192264  0.793750  $ Lower grid plate water hole C7
c  111383  c/z  1.848358 -8.695690  0.793750  $ Lower grid plate water hole C8
c  111384  c/z -1.848358 -8.695690  0.793750  $ Lower grid plate water hole C9
c  111385  c/z -5.225288 -7.192264  0.793750  $ Lower grid plate water hole C10
c  111386  c/z -7.698994 -4.445000  0.793750  $ Lower grid plate water hole C11
c  111387  c/z -8.841232 -0.929132  0.793750  $ Lower grid plate water hole C12
c  111388  c/z -8.454898  2.747264  0.793750  $ Lower grid plate water hole C13
c  111389  c/z -6.606540  5.948680  0.793750  $ Lower grid plate water hole C14
c  111390  c/z -3.615944  8.121396  0.793750  $ Lower grid plate water hole C15
c
c
c
c ------------------------------
c ----- Graphite reflector -----
c ------------------------------
c
121301  cz  22.0980  $ Reflector assembly inner radius
121302  cz  22.7330  $ Graphite blank inner radius
c
121303  cz  29.5656  $ inner radius of graphite blank annulus in LS region
121304  cz  30.2006  $ inner radius of LS channel in reflector assembly
c
121305  cz  36.6395  $ outer radius of LS channel in reflector assembly
121306  cz  37.2745  $ outer radius of graphite blank annulus in LS region   
c
121307  cz  53.3400  $ Graphite blank outer radius
121308  cz  54.6100  $ Reflector assembly outer radius
c
c
c
122301  pz   7.6200  $ Bottom of reflector assembly
122302  pz   8.8900  $ Bottom of graphite blank
c
122303  pz  35.7886  $ top of graphite blank in LS channel region
122304  pz  36.4236  $ bottom of reflector assembly LS channel
c
122305  pz  62.2300  $ Top of graphite blank
122306  pz  63.5000  $ Top of reflector assembly
c
c
c
c ------------------------------
c ---- Rotary specimen rack ----
c ------------------------------
c
c -- pz surfaces --
c
122307  pz  37.05860  $ Bottom of inner LS container
122308  pz  64.77001  $ Top of reflector container lip annulus
122309  pz  72.54875  $ Top of inside of reflector container
122310  pz  73.18375  $ Top of reflector container
c
122311  pz  38.64610  $ Bottom of specimen holder
122312  pz  38.80485  $ Bottom of inner specimen holder
c
122313  pz  65.72250  $ Bottom of sepcimen ring
122314  pz  66.83375  $ Top of sample tube
122315  pz  67.62750  $ Top of specimen ring
c
c 122316  pz  67.46875  $ top of beveling
c 
c
c -- cz surfaces --
c
121390  cz  26.70810  $ Ouside of LS lip
121391  cz  27.34310  $ Inside of LS lip
c
121392  cz  36.00450  $ Outer wall of inside of rotary rack enclosure
121393  cz  30.83560  $ Inner wall of inside of rotary rack enclosure
c
121394  cz  30.63875  $ Outer radius of sample tube annulus
121395  cz  35.08375  $ Inner radius of sample tube annulus
c
c
c
c
c -- specimen container c/z surfaces --    malcolm, reminder, renumber rhis
c
121310  c/z  0.0000000  33.020000  1.58750  $ Pos. 1 inner radius 
121311  c/z  0.0000000  33.020000  1.74625  $ Pos. 1 outer radius
c
121312  c/z  10.203688  31.403798  1.58750  $ Pos. 3 inner radius 
121313  c/z  10.203688  31.403798  1.74625  $ Pos. 3 outer radius
c
121314  c/z  19.408648  26.713688  1.58750  $ Pos. 5 inner radius 
121315  c/z  19.408648  26.713688  1.74625  $ Pos. 5 outer radius
c
121316  c/z  26.713688  19.408648  1.58750  $ Pos. 7 inner radius 
121317  c/z  26.713688  19.408648  1.74625  $ Pos. 7 outer radius
c
121318  c/z  31.403798  10.203688  1.58750  $ Pos. 9 inner radius 
121319  c/z  31.403798  10.203688  1.74625  $ Pos. 9 outer radius
c
121320  c/z  33.020000  00.000000  1.58750  $ Pos. 11 inner radius 
121321  c/z  33.020000  00.000000  1.74625  $ Pos. 11 outer radius
c
121322  c/z  31.403798 -10.203688  1.58750  $ Pos. 13 inner radius 
121323  c/z  31.403798 -10.203688  1.74625  $ Pos. 13 outer radius
c
121324  c/z  26.713688 -19.408648  1.51750  $ Pos. 15 inner radius 
121325  c/z  26.713688 -19.408648  1.74620  $ Pos. 15 outer radius
c
121326  c/z  19.408648 -26.713688  1.51750  $ Pos. 17 inner radius 
121327  c/z  19.408648 -26.713688  1.74620  $ Pos. 17 outer radius
c
121328  c/z  10.203688 -31.403798  1.51750  $ Pos. 19 inner radius 
121329  c/z  10.203688 -31.403798  1.74620  $ Pos. 19 outer radius
c
121330  c/z  0.0000000 -33.020000  1.51750  $ Pos. 21 inner radius 
121331  c/z  0.0000000 -33.020000  1.74620  $ Pos. 21 outer radius
c
121332  c/z -10.203688 -31.403798  1.51750  $ Pos. 23 inner radius 
121333  c/z -10.203688 -31.403798  1.74620  $ Pos. 23 outer radius
c
121334  c/z -19.408648 -26.713688  1.51750  $ Pos. 25 inner radius 
121335  c/z -19.408648 -26.713688  1.74620  $ Pos. 25 outer radius
c
121336  c/z -26.713688 -19.408648  1.51750  $ Pos. 27 inner radius 
121337  c/z -26.713688 -19.408648  1.74620  $ Pos. 27 outer radius
c
121338  c/z -31.403798 -10.203688  1.51750  $ Pos. 29 inner radius 
121339  c/z -31.403798 -10.203688  1.74620  $ Pos. 29 outer radius
c
121340  c/z -33.020000  00.000000  1.51750  $ Pos. 31 inner radius 
121341  c/z -33.020000  00.000000  1.74620  $ Pos. 31 outer radius
c
121342  c/z -31.403798  10.203688  1.51750  $ Pos. 33 inner radius 
121343  c/z -31.403798  10.203688  1.74620  $ Pos. 33 outer radius
c
121344  c/z -26.713688  19.408648  1.51750  $ Pos. 35 inner radius 
121345  c/z -26.713688  19.408648  1.74620  $ Pos. 35 outer radius
c
121346  c/z -19.408648  26.713688  1.51750  $ Pos. 37 inner radius 
121347  c/z -19.408648  26.713688  1.74620  $ Pos. 37 outer radius
c
121348  c/z -10.203688  31.403798  1.51750  $ Pos. 39 inner radius 
121349  c/z -10.203688  31.403798  1.74620  $ Pos. 39 outer radius
c
c
c
121350  c/z   05.1655   32.6135  1.58750  $ Pos. 2 inner radius 
121351  c/z   05.1655   32.6135  1.74625  $ Pos. 2 outer radius
c
121352  c/z   14.9908   29.4210  1.58750  $ Pos. 4 inner radius 
121353  c/z   14.9908   29.4210  1.74625  $ Pos. 4 outer radius
c
121354  c/z   23.3487   23.3487  1.58750  $ Pos. 6 inner radius 
121355  c/z   23.3487   23.3487  1.74625  $ Pos. 6 outer radius
c
121356  c/z   29.4210   14.9908  1.58750  $ Pos. 8 inner radius 
121357  c/z   29.4210   14.9908  1.74625  $ Pos. 8 outer radius
c
121358  c/z   32.6135   05.1655  1.58750  $ Pos. 10 inner radius 
121359  c/z   32.6135   05.1655  1.74625  $ Pos. 10 outer radius
c
121360  c/z   32.6135  -05.1655  1.58750  $ Pos. 12 inner radius 
121361  c/z   32.6135  -05.1655  1.74625  $ Pos. 12 outer radius
c
121362  c/z   29.4210  -14.9908  1.58750  $ Pos. 14 inner radius 
121363  c/z   29.4210  -14.9908  1.74625  $ Pos. 14 outer radius
c
121364  c/z   23.3487  -23.3487  1.51750  $ Pos. 16 inner radius 
121365  c/z   23.3487  -23.3487  1.74620  $ Pos. 16 outer radius
c
121366  c/z   14.9908  -29.4210  1.51750  $ Pos. 18 inner radius 
121367  c/z   14.9908  -29.4210  1.74620  $ Pos. 18 outer radius
c
121368  c/z   05.1655  -32.6135  1.51750  $ Pos. 20 inner radius 
121369  c/z   05.1655  -32.6135  1.74620  $ Pos. 20 outer radius
c
121370  c/z  -05.1655  -32.6135  1.51750  $ Pos. 22 inner radius 
121371  c/z  -05.1655  -32.6135  1.74620  $ Pos. 22 outer radius
c
121372  c/z  -14.9908  -29.4210  1.51750  $ Pos. 24 inner radius 
121373  c/z  -14.9908  -29.4210  1.74620  $ Pos. 24 outer radius
c
121374  c/z  -23.3487  -23.3487  1.51750  $ Pos. 26 inner radius 
121375  c/z  -23.3487  -23.3487  1.74620  $ Pos. 26 outer radius
c
121376  c/z  -29.4210  -14.9908  1.51750  $ Pos. 28 inner radius 
121377  c/z  -29.4210  -14.9908  1.74620  $ Pos. 28 outer radius
c
121378  c/z  -32.6135  -5.16550  1.51750  $ Pos. 30 inner radius 
121379  c/z  -32.6135  -5.16550  1.74620  $ Pos. 30 outer radius
c
121380  c/z  -32.6135   05.1655  1.51750  $ Pos. 32 inner radius 
121381  c/z  -32.6135   05.1655  1.74620  $ Pos. 32 outer radius
c
121382  c/z  -29.4210   14.9908  1.51750  $ Pos. 34 inner radius 
121383  c/z  -29.4210   14.9908  1.74620  $ Pos. 34 outer radius
c
121384  c/z  -23.3487   23.3487  1.51750  $ Pos. 36 inner radius 
121385  c/z  -23.3487   23.3487  1.74620  $ Pos. 36 outer radius
c
121386  c/z  -14.9908   29.4210  1.51750  $ Pos. 38 inner radius 
121387  c/z  -14.9908   29.4210  1.74620  $ Pos. 38 outer radius
c
121388  c/z  -05.1655   32.6135  1.51750  $ Pos. 40 inner radius 
121389  c/z  -05.1655   32.6135  1.74620  $ Pos. 40 outer radius
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c -- specimen container k/z surfaces --
c
123301  k/z   00.000000   33.020000   65.08750  1  $ Sample container top bevel Pos. 1
123302  k/z   10.203688   31.403798   65.08750  1  $ Sample container top bevel Pos. 3
123303  k/z   19.408648   26.713688   65.08750  1  $ Sample container top bevel Pos. 5
123304  k/z   26.713688   19.408648   65.08750  1  $ Sample container top bevel Pos. 7
123305  k/z   31.403798   10.203688   65.08750  1  $ Sample container top bevel Pos. 9
123306  k/z   33.020000   00.000000   65.08750  1  $ Sample container top bevel Pos. 11
123307  k/z   31.403798  -10.203688   65.08750  1  $ Sample container top bevel Pos. 13
123308  k/z   26.713688  -19.408648   65.08750  1  $ Sample container top bevel Pos. 15
123309  k/z   19.408648  -26.713688   65.08750  1  $ Sample container top bevel Pos. 17
123310  k/z   10.203688  -31.403798   65.08750  1  $ Sample container top bevel Pos. 19
123311  k/z   00.000000  -33.020000   65.08750  1  $ Sample container top bevel Pos. 21
123312  k/z  -10.203688  -31.403798   65.08750  1  $ Sample container top bevel Pos. 23
123313  k/z  -19.408648  -26.713688   65.08750  1  $ Sample container top bevel Pos. 25
123314  k/z  -26.713688  -19.408648   65.08750  1  $ Sample container top bevel Pos. 27
123315  k/z  -31.403798  -10.203688   65.08750  1  $ Sample container top bevel Pos. 29
123316  k/z  -33.020000   00.000000   65.08750  1  $ Sample container top bevel Pos. 31
123317  k/z  -31.403798   10.203688   65.08750  1  $ Sample container top bevel Pos. 33
123318  k/z  -26.713688   19.408648   65.08750  1  $ Sample container top bevel Pos. 35
123319  k/z  -19.408648   26.713688   65.08750  1  $ Sample container top bevel Pos. 37
123320  k/z  -10.203688   31.403798   65.08750  1  $ Sample container top bevel Pos. 39
c
123321  k/z   05.1655     32.6135     65.08750  1  $ Sample container top bevel Pos. 2
123322  k/z   14.9908     29.4210     65.08750  1  $ Sample container top bevel Pos. 4
123323  k/z   23.3487     23.3487     65.08750  1  $ Sample container top bevel Pos. 6
123324  k/z   29.4210     14.9908     65.08750  1  $ Sample container top bevel Pos. 8
123325  k/z   32.6135     05.1655     65.08750  1  $ Sample container top bevel Pos. 10
123326  k/z   32.6135    -05.1655     65.08750  1  $ Sample container top bevel Pos. 12
123327  k/z   29.4210    -14.9908     65.08750  1  $ Sample container top bevel Pos. 14
123328  k/z   23.3487    -23.3487     65.08750  1  $ Sample container top bevel Pos. 16
123329  k/z   14.9908    -29.4210     65.08750  1  $ Sample container top bevel Pos. 18
123330  k/z   05.1655    -32.6135     65.08750  1  $ Sample container top bevel Pos. 20
123331  k/z  -5.16550    -32.6135     65.08750  1  $ Sample container top bevel Pos. 22
123332  k/z  -14.9908    -29.4210     65.08750  1  $ Sample container top bevel Pos. 24
123333  k/z  -23.3487    -23.3487     65.08750  1  $ Sample container top bevel Pos. 26
123334  k/z  -29.4210    -14.9908     65.08750  1  $ Sample container top bevel Pos. 28
123335  k/z  -32.6135    -5.16550     65.08750  1  $ Sample container top bevel Pos. 30
123336  k/z  -32.6135     05.1655     65.08750  1  $ Sample container top bevel Pos. 32
123337  k/z  -29.4210     14.9908     65.08750  1  $ Sample container top bevel Pos. 34
123338  k/z  -23.3487     23.3487     65.08750  1  $ Sample container top bevel Pos. 36
123339  k/z  -14.9908     29.4210     65.08750  1  $ Sample container top bevel Pos. 38
123340  k/z  -5.16550     32.6135     65.08750  1  $ Sample container top bevel Pos. 40
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------- Rotary rack radial planes -------
c
122001  p    16.4591    01.2954  0  0  $ Annular rack plane 1
122002  p    16.0538    03.8542  0  0  $ Annular rack plane 2
122003  p    15.2533    06.3181  0  0  $ Annular rack plane 3
122004  p    14.0771    08.6265  0  0  $ Annular rack plane 4
122005  p    12.5543    10.7224  0  0  $ Annular rack plane 5
122006  p    10.7224    12.5543  0  0  $ Annular rack plane 6
122007  p    08.6265    14.0771  0  0  $ Annular rack plane 7
122008  p    06.3181    15.2533  0  0  $ Annular rack plane 8
122009  p    03.8542    16.0538  0  0  $ Annular rack plane 9
122010  p    01.2954    16.4591  0  0  $ Annular rack plane 10
122011  p   -01.2954    16.4591  0  0  $ Annular rack plane 11
122012  p   -03.8542    16.0538  0  0  $ Annular rack plane 12
122013  p   -06.3181    15.2533  0  0  $ Annular rack plane 13
122014  p   -08.6265    14.0771  0  0  $ Annular rack plane 14
122015  p   -10.7224    12.5543  0  0  $ Annular rack plane 15
122016  p   -12.5543    10.7224  0  0  $ Annular rack plane 16
122017  p   -14.0771    08.6265  0  0  $ Annular rack plane 17
122018  p   -15.2533    06.3181  0  0  $ Annular rack plane 18
122019  p   -16.0538    03.8542  0  0  $ Annular rack plane 19
122020  p   -16.4591    01.2954  0  0  $ Annular rack plane 20
c 122021  p   -16.4591   -1.29540  0  0  $ Annular rack plane 21
c 122022  p   -16.0538   -3.85420  0  0  $ Annular rack plane 22
c 122023  p   -15.2533   -6.31810  0  0  $ Annular rack plane 23
c 122024  p   -14.0771   -8.62650  0  0  $ Annular rack plane 24
c 122025  p   -12.5543   -10.7224  0  0  $ Annular rack plane 25
c 122026  p   -10.7224   -12.5543  0  0  $ Annular rack plane 26
c 122027  p   -08.6265   -14.0771  0  0  $ Annular rack plane 27
c 122028  p   -06.3181   -15.2533  0  0  $ Annular rack plane 28
c 122029  p   -03.8542   -16.0538  0  0  $ Annular rack plane 29
c 122030  p   -01.2954   -16.4591  0  0  $ Annular rack plane 30
c 122031  p    01.2954   -16.4591  0  0  $ Annular rack plane 31
c 122032  p    03.8542   -16.0538  0  0  $ Annular rack plane 32
c 122033  p    06.3181   -15.2533  0  0  $ Annular rack plane 33
c 122034  p    08.6265   -14.0771  0  0  $ Annular rack plane 34
c 122035  p    10.7224   -12.5543  0  0  $ Annular rack plane 35
c 122036  p    12.5543   -10.7224  0  0  $ Annular rack plane 36
c 122037  p    14.0771   -8.62650  0  0  $ Annular rack plane 37
c 122038  p    15.2533   -6.31810  0  0  $ Annular rack plane 38
c 122039  p    16.0538   -3.85420  0  0  $ Annular rack plane 39
c 122040  p    16.4591   -1.29540  0  0  $ Annular rack plane 40
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------------------------------
c --------- Core water ---------
c ------------------------------
c
c
c
c ---------- Core water cylinders ----------
c
c 131301  cz   1.51750   $ A ring outer diameter water 
131302  cz   6.01726   $ B ring outer diameter water
131303  cz   9.96315   $ C ring outer diameter water 
131304  cz  13.93063   $ D ring outer diameter water
131305  cz  17.94200   $ E ring outer diameter water
c
c 1.914525 radius holes
c
c CT has 1.927225
c
c
c
c ---------- Core water axial planes ----------
c
c 132301  pz  21.5900  $ core water axial plane 1
c 132302  pz  43.1800  $ core water axial plane 2
c
11  pz  76.2000  $ top plane of fuel assembly supercells 
c
c
c
c ---------- Core radial planes ----------
c
c
c 132001  p   1.000000  0.000000  0 0   $ angular grid plane  1  (000.0 degrees)  This one's proabably going to be a px surface
132002  p   0.994522 -0.104528  0 0   $ angular grid plane  2  (006.0 degrees)
132003  p   0.991445 -0.130526  0 0   $ angular grid plane  3  (007.5 degrees)
132004  p   0.984808 -0.173648  0 0   $ angular grid plane  4  (010.0 degrees)
132005  p   0.965926 -0.258819  0 0   $ angular grid plane  5  (015.0 degrees)
132006  p   0.951057 -0.309017  0 0   $ angular grid plane  6  (018.0 degrees)
132007  p   0.923880 -0.382683  0 0   $ angular grid plane  7  (022.5 degrees)
132008  p   0.866025 -0.500000  0 0   $ angular grid plane  8  (030.0 degrees)  --- problem ---
132009  p   0.793353 -0.608761  0 0   $ angular grid plane  9  (037.5 degrees)
132010  p   0.743145 -0.669131  0 0   $ angular grid plane 10  (042.0 degrees)
132011  p   0.707107 -0.707107  0 0   $ angular grid plane 11  (045.0 degrees)
132012  p   0.642788 -0.766044  0 0   $ angular grid plane 12  (050.0 degrees)
132013  p   0.608761 -0.793353  0 0   $ angular grid plane 13  (052.5 degrees)
132014  p   0.587785 -0.809017  0 0   $ angular grid plane 14  (052.5 degrees)
132015  p   0.406737 -0.913545  0 0   $ angular grid plane 15  (066.0 degrees)
132016  p   0.382683 -0.923880  0 0   $ angular grid plane 16  (067.5 degrees)
132017  p   0.342020 -0.939693  0 0   $ angular grid plane 17  (070.0 degrees)
132018  p   0.258819 -0.965926  0 0   $ angular grid plane 18  (075.0 degrees)
132019  p   0.207912 -0.978148  0 0   $ angular grid plane 19  (078.0 degrees)
132020  p   0.130526 -0.991445  0 0   $ angular grid plane 20  (082.5 degrees)
132021  p   0.000000 -1.000000  0 0   $ angular grid plane 21  (090.0 degrees)  This one's also probably going to be a px surface   --- problem ----
132022  p  -0.130526 -0.991445  0 0   $ angular grid plane 22  (097.5 degrees)
132023  p  -0.207912 -0.978148  0 0   $ angular grid plane 23  (102.0 degrees)
132024  p  -0.258819 -0.965926  0 0   $ angular grid plane 24  (105.0 degrees)
132025  p  -0.342020 -0.939693  0 0   $ angular grid plane 25  (110.0 degrees)
132026  p  -0.382683 -0.923880  0 0   $ angular grid plane 26  (112.5 degrees)
132027  p  -0.406737 -0.913545  0 0   $ angular grid plane 27  (114.0 degrees)
132028  p  -0.587785 -0.809017  0 0   $ angular grid plane 28  (126.0 degrees)
132029  p  -0.608761 -0.793353  0 0   $ angular grid plane 29  (127.5 degrees)
132030  p  -0.642788 -0.766044  0 0   $ angular grid plane 30  (130.0 degrees)
132031  p  -0.707107 -0.707107  0 0   $ angular grid plane 31  (135.0 degrees)
132032  p  -0.743145 -0.669131  0 0   $ angular grid plane 32  (138.0 degrees)
132033  p  -0.793353 -0.608761  0 0   $ angular grid plane 33  (142.5 degrees)
132034  p  -0.866025 -0.500000  0 0   $ angular grid plane 34  (150.0 degrees)
132035  p  -0.923880 -0.382683  0 0   $ angular grid plane 35  (157.5 degrees)
132036  p  -0.951057 -0.309017  0 0   $    grid plane 36  (162.0 degrees)
132037  p  -0.965926 -0.258819  0 0   $ angular grid plane 37  (165.0 degrees)
132038  p  -0.984808 -0.173648  0 0   $ angular grid plane 38  (170.0 degrees)
132039  p  -0.991445 -0.130526  0 0   $ angular grid plane 39  (172.5 degrees)
132040  p  -0.994522 -0.104528  0 0   $ angular grid plane 40  (174.0 degrees)
c
c
c
c
c
c ------------------------------
c ------ Central Thimble -------
c ------------------------------
c
141300  cz  1.69418   $ Central thimble inner diameter
c
142301  pz -20.9550   $ Bottom of central thimble bottom cap
142302  pz -19.0500   $ Top of central thimble bottom cap
c
142303  pz  52.7050   $ Central thimble evacuable waterline
c
c
c
c
c
c
c
c
c ------------------------------
c ------ Installed sources -----
c ------------------------------
c
c
c
c ---- p/z surfaces ----
c
172302     pz  0.285         $ bottom of source holder
172303     pz  40.245        $ bottom of lower cavity cone
172304     pz  40.745        $ bottom of main cavity cylinder
172305     pz  48.445        $ top of main cavity cylinder
172306     pz  48.695        $ top of half-cone directly above cavity cylinder
172308     pz  49.395        $ top of cylinder on cavity cap
172309     pz  49.595        $ top of upper cavity cone
172311     pz  66.675        $ top of top grid plate
172312     pz  66.975        $ top of upper source body cap
172313     pz  73.575        $ top of lower cylindrical component of source knob
172314     pz  74.075        $ midsection of corset componenet on source knob
172315     pz  74.575        $ top of corset bit/bottom of upper cylindrical component on source knob
172316     pz  75.075        $ top of upper cylindrical component on source knob
172317     pz  75.825        $ top of source knob 
c 
c
c
c ---- AmBe c/z and k/z surfaces ----
c
171301       cz  1.9                 $ cylinder body of source holder
171302       cz  1.25                $ main cylinder part of source cavity
171303       cz  0.3                 $ top cap cylinder part of source cavity
171305       cz  0.75                $ cylinder component on knob
171306       cz  1.920000            $ upper grid plate hole size
c
173301       kz  40.245  4.0804      $ cone on bottom of cavity
173302       kz  48.945  1.44        $ imaginary cone on top of cavity
173303       kz  49.595  2.25        $ cone on tip of cavity cap
173304       kz  76.575  0.0625      $ bottom cone half of corset
173305       kz  71.575  0.0625      $ top cone half of corset
173306       kz  75.825  1           $ cone on end of knob
c
c
c
c
c ---- IR-192 c/z and k/z surfaces ----
c
171310       cz  1.9                 $ cylinder body of source holder
171311       cz  1.25                $ main cylinder part of source cavity
171312       cz  0.3                 $ top cap cylinder part of source cavity
171313       cz  2                   $ lip of source that rests on grid plate
171314       cz  0.75                $ cylinder component on knob
171315       cz  1.920000
c
173310       kz  40.245  4.0804      $ cone on bottom of cavity
173311       kz  48.945  1.44        $ imaginary cone on top of cavity
173312       kz  49.595  2.25        $ cone on tip of cavity cap
173313       kz  76.575  0.0625      $ bottom cone half of corset
173314       kz  71.575  0.0625      $ top cone half of corset
173315       kz  75.825  1           $ cone on end of knob
c
c
c
c
c
c
c
c ------------------------------
c ----------- Rabbit -----------
c ------------------------------
c
c
c ---- pz surfaces ----
c
502301  pz   1.2700  $ Top of lower section lower taper
502302  pz   8.2550  $ Bottom of lower section upper taper
502303  pz   8.8900  $ Top of lower section upper taper  -- 
502304  pz   9.5250  $ Top of mid section lower taper
502305  pz  25.4000  $ Bottom of mid section upper taper
502306  pz  26.3525  $ Top of mid section upper taper
c
502307  pz  26.6700  $ Bottom of main section
502308  pz  28.5750  $ Lower divit main section
502309  pz  29.2100  $ Main section divit bezel
c
502310  pz  69.5325  $ Top of thinner outer tube section
c
502311  pz  30.4800  $ Bottom of sample holder
502312  pz  31.7500  $ Top of sample holder
c
502313  pz  39.6725  $ Sketchy bottom of upper bevel
c
c
c
c
c ----- Rabbit terminus -----
c
c --- c/z surfaces ---
c
501301  c/z  19.777202 -2.0706080  0.95250  $ Main section lower post outer radius
501302  c/z  19.777202 -2.0706080  1.31191  $ Shock absorber inner radius
501303  c/z  19.777202 -2.0706080  1.47066  $ Shock absorber outer radius
501304  c/z  19.777202 -2.0706080  1.48590  $ Divit outer radius 
501305  c/z  19.777202 -2.0706080  1.72720  $ Main section tube inner radius
501306  c/z  19.777202 -2.0706080  1.88595  $ Lower, mid, and main sections outer radii
501307  c/z  19.777202 -2.0706080  2.04470  $ Thick section outer radius
c
501308  c/z  19.777202 -2.0706080  0.79375  $ Sample holder inner radius
c
c
c --- k/z surfaces ---
c
503301  k/z  19.777202 -2.0706080  -0.61595  1  $ Lower taper
503302  k/z  19.777202 -2.0706080  10.14095  1  $ Taper b/w lower and mid section lower cone
503303  k/z  19.777202 -2.0706080   7.63905  1  $ Taper b/w lower and mid section upper cone
503304  k/z  19.777202 -2.0706080  27.28595  1  $ Upper taper mid section
c
c
c
c
c
c
c
c
c
c
c
c ----- Sample vials ----- 
c
c --- c/z surfaces ---
c
501311   c/z   19.777202 -2.0706080   0.50800       $ inner radius of inner irradiation vial
501312   c/z   19.777202 -2.0706080   0.61341       $ outer radius of inner irradiation vial
c
501313   c/z   19.777202 -2.0706080   0.72390       $ inner radius of outer irradiation vial
c
501317   c/z   19.777202 -2.0706080   1.11125       $ outer radius of rabbit vial top
501318   c/z   19.777202 -2.0706080   1.19063       $ outer radius of rabbit vial cap
c
c
c --- k/z surfaces ---
c
553301   k/z   19.777202 -2.0706080  26.6700  0.03515625  $ -2.2225 - 6.35 lower rabbit vial bevel lower portion
553302   k/z   19.777202 -2.0706080  39.3700  0.03515625  $ -2.2225 + 6.35 lower rabbit vial bevel upper portion
553303   k/z   19.777202 -2.0706080  34.9250  0.04000000  $ upper rabbit vial bevel
c
c
c --- pz surfaces ----
c
552302   pz   31.90875              $ -3.4925 + 0.15875 -- bottom of inside of rabbit vial
c
552303   pz   32.16910              $ -3.4925 + 0.15875 + 0.26035           -- bottom of inside of outer irradiation vial
552304   pz   33.02000              $ 1.27 -3.4925                          -- center of lower bevel of rabbit vial    %%%%%%%
552305   pz   32.33547              $ -3.4925 + 0.15875 + 0.26035 + 0.16637 -- bottom of inside of inner irradiation vial
c
552306   pz   34.29000              $ 2.54 + -3.4925  -- top of lower bevel of rabbit vial
c
552307   pz   34.54527              $ + 2.2098 -- top of inside of inner irradiation vial
552308   pz   34.70402              $ + 0.15875 -- top of outside of inner irradiation vial
552309   pz   37.47770              $ -3.07340 + 5.3086 top of inside of outer irradiation vial
c
552310   pz   37.63645              $ -3.33375 + 5.7277  -- top of outside of outer irradiation vial
c
552311   pz   40.32250              $ -3.4925 + 8.57250 -- top of lower portion of rabbit vial
552312   pz   41.11625              $ 5.08000 + 0.79375 -- top of upper bevel of rabbit vial
552313   pz   41.27500              $ 5.87375 + 0.15875 -- top of upper portion of rabbit vial
552314   pz   41.90975              $ 4.14375 - 0.47625 -- top of inner rabbit vial
552315   pz   42.38625              $ 6.0325  + 1.11125 -- top of cap of rabbit vial
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------------------------------
c --------- Control Rods -------
c ------------------------------
c
c
c --- control rod guide tubes ---
c
c -- general --
c
c
902301  pz  2.22250   $ top plane of rod guide tube grid plate adapter
c
c 902302  pz  4.44500   $ bottom plane of (1/4)" to (1/16)" taper
902303  pz  5.23875   $ middle of taper
c 902304  pz  6.03250   $ top plane of (1/4)" to (1/16)" taper
c
902399  pz  92.7100   $ top of control rod guide tubes
c
c
c
c
c
c -- safe rod --
c
903058   c/z   6.91134  -3.99034  1.90500   $ rod guide tube outer diameter
903057   c/z   6.91134  -3.99034  1.74625   $ rod guide tube inner diameter
c
c
c
c -- shim rod --
c
903098   c/z  -6.91134  -3.99034  1.90500   $ rod guide tube outer diameter
903097   c/z  -6.91134  -3.99034  1.74625   $ rod guide tube inner diameter
c
c
c
c -- reg rod --
c
905018   c/z   0.00000  15.91560  1.90500   $ rod guide tube outer diameter
905017   c/z   0.00000  15.91560  1.74625   $ rod guide tube inner diameter
c
c
c
c
c
c
c
c -------------------
c ---- COPY HERE ----
c
c ROD HEIGHTS
c Control rods have a travel of 38 cm
c The "bottom of control rod" has z-position 13.7425 at 0% and 51.7425 at 100%
c Rod moves 0.38 cm for every 1%
c
c Safe Rod (0% withdrawn)
c
c
c c/z surfaces
c
811301   c/z   6.91134   -3.99034   0.508   $ Upper connecting rod cylinder
811302   c/z   6.91134   -3.99034   1.2573   $ Lower conic section cylinder
811303   c/z   6.91134   -3.99034   1.52112  $ Poison section cylinder
811305   c/z   6.91134   -3.99034   1.5300   $ Poison burnup section cylinder (graphite)
811304   c/z   6.91134   -3.99034   1.5875   $ Outer diameter
c
c
c pz surfaces
c
812301   pz   97.0153   $ top of control rod
812302   pz   96.2533   $ top of main section
812303   pz   95.6183   $ top of poison portion
812304   pz   49.6327   $ bottom of poison portion
812305   pz   48.907700000000006   $ bottom of main section
812306   pz   48.5013   $ bottom of outer lower cone
812307   pz   47.9425   $ bottom of control rod
c
c
c k/z surfaces
c
813301   k/z   6.91134   -3.99034   103.71676   0.1877777777   $ upper beveling
813302   k/z   6.91134   -3.99034   50.75385   0.66015625   $ lower outer beveling
813303   k/z   6.91134   -3.99034   51.7425   5.0625   $ lower inner beveling
c
c End of Safe Rod
c
c
c
c
c
c Shim Rod (0% withdrawn)
c
c
c c/z surfaces
c
821301   c/z   -6.91134   -3.99034   0.508    $ Upper connecting rod cylinder
821302   c/z   -6.91134   -3.99034   1.2573   $ Lower conic section cylinder
821303   c/z   -6.91134   -3.99034   1.52112  $ Poison section cylinder
821305   c/z   -6.91134   -3.99034   1.5300   $ Poison burnup section cylinder (grahpite)
821304   c/z   -6.91134   -3.99034   1.5875   $ Outer diameter
c
c
c pz surfaces
c
822301   pz   100.81530000000001   $ top of control rod
822302   pz   100.05330000000001   $ top of main section
822303   pz   99.4183   $ top of poison portion
822304   pz   53.4327   $ bottom of poison portion
822305   pz   52.7077   $ bottom of main section
822306   pz   52.3013   $ bottom of outer lower cone
822307   pz   51.7425   $ bottom of control rod
c
c
c k/z surfaces
c
823301   k/z   -6.91134   -3.99034   103.71676   0.1877777777   $ upper beveling
823302   k/z   -6.91134   -3.99034   50.75385   0.66015625   $ lower outer beveling
823303   k/z   -6.91134   -3.99034   51.7425   5.0625   $ lower inner beveling
c
c End of Shim Rod
c
c
c
c
c
c Reg Rod (0% withdrawn)
c
c
c c/z surfaces
c
831301   c/z   0   15.9156   0.508   $ Upper connecting rod cylinder
831302   c/z   0   15.9156   1.2573   $ Lower conic section cylinder
831303   c/z   0   15.9156   1.52112  $ Poison section cylinder
831305   c/z   0   15.9156   1.5300   $ Poison burnup section cylinder (graphite)
831304   c/z   0   15.9156   1.5875   $ Outer diameter
c
c
c pz surfaces
c
832301   pz   100.81530000000001   $ top of control rod
832302   pz   100.05330000000001   $ top of main section
832303   pz   99.4183   $ top of poison portion
832304   pz   53.4327   $ bottom of poison portion
832305   pz   52.7077   $ bottom of main section
832306   pz   52.3013   $ bottom of outer lower cone
832307   pz   51.7425   $ bottom of control rod
c
c
c k/z surfaces
c
833301   k/z   0   15.9156   103.71676   0.1877777777   $ upper beveling
833302   k/z   0   15.9156   50.75385   0.66015625   $ lower outer beveling
833303   k/z   0   15.9156   51.7425   5.0625   $ lower inner beveling
c
c End of Reg Rod
c
c
c
c
c ---- COPY HERE ----
c -------------------
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------------------------------
c -------- Fuel Surfaces ------- TODO 
c ------------------------------
c
c
c ------- Active section surfaces -------
c
c 302301  pz  17.89684 $ $ Fuel meat 1"
c 302302  pz  20.43684 $ $ Fuel meat 2"
302303  pz  22.97684   $ Fuel meat 3"
c 302304  pz  25.51684 $ $ Fuel meat 4"
c 302305  pz  28.05684 $ $ Fuel meat 5"
302306  pz  30.59684   $ Fuel meat 6"
c 302307  pz  33.13684 $ $ Fuel meat 7"
c 302308  pz  35.67684 $ $ Fuel meat 8"
302309  pz  38.21684   $ Fuel meat 9"
c 302310  pz  40.75684 $ $ Fuel meat 10"
c 302311  pz  43.29684 $ $ Fuel meat 11"
302312  pz  45.83684   $ Fuel meat 12"
c 302313  pz  48.37684 $ $ Fuel meat 13"
c 302314  pz  50.91684 $ $ Fuel meat 14"
c
c
c SS-clad Fuel Element 
c specs from Reed Neutronics Report 2010
c 
311301  cz  0.285750  $ Zirc pin outer radius (0.225" DIA)
311302  cz  0.793750  $ Top and bottom fitting outer radii (0.625" DIA)
311303  cz  1.587500  $ Tri-flute effective outer radius (1.250" DIA)
311304  cz  1.822450  $ Fuel active section outer radius (36.449 mm OD)
311305  cz  1.873250  $ Cladding outer radius (1.475" DIA)
311306  cz  1.920000  $ Water around FE (fits gap between cladding OD and core position diameter)
c
312300  pz  0         $ Bottom of lower grid plate (with rounding correction)
312301  pz  5.120640  $ Top of lower grid plate pin
312302  pz  6.390640  $ Top of bottom fitting casing
312303  pz  15.35684  $ Bottom of active section 
312304  pz  53.45684  $ Top of active section (active length = 381 mm = 15 in)
312305  pz  62.42304  $ Top of upper graphite spacer
312306  pz  63.69304  $ Top of SS top cap 
312307  pz  66.55054  $ Top of tri-flute  
312308  pz  70.36054  $ Top of fuel 
312309  pz  76.40000  $ top plane of fuel assembly supercells
c
c
c
c Al-clad FE element (done) (originals from 2016 to 02/14/2021)
c
c 311301  cz  0.285750  tmp=2.533494e-08 $ Zirc pin outer radius (0.225" DIA)
c 311302  cz  0.793750  $ Top and bottom fitting outer radii (0.625" DIA)
c 311303  cz  1.587500  $ Tri-flute effective outer radius (1.250" DIA)
c 311304  cz  1.797050  $ Fuel active section outer radius (1.415" DIA)
c 311305  cz  1.873250  $ Cladding outer radius (1.475" DIA)
c 311306  cz  1.92  $
c c
c 312300  pz  0         $ Bottom of lower grid plate (with rounding correction)
c 312301  pz  5.120640  $ Top of lower grid plate pin
c 312302  pz  6.390640  $ Top of bottom fitting casing
c 312303  pz  15.35684  $ Bottom of active section
c 312304  pz  53.45684  $ Top of active section 
c 312305  pz  62.42304  $ Top of upper graphite spacer
c 312306  pz  63.69304  $ Top of SS top cap 
c 312307  pz  66.55054  $ Top of tri-flute  
c 312308  pz  70.36054  $ Top of fuel 
c 312309  pz  76.40000  $ top plane of fuel assembly supercells
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c -----------------------------------------------------------------------------
c -----------------------------------------------------------------------------

c -----------------------------------------------------------------------------
c -------------------------- DATA CARDS ---------------------------------------
c -----------------------------------------------------------------------------
c --Begin Options-- $ for NIST MCNP syntax
c
c
c
c
c ------------------------------
c ---------- Tallies -----------
c ------------------------------
c
c
c -----------------------------------------------------------------------------
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c 
c ------------------------------
c ----- General materials ------
c ------------------------------
c 
c ------- Air -------
c 
c   Air inside rabbit, LS, or CT if beam IR    
c   Assumed to be 75.2290% Nitrogen, 23.1781% Oxygen, 0.0124% Carbon, and 1.2827% Argon (mass percentage) by NIST standard
c
c
m101   6000.80c -0.000124   7014.00c -0.752290   7015.00c  -0.002977
                            8016.00c -0.231153   8017.00c  -0.000094
                                                 18000.59c -0.012827
c
c
c
c
c
c ------- Water -------
c
c   Water inside and outside the core, under the control rods, and inside the CT
c   Assumed to be (1/3) Oxygen and (2/3) Hydrogen
c
c
m102   1001.06c 0.037159    1001.00c 1.962841 
       8016.00c 1.0000
c
mt102  h-h2o.40t
c
c
c
c ------- 6061-T6 Aluminum ------
c
c   6061-T6 Aluminum alloy used in the core structure (Grid plates, reflector cladding, etc.)
c   Assumed to be 
c   Thanks to Rob Schickler of OSU for providing this m card
c
c
m103    5010.00c  2.3945E-7    12024.00c  5.3511E-4    12025.00c  6.5030E-5 
       12026.00c  6.8851E-5    13027.00c  5.9015E-2    14028.00c  3.2153E-4
       14029.00c  1.5771E-5    14030.00c  1.0062E-5    24050.00c  2.6872E-6
       24052.00c  4.9830E-5    24053.00c  5.5435E-6    24054.00c  1.3544E-6
       29063.00c  5.0017E-5    29065.00c  2.1628E-5
c
mt103  al-27.40t    $ 294 K
c
c
c
c ------- 1100F Aluminum -------
c
c   1100F Aluminum used in the cladding of graphite elements or old aluminum fuel elements
c   Assumed to be 99.6% aluminum, 0.95% iron, 0.95% silicon, 0.125% copper, 0.05% manganese
c
c
m104   13027.00c 0.996   26054.00c 0.0056  26056.00c 0.0871   
       14028.00c 0.0871  14029.00c 0.004   14030.00c 0.003  
       29063.00c 0.0086  29065.00c 0.0039  25055.00c 0.0005  
c
mt104   al-27.40t    fe-56.40t  $ 294 K
c
c
c
c ------- Type 304 Stainless steel -------
c
c   Type 304 Stainless steel used as fuel element cladding
c   Density 7..85 g/cc per OSU Neutronics of RRR Report 2010   
c   Thanks to Rob Schickler of OSU for providing this m card
c
c
m105   6000.80c 0.00031519 24050.00c 7.8200E-4 24052.00c 1.4501E-2 
       24053.00c 1.6130E-3 24054.00c 3.9400E-4 26054.00c 3.5540E-3
       26056.00c 5.5110E-2 26057.00c 1.2570E-3 26058.00c 1.6600E-4
       28058.00c 5.5580E-3 28060.00c 2.0700E-3 28061.00c 8.8500E-5
       28062.00c 2.7800E-4 28064.00c 6.8500E-5 
c
c
c
c ------- Graphite -------
c
c   Graphite used as the material for the reflector blank as well as the fuel element upper and lower spacers
c   Assumed to be pure elemental carbon
c
c
m106   6012.00c  0.9893    6013.00c  0.0107
c
mt106   grph.40t  $ 296 K
c
c
c
c
c ------- 25% mass b4c and Grapite 5% depleted -------
c
c   Density 1..80772 - chemically solid density is 2..52 but this is powdered
c
m107   5010.00c 0.1592  5011.00c 0.6408 
       6012.00c 0.1977  6013.00c 0.0021		    $ b4c   
c
mt107   grph.40t  $ 296 K
c
c
c   Old ENDF7 card
c
c m107   5010.80c 0.1592 5011.80c 0.6408 
c        6000.80c 0.2 							$ b4c                    
c
c
c   From RRR Neutronics Analysis 2010
c   Original card - Density 1..72066
c
c m107   5010.80c  0.0035454  5011.80c  0.01427   
c        6000.80c  0.0693901                     $ 25% mass b4c and Grapite 5% depleted   
c
c
c
c ------- Zirconium -------
c
c
c
c
c
m108   40090.00c 0.5219 40091.00c 0.1125 40092.00c 0.1702 
       40094.00c 0.1688 40096.00c 0.0266
c
c no mt lib for zr
c
c
c c ------- Prime polyethylene -------
c c
c c
c c
c c
c c
c m109    1001.00c  0.666590  1002.00c  0.000077  6000.80c 0.333333
c mt109   poly.10t
c c
c
c
c
c
c
c
c
c
c ------------------------------
c ------- Fuel materials -------
c ------------------------------
c
c
c --Begin Fuel Materials--                               
c                 
c
c materials auto-generated from './Source/Fuel/Core Burnup History 20201117.xlsx'
c
m7202    92235.00c 9.324675e+22 $ u-235 36.395024 g
         92238.00c 3.898773e+23 $ u-238 154.119236 g
         94239.00c 2.252371e+20 $ pu-239 0.089411 g
         62149.00c 1.355331e+19 $ sm-149 0.003352 g
         40000.66c 1.331289e+25 $ zr 2016.697323 g
          1001.00c 2.096780e+25 $ h 35.095129 g
mt7202 h-zrh.40t zr-zrh.40t
c 
c 
c
m7945    92235.00c 9.368295e+22 $ u-235 36.565275 g
         92238.00c 3.847851e+23 $ u-238 152.106266 g
         94239.00c 2.021554e+20 $ pu-239 0.080249 g
         62149.00c 1.361671e+19 $ sm-149 0.003367 g
         40000.66c 1.318354e+25 $ zr 1997.103346 g
          1001.00c 2.076408e+25 $ h 34.754150 g
mt7945 h-zrh.40t zr-zrh.40t
c 
c 
c
m7946    92235.00c 9.346126e+22 $ u-235 36.478748 g
         92238.00c 3.822720e+23 $ u-238 151.112849 g
         94239.00c 2.139078e+20 $ pu-239 0.084914 g
         62149.00c 1.358449e+19 $ sm-149 0.003359 g
         40000.66c 1.310844e+25 $ zr 1985.726276 g
          1001.00c 2.064579e+25 $ h 34.556163 g
mt7946 h-zrh.40t zr-zrh.40t
c 
c 
c
m8102    92235.00c 9.793419e+22 $ u-235 38.224573 g
         92238.00c 3.833949e+23 $ u-238 151.556725 g
         94239.00c 1.110440e+20 $ pu-239 0.044081 g
         62149.00c 1.423462e+19 $ sm-149 0.003520 g
         40000.66c 1.325853e+25 $ zr 2008.462543 g
          1001.00c 2.088218e+25 $ h 34.951826 g
mt8102 h-zrh.40t zr-zrh.40t
c 
c 
c
m8103    92235.00c 9.793419e+22 $ u-235 38.224573 g
         92238.00c 3.833949e+23 $ u-238 151.556725 g
         94239.00c 1.110440e+20 $ pu-239 0.044081 g
         62149.00c 1.423462e+19 $ sm-149 0.003520 g
         40000.66c 1.325853e+25 $ zr 2008.462543 g
          1001.00c 2.088218e+25 $ h 34.951826 g
mt8103 h-zrh.40t zr-zrh.40t
c 
c 
c
m8104    92235.00c 9.775341e+22 $ u-235 38.154012 g
         92238.00c 3.834081e+23 $ u-238 151.561932 g
         94239.00c 1.210340e+20 $ pu-239 0.048046 g
         62149.00c 1.420834e+19 $ sm-149 0.003514 g
         40000.66c 1.325424e+25 $ zr 2007.813021 g
          1001.00c 2.087543e+25 $ h 34.940522 g
mt8104 h-zrh.40t zr-zrh.40t
c 
c 
c
m8105    92235.00c 9.794761e+22 $ u-235 38.229808 g
         92238.00c 3.833939e+23 $ u-238 151.556335 g
         94239.00c 1.103110e+20 $ pu-239 0.043790 g
         62149.00c 1.423657e+19 $ sm-149 0.003521 g
         40000.66c 1.325885e+25 $ zr 2008.510731 g
          1001.00c 2.088269e+25 $ h 34.952664 g
mt8105 h-zrh.40t zr-zrh.40t
c 
c 
c
m9678    92235.00c 9.301132e+22 $ u-235 36.303133 g
         92238.00c 3.810562e+23 $ u-238 150.632246 g
         94239.00c 1.585710e+20 $ pu-239 0.062947 g
         62149.00c 1.351909e+19 $ sm-149 0.003343 g
         40000.66c 1.306107e+25 $ zr 1978.550689 g
          1001.00c 2.057119e+25 $ h 34.431291 g
mt9678 h-zrh.40t zr-zrh.40t
c 
c 
c
m9679    92235.00c 9.308589e+22 $ u-235 36.332238 g
         92238.00c 3.813600e+23 $ u-238 150.752312 g
         94239.00c 1.586959e+20 $ pu-239 0.062997 g
         62149.00c 1.352993e+19 $ sm-149 0.003346 g
         40000.66c 1.307149e+25 $ zr 1980.129534 g
          1001.00c 2.058760e+25 $ h 34.458767 g
mt9679 h-zrh.40t zr-zrh.40t
c 
c 
c
m1070    92235.00c 9.532478e+22 $ u-235 37.206096 g
         92238.00c 3.871613e+23 $ u-238 153.045581 g
         94239.00c 5.145615e+19 $ pu-239 0.020426 g
         62149.00c 1.385535e+19 $ sm-149 0.003426 g
         40000.66c 1.328973e+25 $ zr 2013.189154 g
          1001.00c 2.093133e+25 $ h 35.034079 g
mt1070 h-zrh.40t zr-zrh.40t
c 
c 
c
m3671    92235.00c 8.242023e+22 $ u-235 32.169337 g
         92238.00c 3.913650e+23 $ u-238 154.707305 g
         94239.00c 1.579829e+21 $ pu-239 0.627136 g
         62149.00c 1.197968e+19 $ sm-149 0.002962 g
         40000.66c 1.309638e+25 $ zr 1983.898674 g
          1001.00c 2.062679e+25 $ h 34.524358 g
mt3671 h-zrh.40t zr-zrh.40t
c 
c 
c
m3673    92235.00c 8.697300e+22 $ u-235 33.946324 g
         92238.00c 3.911154e+23 $ u-238 154.608631 g
         94239.00c 1.159846e+21 $ pu-239 0.460418 g
         62149.00c 1.264142e+19 $ sm-149 0.003126 g
         40000.66c 1.320195e+25 $ zr 1999.892216 g
          1001.00c 2.079308e+25 $ h 34.802682 g
mt3673 h-zrh.40t zr-zrh.40t
c 
c 
c
m3674    92235.00c 8.643534e+22 $ u-235 33.736470 g
         92238.00c 3.911424e+23 $ u-238 154.619323 g
         94239.00c 1.220481e+21 $ pu-239 0.484488 g
         62149.00c 1.256328e+19 $ sm-149 0.003107 g
         40000.66c 1.318972e+25 $ zr 1998.039634 g
          1001.00c 2.077382e+25 $ h 34.770443 g
mt3674 h-zrh.40t zr-zrh.40t
c 
c 
c
m3676    92235.00c 8.673068e+22 $ u-235 33.851744 g
         92238.00c 3.911293e+23 $ u-238 154.614136 g
         94239.00c 1.182769e+21 $ pu-239 0.469518 g
         62149.00c 1.260620e+19 $ sm-149 0.003117 g
         40000.66c 1.319637e+25 $ zr 1999.046032 g
          1001.00c 2.078428e+25 $ h 34.787957 g
mt3676 h-zrh.40t zr-zrh.40t
c 
c 
c
m3677    92235.00c 8.217943e+22 $ u-235 32.075352 g
         92238.00c 3.913787e+23 $ u-238 154.712752 g
         94239.00c 1.599294e+21 $ pu-239 0.634863 g
         62149.00c 1.194469e+19 $ sm-149 0.002954 g
         40000.66c 1.309073e+25 $ zr 1983.043637 g
          1001.00c 2.061790e+25 $ h 34.509479 g
mt3677 h-zrh.40t zr-zrh.40t
c 
c 
c
m3679    92235.00c 8.209276e+22 $ u-235 32.041523 g
         92238.00c 3.913832e+23 $ u-238 154.714510 g
         94239.00c 1.607108e+21 $ pu-239 0.637965 g
         62149.00c 1.193209e+19 $ sm-149 0.002951 g
         40000.66c 1.308871e+25 $ zr 1982.737127 g
          1001.00c 2.061472e+25 $ h 34.504145 g
mt3679 h-zrh.40t zr-zrh.40t
c 
c 
c
m3682    92235.00c 8.431509e+22 $ u-235 32.908916 g
         92238.00c 3.912639e+23 $ u-238 154.667369 g
         94239.00c 1.408042e+21 $ pu-239 0.558943 g
         62149.00c 1.225510e+19 $ sm-149 0.003031 g
         40000.66c 1.314048e+25 $ zr 1990.579771 g
          1001.00c 2.069626e+25 $ h 34.640625 g
mt3682 h-zrh.40t zr-zrh.40t
c 
c 
c
m3683    92235.00c 8.711307e+22 $ u-235 34.000992 g
         92238.00c 3.911033e+23 $ u-238 154.603872 g
         94239.00c 1.157993e+21 $ pu-239 0.459682 g
         62149.00c 1.266178e+19 $ sm-149 0.003131 g
         40000.66c 1.320539e+25 $ zr 2000.412497 g
          1001.00c 2.079849e+25 $ h 34.811736 g
mt3683 h-zrh.40t zr-zrh.40t
c 
c 
c
m3685    92235.00c 8.419370e+22 $ u-235 32.861538 g
         92238.00c 3.912725e+23 $ u-238 154.670733 g
         94239.00c 1.415167e+21 $ pu-239 0.561771 g
         62149.00c 1.223746e+19 $ sm-149 0.003026 g
         40000.66c 1.313760e+25 $ zr 1990.144008 g
          1001.00c 2.069173e+25 $ h 34.633041 g
mt3685 h-zrh.40t zr-zrh.40t
c 
c 
c
m3721    92235.00c 7.796476e+22 $ u-235 30.430327 g
         92238.00c 3.811723e+23 $ u-238 150.678129 g
         94239.00c 1.754063e+21 $ pu-239 0.696301 g
         62149.00c 1.133209e+19 $ sm-149 0.002802 g
         40000.66c 1.269832e+25 $ zr 1923.599716 g
          1001.00c 1.999986e+25 $ h 33.475019 g
mt3721 h-zrh.40t zr-zrh.40t
c 
c 
c
m3743    92235.00c 8.105038e+22 $ u-235 31.634671 g
         92238.00c 3.810234e+23 $ u-238 150.619263 g
         94239.00c 1.467001e+21 $ pu-239 0.582348 g
         62149.00c 1.178058e+19 $ sm-149 0.002913 g
         40000.66c 1.277037e+25 $ zr 1934.513848 g
          1001.00c 2.011333e+25 $ h 33.664950 g
mt3743 h-zrh.40t zr-zrh.40t
c 
c 
c
m3748    92235.00c 9.007313e+22 $ u-235 35.156331 g
         92238.00c 3.804945e+23 $ u-238 150.410186 g
         94239.00c 6.061419e+20 $ pu-239 0.240617 g
         62149.00c 1.309202e+19 $ sm-149 0.003238 g
         40000.66c 1.297787e+25 $ zr 1965.947189 g
          1001.00c 2.044015e+25 $ h 34.211961 g
mt3748 h-zrh.40t zr-zrh.40t
c 
c 
c
m3774    92235.00c 8.091964e+22 $ u-235 31.583642 g
         92238.00c 3.914333e+23 $ u-238 154.734318 g
         94239.00c 1.726206e+21 $ pu-239 0.685243 g
         62149.00c 1.176157e+19 $ sm-149 0.002909 g
         40000.66c 1.306141e+25 $ zr 1978.602288 g
          1001.00c 2.057172e+25 $ h 34.432189 g
mt3774 h-zrh.40t zr-zrh.40t
c 
c 
c
m3810    92235.00c 8.109717e+22 $ u-235 31.652935 g
         92238.00c 3.914311e+23 $ u-238 154.733432 g
         94239.00c 1.700589e+21 $ pu-239 0.675074 g
         62149.00c 1.178738e+19 $ sm-149 0.002915 g
         40000.66c 1.306548e+25 $ zr 1979.218480 g
          1001.00c 2.057813e+25 $ h 34.442912 g
mt3810 h-zrh.40t zr-zrh.40t
c 
c 
c
m3835    92235.00c 9.181003e+22 $ u-235 35.834258 g
         92238.00c 4.012571e+23 $ u-238 158.617683 g
         94239.00c 9.470749e+20 $ pu-239 0.375955 g
         62149.00c 1.334448e+19 $ sm-149 0.003300 g
         40000.66c 1.360794e+25 $ zr 2061.392087 g
          1001.00c 2.143250e+25 $ h 35.872920 g
mt3835 h-zrh.40t zr-zrh.40t
c 
c 
c
m3840    92235.00c 9.018959e+22 $ u-235 35.201785 g
         92238.00c 3.909236e+23 $ u-238 154.532838 g
         94239.00c 8.517703e+20 $ pu-239 0.338123 g
         62149.00c 1.310895e+19 $ sm-149 0.003242 g
         40000.66c 1.327581e+25 $ zr 2011.079837 g
          1001.00c 2.090940e+25 $ h 34.997372 g
mt3840 h-zrh.40t zr-zrh.40t
c 
c 
c
m3851    92235.00c 9.003491e+22 $ u-235 35.141414 g
         92238.00c 3.909342e+23 $ u-238 154.537025 g
         94239.00c 8.621487e+20 $ pu-239 0.342243 g
         62149.00c 1.308647e+19 $ sm-149 0.003236 g
         40000.66c 1.327217e+25 $ zr 2010.528963 g
          1001.00c 2.090367e+25 $ h 34.987786 g
mt3851 h-zrh.40t zr-zrh.40t
c 
c 
c
m3852    92235.00c 9.264666e+22 $ u-235 36.160800 g
         92238.00c 3.907692e+23 $ u-238 154.471789 g
         94239.00c 6.087314e+20 $ pu-239 0.241645 g
         62149.00c 1.346608e+19 $ sm-149 0.003330 g
         40000.66c 1.333179e+25 $ zr 2019.560044 g
          1001.00c 2.099757e+25 $ h 35.144947 g
mt3852 h-zrh.40t zr-zrh.40t
c 
c 
c
m3853    92235.00c 8.843845e+22 $ u-235 34.518302 g
         92238.00c 3.910301e+23 $ u-238 154.574921 g
         94239.00c 1.018851e+21 $ pu-239 0.404448 g
         62149.00c 1.285443e+19 $ sm-149 0.003179 g
         40000.66c 1.323564e+25 $ zr 2004.995211 g
          1001.00c 2.084613e+25 $ h 34.891486 g
mt3853 h-zrh.40t zr-zrh.40t
c 
c 
c
m3854    92235.00c 8.014054e+22 $ u-235 31.279554 g
         92238.00c 3.914779e+23 $ u-238 154.751945 g
         94239.00c 1.785883e+21 $ pu-239 0.708933 g
         62149.00c 1.164833e+19 $ sm-149 0.002881 g
         40000.66c 1.304306e+25 $ zr 1975.822018 g
          1001.00c 2.054282e+25 $ h 34.383806 g
mt3854 h-zrh.40t zr-zrh.40t
c 
c 
c
m3855    92235.00c 8.161298e+22 $ u-235 31.854259 g
         92238.00c 3.913990e+23 $ u-238 154.720763 g
         94239.00c 1.664150e+21 $ pu-239 0.660609 g
         62149.00c 1.186235e+19 $ sm-149 0.002933 g
         40000.66c 1.307765e+25 $ zr 1981.061513 g
          1001.00c 2.059729e+25 $ h 34.474985 g
mt3855 h-zrh.40t zr-zrh.40t
c 
c 
c
m3856    92235.00c 9.108826e+22 $ u-235 35.552544 g
         92238.00c 3.908693e+23 $ u-238 154.511373 g
         94239.00c 7.566940e+20 $ pu-239 0.300381 g
         62149.00c 1.323957e+19 $ sm-149 0.003274 g
         40000.66c 1.329617e+25 $ zr 2014.164615 g
          1001.00c 2.094147e+25 $ h 35.051055 g
mt3856 h-zrh.40t zr-zrh.40t
c 
c 
c
m3858    92235.00c 7.937683e+22 $ u-235 30.981471 g
         92238.00c 3.915154e+23 $ u-238 154.766761 g
         94239.00c 1.852027e+21 $ pu-239 0.735190 g
         62149.00c 1.153733e+19 $ sm-149 0.002853 g
         40000.66c 1.302511e+25 $ zr 1973.102692 g
          1001.00c 2.051454e+25 $ h 34.336484 g
mt3858 h-zrh.40t zr-zrh.40t
c 
c 
c
m3862    92235.00c 7.875131e+22 $ u-235 30.737324 g
         92238.00c 3.915446e+23 $ u-238 154.778308 g
         94239.00c 1.907000e+21 $ pu-239 0.757012 g
         62149.00c 1.144641e+19 $ sm-149 0.002831 g
         40000.66c 1.301039e+25 $ zr 1970.872549 g
          1001.00c 2.049136e+25 $ h 34.297674 g
mt3862 h-zrh.40t zr-zrh.40t
c 
c 
c
m3864    92235.00c 8.424253e+22 $ u-235 32.880597 g
         92238.00c 4.016748e+23 $ u-238 158.782782 g
         94239.00c 1.664621e+21 $ pu-239 0.660796 g
         62149.00c 1.224455e+19 $ sm-149 0.003028 g
         40000.66c 1.343306e+25 $ zr 2034.901257 g
          1001.00c 2.115707e+25 $ h 35.411919 g
mt3864 h-zrh.40t zr-zrh.40t
c 
c 
c
m3865    92235.00c 9.186687e+22 $ u-235 35.856442 g
         92238.00c 3.908187e+23 $ u-238 154.491383 g
         94239.00c 6.876911e+20 $ pu-239 0.272989 g
         62149.00c 1.335274e+19 $ sm-149 0.003302 g
         40000.66c 1.331409e+25 $ zr 2016.878709 g
          1001.00c 2.096969e+25 $ h 35.098286 g
mt3865 h-zrh.40t zr-zrh.40t
c 
c 
c
m3866    92235.00c 9.432160e+22 $ u-235 36.814545 g
         92238.00c 4.011019e+23 $ u-238 158.556351 g
         94239.00c 6.971836e+20 $ pu-239 0.276757 g
         62149.00c 1.370953e+19 $ sm-149 0.003390 g
         40000.66c 1.366519e+25 $ zr 2070.065584 g
          1001.00c 2.152268e+25 $ h 36.023859 g
mt3866 h-zrh.40t zr-zrh.40t
c 
c 
c
m3868    92235.00c 8.856487e+22 $ u-235 34.567644 g
         92238.00c 3.910220e+23 $ u-238 154.571746 g
         94239.00c 1.008479e+21 $ pu-239 0.400331 g
         62149.00c 1.287280e+19 $ sm-149 0.003183 g
         40000.66c 1.323858e+25 $ zr 2005.440112 g
          1001.00c 2.085076e+25 $ h 34.899228 g
mt3868 h-zrh.40t zr-zrh.40t
c 
c 
c
m3870    92235.00c 7.905612e+22 $ u-235 30.856296 g
         92238.00c 3.915219e+23 $ u-238 154.769351 g
         94239.00c 1.890880e+21 $ pu-239 0.750613 g
         62149.00c 1.149072e+19 $ sm-149 0.002842 g
         40000.66c 1.301762e+25 $ zr 1971.968873 g
          1001.00c 2.050276e+25 $ h 34.316753 g
mt3870 h-zrh.40t zr-zrh.40t
c 
c 
c
m3872    92235.00c 8.038764e+22 $ u-235 31.375998 g
         92238.00c 4.018684e+23 $ u-238 158.859333 g
         94239.00c 1.995334e+21 $ pu-239 0.792077 g
         62149.00c 1.168425e+19 $ sm-149 0.002889 g
         40000.66c 1.334249e+25 $ zr 2021.180709 g
          1001.00c 2.101442e+25 $ h 35.173151 g
mt3872 h-zrh.40t zr-zrh.40t
c 
c 
c
m3874    92235.00c 9.617779e+22 $ u-235 37.539032 g
         92238.00c 3.905351e+23 $ u-238 154.379256 g
         94239.00c 2.501436e+20 $ pu-239 0.099298 g
         62149.00c 1.397933e+19 $ sm-149 0.003457 g
         40000.66c 1.341165e+25 $ zr 2031.657371 g
          1001.00c 2.112334e+25 $ h 35.355468 g
mt3874 h-zrh.40t zr-zrh.40t
c 
c 
c
m4046    92235.00c 8.481832e+22 $ u-235 33.105331 g
         92238.00c 4.016513e+23 $ u-238 158.773517 g
         94239.00c 1.602148e+21 $ pu-239 0.635996 g
         62149.00c 1.232824e+19 $ sm-149 0.003049 g
         40000.66c 1.344638e+25 $ zr 2036.918647 g
          1001.00c 2.117805e+25 $ h 35.447027 g
mt4046 h-zrh.40t zr-zrh.40t
c 
c 
c
m4049    92235.00c 8.401635e+22 $ u-235 32.792316 g
         92238.00c 4.016925e+23 $ u-238 158.789783 g
         94239.00c 1.674748e+21 $ pu-239 0.664816 g
         62149.00c 1.221168e+19 $ sm-149 0.003020 g
         40000.66c 1.342766e+25 $ zr 2034.083810 g
          1001.00c 2.114857e+25 $ h 35.397694 g
mt4049 h-zrh.40t zr-zrh.40t
c 
c 
c
m4050    92235.00c 7.980041e+22 $ u-235 31.146797 g
         92238.00c 4.018854e+23 $ u-238 158.866068 g
         94239.00c 2.056881e+21 $ pu-239 0.816509 g
         62149.00c 1.159890e+19 $ sm-149 0.002868 g
         40000.66c 1.332866e+25 $ zr 2019.085402 g
          1001.00c 2.099263e+25 $ h 35.136688 g
mt4050 h-zrh.40t zr-zrh.40t
c 
c 
c
m4053    92235.00c 9.225349e+22 $ u-235 36.007346 g
         92238.00c 4.012305e+23 $ u-238 158.607175 g
         94239.00c 9.023579e+20 $ pu-239 0.358204 g
         62149.00c 1.340894e+19 $ sm-149 0.003316 g
         40000.66c 1.361805e+25 $ zr 2062.924458 g
          1001.00c 2.144843e+25 $ h 35.899587 g
mt4053 h-zrh.40t zr-zrh.40t
c 
c 
c
m4054    92235.00c 8.422187e+22 $ u-235 32.872532 g
         92238.00c 3.912709e+23 $ u-238 154.670130 g
         94239.00c 1.412578e+21 $ pu-239 0.560744 g
         62149.00c 1.224155e+19 $ sm-149 0.003027 g
         40000.66c 1.313826e+25 $ zr 1990.243070 g
          1001.00c 2.069276e+25 $ h 34.634765 g
mt4054 h-zrh.40t zr-zrh.40t
c 
c 
c
m4055    92235.00c 9.218487e+22 $ u-235 35.980563 g
         92238.00c 4.012347e+23 $ u-238 158.608835 g
         94239.00c 9.090086e+20 $ pu-239 0.360844 g
         62149.00c 1.339896e+19 $ sm-149 0.003313 g
         40000.66c 1.361648e+25 $ zr 2062.686579 g
          1001.00c 2.144596e+25 $ h 35.895447 g
mt4055 h-zrh.40t zr-zrh.40t
c 
c 
c
m4057    92235.00c 9.072776e+22 $ u-235 35.411837 g
         92238.00c 3.908903e+23 $ u-238 154.519677 g
         94239.00c 7.993919e+20 $ pu-239 0.317330 g
         62149.00c 1.318717e+19 $ sm-149 0.003261 g
         40000.66c 1.328811e+25 $ zr 2012.943066 g
          1001.00c 2.092877e+25 $ h 35.029797 g
mt4057 h-zrh.40t zr-zrh.40t
c 
c 
c
m4060    92235.00c 7.901977e+22 $ u-235 30.842106 g
         92238.00c 3.915236e+23 $ u-238 154.770014 g
         94239.00c 1.894068e+21 $ pu-239 0.751878 g
         62149.00c 1.148543e+19 $ sm-149 0.002840 g
         40000.66c 1.301677e+25 $ zr 1971.839138 g
          1001.00c 2.050141e+25 $ h 34.314495 g
mt4060 h-zrh.40t zr-zrh.40t
c 
c 
c
m4061    92235.00c 9.086799e+22 $ u-235 35.466571 g
         92238.00c 4.013117e+23 $ u-238 158.639268 g
         94239.00c 1.044674e+21 $ pu-239 0.414699 g
         62149.00c 1.320756e+19 $ sm-149 0.003266 g
         40000.66c 1.358647e+25 $ zr 2058.140051 g
          1001.00c 2.139869e+25 $ h 35.816327 g
mt4061 h-zrh.40t zr-zrh.40t
c 
c 
c
m4062    92235.00c 8.930681e+22 $ u-235 34.857231 g
         92238.00c 3.909779e+23 $ u-238 154.554316 g
         94239.00c 9.354445e+20 $ pu-239 0.371338 g
         62149.00c 1.298064e+19 $ sm-149 0.003210 g
         40000.66c 1.325556e+25 $ zr 2008.012939 g
          1001.00c 2.087751e+25 $ h 34.944001 g
mt4062 h-zrh.40t zr-zrh.40t
c 
c 
c
m4063    92235.00c 7.670854e+22 $ u-235 29.940015 g
         92238.00c 3.916259e+23 $ u-238 154.810467 g
         94239.00c 2.094291e+21 $ pu-239 0.831360 g
         62149.00c 1.114950e+19 $ sm-149 0.002757 g
         40000.66c 1.296214e+25 $ zr 1963.563456 g
          1001.00c 2.041536e+25 $ h 34.170479 g
mt4063 h-zrh.40t zr-zrh.40t
c 
c 
c
m4064    92235.00c 8.756699e+22 $ u-235 34.178164 g
         92238.00c 3.806507e+23 $ u-238 150.471929 g
         94239.00c 8.567406e+20 $ pu-239 0.340096 g
         62149.00c 1.272776e+19 $ sm-149 0.003147 g
         40000.66c 1.292081e+25 $ zr 1957.303433 g
          1001.00c 2.035028e+25 $ h 34.061540 g
mt4064 h-zrh.40t zr-zrh.40t
c 
c 
c
m4065    92235.00c 8.363132e+22 $ u-235 32.642035 g
         92238.00c 3.808844e+23 $ u-238 150.564326 g
         94239.00c 1.224249e+21 $ pu-239 0.485984 g
         62149.00c 1.215571e+19 $ sm-149 0.003006 g
         40000.66c 1.283016e+25 $ zr 1943.571491 g
          1001.00c 2.020751e+25 $ h 33.822573 g
mt4065 h-zrh.40t zr-zrh.40t
c 
c 
c
m4066    92235.00c 7.959830e+22 $ u-235 31.067914 g
         92238.00c 3.914967e+23 $ u-238 154.759372 g
         94239.00c 1.843259e+21 $ pu-239 0.731709 g
         62149.00c 1.156952e+19 $ sm-149 0.002861 g
         40000.66c 1.303039e+25 $ zr 1973.902307 g
          1001.00c 2.052286e+25 $ h 34.350399 g
mt4066 h-zrh.40t zr-zrh.40t
c 
c 
c
m4068    92235.00c 8.406668e+22 $ u-235 32.811963 g
         92238.00c 4.016836e+23 $ u-238 158.786293 g
         94239.00c 1.680490e+21 $ pu-239 0.667095 g
         62149.00c 1.221899e+19 $ sm-149 0.003022 g
         40000.66c 1.342895e+25 $ zr 2034.278869 g
          1001.00c 2.115060e+25 $ h 35.401088 g
mt4068 h-zrh.40t zr-zrh.40t
c 
c 
c
m4069    92235.00c 8.930564e+22 $ u-235 34.856774 g
         92238.00c 3.909776e+23 $ u-238 154.554162 g
         94239.00c 9.372975e+20 $ pu-239 0.372074 g
         62149.00c 1.298047e+19 $ sm-149 0.003210 g
         40000.66c 1.325557e+25 $ zr 2008.014256 g
          1001.00c 2.087752e+25 $ h 34.944024 g
mt4069 h-zrh.40t zr-zrh.40t
c 
c 
c
m4070    92235.00c 8.495977e+22 $ u-235 33.160542 g
         92238.00c 4.016475e+23 $ u-238 158.771998 g
         94239.00c 1.582946e+21 $ pu-239 0.628374 g
         62149.00c 1.234880e+19 $ sm-149 0.003054 g
         40000.66c 1.344960e+25 $ zr 2037.406090 g
          1001.00c 2.118311e+25 $ h 35.455509 g
mt4070 h-zrh.40t zr-zrh.40t
c 
c 
c
m4071    92235.00c 7.908951e+22 $ u-235 30.869327 g
         92238.00c 4.019263e+23 $ u-238 158.882205 g
         94239.00c 2.107914e+21 $ pu-239 0.836768 g
         62149.00c 1.149557e+19 $ sm-149 0.002843 g
         40000.66c 1.331182e+25 $ zr 2016.534692 g
          1001.00c 2.096611e+25 $ h 35.092299 g
mt4071 h-zrh.40t zr-zrh.40t
c 
c 
c
m4074    92235.00c 9.004060e+22 $ u-235 35.143635 g
         92238.00c 3.909328e+23 $ u-238 154.536458 g
         94239.00c 8.662276e+20 $ pu-239 0.343862 g
         62149.00c 1.308730e+19 $ sm-149 0.003236 g
         40000.66c 1.327240e+25 $ zr 2010.563593 g
          1001.00c 2.090403e+25 $ h 34.988389 g
mt4074 h-zrh.40t zr-zrh.40t
c 
c 
c
m4077    92235.00c 8.226946e+22 $ u-235 32.110492 g
         92238.00c 3.913727e+23 $ u-238 154.710375 g
         94239.00c 1.593509e+21 $ pu-239 0.632567 g
         62149.00c 1.195777e+19 $ sm-149 0.002957 g
         40000.66c 1.309286e+25 $ zr 1983.365991 g
          1001.00c 2.062125e+25 $ h 34.515088 g
mt4077 h-zrh.40t zr-zrh.40t
c 
c 
c
m4081    92235.00c 8.251744e+22 $ u-235 32.207277 g
         92238.00c 3.913532e+23 $ u-238 154.702670 g
         94239.00c 1.582649e+21 $ pu-239 0.628256 g
         62149.00c 1.199381e+19 $ sm-149 0.002966 g
         40000.66c 1.309878e+25 $ zr 1984.262897 g
          1001.00c 2.063058e+25 $ h 34.530697 g
mt4081 h-zrh.40t zr-zrh.40t
c 
c 
c
m4082    92235.00c 8.322684e+22 $ u-235 32.484163 g
         92238.00c 3.913165e+23 $ u-238 154.688158 g
         94239.00c 1.518253e+21 $ pu-239 0.602693 g
         62149.00c 1.209692e+19 $ sm-149 0.002991 g
         40000.66c 1.311532e+25 $ zr 1986.768489 g
          1001.00c 2.065663e+25 $ h 34.574300 g
mt4082 h-zrh.40t zr-zrh.40t
c 
c 
c
m4083    92235.00c 8.208283e+22 $ u-235 32.037647 g
         92238.00c 4.017890e+23 $ u-238 158.827952 g
         94239.00c 1.846216e+21 $ pu-239 0.732882 g
         62149.00c 1.193064e+19 $ sm-149 0.002950 g
         40000.66c 1.338237e+25 $ zr 2027.222997 g
          1001.00c 2.107724e+25 $ h 35.278300 g
mt4083 h-zrh.40t zr-zrh.40t
c 
c 
c
m4085    92235.00c 8.889243e+22 $ u-235 34.695493 g
         92238.00c 3.805696e+23 $ u-238 150.439860 g
         94239.00c 7.225380e+20 $ pu-239 0.286822 g
         62149.00c 1.292041e+19 $ sm-149 0.003195 g
         40000.66c 1.295098e+25 $ zr 1961.874097 g
          1001.00c 2.039780e+25 $ h 34.141080 g
mt4085 h-zrh.40t zr-zrh.40t
c 
c 
c
m4086    92235.00c 8.205925e+22 $ u-235 32.028441 g
         92238.00c 3.913862e+23 $ u-238 154.715706 g
         94239.00c 1.607959e+21 $ pu-239 0.638303 g
         62149.00c 1.192722e+19 $ sm-149 0.002949 g
         40000.66c 1.308790e+25 $ zr 1982.614946 g
          1001.00c 2.061344e+25 $ h 34.502018 g
mt4086 h-zrh.40t zr-zrh.40t
c 
c 
c
m4087    92235.00c 8.663791e+22 $ u-235 33.815533 g
         92238.00c 3.911304e+23 $ u-238 154.614598 g
         94239.00c 1.202709e+21 $ pu-239 0.477433 g
         62149.00c 1.259272e+19 $ sm-149 0.003114 g
         40000.66c 1.319442e+25 $ zr 1998.751533 g
          1001.00c 2.078122e+25 $ h 34.782832 g
mt4087 h-zrh.40t zr-zrh.40t
c 
c 
c
m4088    92235.00c 8.039193e+22 $ u-235 31.377672 g
         92238.00c 3.810578e+23 $ u-238 150.632856 g
         94239.00c 1.526982e+21 $ pu-239 0.606158 g
         62149.00c 1.168487e+19 $ sm-149 0.002890 g
         40000.66c 1.275503e+25 $ zr 1932.190393 g
          1001.00c 2.008918e+25 $ h 33.624516 g
mt4088 h-zrh.40t zr-zrh.40t
c 
c 
c
m4090    92235.00c 8.492544e+22 $ u-235 33.147143 g
         92238.00c 4.016399e+23 $ u-238 158.768986 g
         94239.00c 1.602957e+21 $ pu-239 0.636317 g
         62149.00c 1.234381e+19 $ sm-149 0.003052 g
         40000.66c 1.344900e+25 $ zr 2037.316506 g
          1001.00c 2.118218e+25 $ h 35.453950 g
mt4090 h-zrh.40t zr-zrh.40t
c 
c 
c
m4091    92235.00c 9.107940e+22 $ u-235 35.549088 g
         92238.00c 4.013011e+23 $ u-238 158.635084 g
         94239.00c 1.017415e+21 $ pu-239 0.403878 g
         62149.00c 1.323829e+19 $ sm-149 0.003274 g
         40000.66c 1.359118e+25 $ zr 2058.854372 g
          1001.00c 2.140611e+25 $ h 35.828758 g
mt4091 h-zrh.40t zr-zrh.40t
c 
c 
c
m4094    92235.00c 8.995891e+22 $ u-235 35.111748 g
         92238.00c 3.909389e+23 $ u-238 154.538872 g
         94239.00c 8.695293e+20 $ pu-239 0.345172 g
         62149.00c 1.307542e+19 $ sm-149 0.003233 g
         40000.66c 1.327043e+25 $ zr 2010.265621 g
          1001.00c 2.090093e+25 $ h 34.983203 g
mt4094 h-zrh.40t zr-zrh.40t
c 
c 
c
m4095    92235.00c 8.556571e+22 $ u-235 33.397046 g
         92238.00c 3.911969e+23 $ u-238 154.640871 g
         94239.00c 1.287821e+21 $ pu-239 0.511219 g
         62149.00c 1.243688e+19 $ sm-149 0.003075 g
         40000.66c 1.316939e+25 $ zr 1994.959159 g
          1001.00c 2.074179e+25 $ h 34.716836 g
mt4095 h-zrh.40t zr-zrh.40t
c 
c 
c
m4103    92235.00c 8.278699e+22 $ u-235 32.312488 g
         92238.00c 3.913473e+23 $ u-238 154.700311 g
         94239.00c 1.544110e+21 $ pu-239 0.612957 g
         62149.00c 1.203299e+19 $ sm-149 0.002976 g
         40000.66c 1.310490e+25 $ zr 1985.189263 g
          1001.00c 2.064021e+25 $ h 34.546817 g
mt4103 h-zrh.40t zr-zrh.40t
c 
c 
c
m4104    92235.00c 8.207999e+22 $ u-235 32.036539 g
         92238.00c 3.913838e+23 $ u-238 154.714768 g
         94239.00c 1.608301e+21 $ pu-239 0.638439 g
         62149.00c 1.193023e+19 $ sm-149 0.002950 g
         40000.66c 1.308841e+25 $ zr 1982.692141 g
          1001.00c 2.061425e+25 $ h 34.503362 g
mt4104 h-zrh.40t zr-zrh.40t
c 
c 
c
m4106    92235.00c 8.330708e+22 $ u-235 32.515482 g
         92238.00c 3.809016e+23 $ u-238 150.571117 g
         94239.00c 1.257067e+21 $ pu-239 0.499011 g
         62149.00c 1.210859e+19 $ sm-149 0.002994 g
         40000.66c 1.282271e+25 $ zr 1942.442175 g
          1001.00c 2.019576e+25 $ h 33.802921 g
mt4106 h-zrh.40t zr-zrh.40t
c 
c 
c
m4107    92235.00c 8.593030e+22 $ u-235 33.539348 g
         92238.00c 3.911703e+23 $ u-238 154.630359 g
         94239.00c 1.268957e+21 $ pu-239 0.503731 g
         62149.00c 1.248987e+19 $ sm-149 0.003089 g
         40000.66c 1.317807e+25 $ zr 1996.274338 g
          1001.00c 2.075546e+25 $ h 34.739723 g
mt4107 h-zrh.40t zr-zrh.40t
c 
c 
c
m4110    92235.00c 8.819441e+22 $ u-235 34.423049 g
         92238.00c 4.014693e+23 $ u-238 158.701576 g
         94239.00c 1.289097e+21 $ pu-239 0.511726 g
         62149.00c 1.281895e+19 $ sm-149 0.003170 g
         40000.66c 1.352471e+25 $ zr 2048.784844 g
          1001.00c 2.130142e+25 $ h 35.653525 g
mt4110 h-zrh.40t zr-zrh.40t
c 
c 
c
m4111    92235.00c 8.679011e+22 $ u-235 33.874940 g
         92238.00c 3.911260e+23 $ u-238 154.612845 g
         94239.00c 1.176770e+21 $ pu-239 0.467136 g
         62149.00c 1.261484e+19 $ sm-149 0.003120 g
         40000.66c 1.319773e+25 $ zr 1999.252604 g
          1001.00c 2.078643e+25 $ h 34.791552 g
mt4111 h-zrh.40t zr-zrh.40t
c 
c 
c
m4113    92235.00c 8.639017e+22 $ u-235 33.718839 g
         92238.00c 4.015629e+23 $ u-238 158.738549 g
         94239.00c 1.469182e+21 $ pu-239 0.583213 g
         62149.00c 1.255671e+19 $ sm-149 0.003105 g
         40000.66c 1.348310e+25 $ zr 2042.481471 g
          1001.00c 2.123588e+25 $ h 35.543832 g
mt4113 h-zrh.40t zr-zrh.40t
c 
c 
c
m4114    92235.00c 8.999649e+22 $ u-235 35.126419 g
         92238.00c 3.909359e+23 $ u-238 154.537695 g
         94239.00c 8.687162e+20 $ pu-239 0.344850 g
         62149.00c 1.308089e+19 $ sm-149 0.003235 g
         40000.66c 1.327135e+25 $ zr 2010.404980 g
          1001.00c 2.090238e+25 $ h 34.985628 g
mt4114 h-zrh.40t zr-zrh.40t
c 
c 
c
m4117    92235.00c 9.025869e+22 $ u-235 35.228758 g
         92238.00c 3.909210e+23 $ u-238 154.531812 g
         94239.00c 8.377163e+20 $ pu-239 0.332544 g
         62149.00c 1.311900e+19 $ sm-149 0.003244 g
         40000.66c 1.327723e+25 $ zr 2011.295340 g
          1001.00c 2.091164e+25 $ h 35.001123 g
mt4117 h-zrh.40t zr-zrh.40t
c 
c 
c
m4118    92235.00c 9.216622e+22 $ u-235 35.973281 g
         92238.00c 4.012366e+23 $ u-238 158.609565 g
         94239.00c 9.079180e+20 $ pu-239 0.360411 g
         62149.00c 1.339625e+19 $ sm-149 0.003313 g
         40000.66c 1.361599e+25 $ zr 2062.612668 g
          1001.00c 2.144519e+25 $ h 35.894161 g
mt4118 h-zrh.40t zr-zrh.40t
c 
c 
c
m4119    92235.00c 8.338736e+22 $ u-235 32.546817 g
         92238.00c 3.913081e+23 $ u-238 154.684835 g
         94239.00c 1.503605e+21 $ pu-239 0.596878 g
         62149.00c 1.212026e+19 $ sm-149 0.002997 g
         40000.66c 1.311906e+25 $ zr 1987.334734 g
          1001.00c 2.066252e+25 $ h 34.584154 g
mt4119 h-zrh.40t zr-zrh.40t
c 
c 
c
m4120    92235.00c 9.145602e+22 $ u-235 35.696086 g
         92238.00c 4.012785e+23 $ u-238 158.626145 g
         94239.00c 9.812009e+20 $ pu-239 0.389502 g
         62149.00c 1.329303e+19 $ sm-149 0.003287 g
         40000.66c 1.359982e+25 $ zr 2060.163008 g
          1001.00c 2.141972e+25 $ h 35.851531 g
mt4120 h-zrh.40t zr-zrh.40t
c 
c 
c
m4121    92235.00c 9.204084e+22 $ u-235 35.924345 g
         92238.00c 4.012435e+23 $ u-238 158.612313 g
         94239.00c 9.229512e+20 $ pu-239 0.366379 g
         62149.00c 1.337803e+19 $ sm-149 0.003308 g
         40000.66c 1.361318e+25 $ zr 2062.187118 g
          1001.00c 2.144076e+25 $ h 35.886756 g
mt4121 h-zrh.40t zr-zrh.40t
c 
c 
c
m4122    92235.00c 8.304080e+22 $ u-235 32.411550 g
         92238.00c 3.809164e+23 $ u-238 150.576978 g
         94239.00c 1.281902e+21 $ pu-239 0.508870 g
         62149.00c 1.206988e+19 $ sm-149 0.002985 g
         40000.66c 1.281655e+25 $ zr 1941.508847 g
          1001.00c 2.018606e+25 $ h 33.786679 g
mt4122 h-zrh.40t zr-zrh.40t
c 
c 
c
m4123    92235.00c 7.790860e+22 $ u-235 30.408410 g
         92238.00c 4.019661e+23 $ u-238 158.897943 g
         94239.00c 2.219096e+21 $ pu-239 0.880903 g
         62149.00c 1.132393e+19 $ sm-149 0.002800 g
         40000.66c 1.328381e+25 $ zr 2012.291415 g
          1001.00c 2.092199e+25 $ h 35.018457 g
mt4123 h-zrh.40t zr-zrh.40t
c 
c 
c
m4125    92235.00c 7.854797e+22 $ u-235 30.657961 g
         92238.00c 3.915528e+23 $ u-238 154.781566 g
         94239.00c 1.926117e+21 $ pu-239 0.764600 g
         62149.00c 1.141686e+19 $ sm-149 0.002823 g
         40000.66c 1.300560e+25 $ zr 1970.147611 g
          1001.00c 2.048382e+25 $ h 34.285058 g
mt4125 h-zrh.40t zr-zrh.40t
c 
c 
c
m4126    92235.00c 8.492883e+22 $ u-235 33.148467 g
         92238.00c 3.912256e+23 $ u-238 154.652222 g
         94239.00c 1.362040e+21 $ pu-239 0.540682 g
         62149.00c 1.234431e+19 $ sm-149 0.003053 g
         40000.66c 1.315488e+25 $ zr 1992.760879 g
          1001.00c 2.071893e+25 $ h 34.678581 g
mt4126 h-zrh.40t zr-zrh.40t
c 
c 
c
m4127    92235.00c 8.735348e+22 $ u-235 34.094829 g
         92238.00c 3.910933e+23 $ u-238 154.599929 g
         94239.00c 1.123900e+21 $ pu-239 0.446149 g
         62149.00c 1.269673e+19 $ sm-149 0.003140 g
         40000.66c 1.321072e+25 $ zr 2001.220438 g
          1001.00c 2.080689e+25 $ h 34.825796 g
mt4127 h-zrh.40t zr-zrh.40t
c 
c 
c
m4129    92235.00c 9.311693e+22 $ u-235 36.344351 g
         92238.00c 3.907392e+23 $ u-238 154.459928 g
         94239.00c 5.589728e+20 $ pu-239 0.221892 g
         62149.00c 1.353444e+19 $ sm-149 0.003347 g
         40000.66c 1.334240e+25 $ zr 2021.167638 g
          1001.00c 2.101428e+25 $ h 35.172923 g
mt4129 h-zrh.40t zr-zrh.40t
c 
c 
c
m4130    92235.00c 9.217144e+22 $ u-235 35.975319 g
         92238.00c 4.012351e+23 $ u-238 158.608984 g
         94239.00c 9.121396e+20 $ pu-239 0.362087 g
         62149.00c 1.339701e+19 $ sm-149 0.003313 g
         40000.66c 1.361621e+25 $ zr 2062.645819 g
          1001.00c 2.144553e+25 $ h 35.894738 g
mt4130 h-zrh.40t zr-zrh.40t
c 
c 
c
m4131    92235.00c 9.229952e+22 $ u-235 36.025309 g
         92238.00c 3.907920e+23 $ u-238 154.480791 g
         94239.00c 6.401428e+20 $ pu-239 0.254114 g
         62149.00c 1.341563e+19 $ sm-149 0.003318 g
         40000.66c 1.332382e+25 $ zr 2018.353645 g
          1001.00c 2.098502e+25 $ h 35.123953 g
mt4131 h-zrh.40t zr-zrh.40t
c 
c 
c
m4132    92235.00c 8.900666e+22 $ u-235 34.740079 g
         92238.00c 3.805620e+23 $ u-238 150.436883 g
         94239.00c 7.131171e+20 $ pu-239 0.283082 g
         62149.00c 1.293701e+19 $ sm-149 0.003199 g
         40000.66c 1.295363e+25 $ zr 1962.274781 g
          1001.00c 2.040197e+25 $ h 34.148053 g
mt4132 h-zrh.40t zr-zrh.40t
c 
c 
c
m4133    92235.00c 9.413825e+22 $ u-235 36.742981 g
         92238.00c 4.011131e+23 $ u-238 158.560745 g
         94239.00c 7.182734e+20 $ pu-239 0.285129 g
         62149.00c 1.368288e+19 $ sm-149 0.003384 g
         40000.66c 1.366109e+25 $ zr 2069.443463 g
          1001.00c 2.151621e+25 $ h 36.013033 g
mt4133 h-zrh.40t zr-zrh.40t
c 
c 
c
m4134    92235.00c 8.852919e+22 $ u-235 34.553719 g
         92238.00c 3.910247e+23 $ u-238 154.572785 g
         94239.00c 1.010167e+21 $ pu-239 0.401001 g
         62149.00c 1.286762e+19 $ sm-149 0.003182 g
         40000.66c 1.323772e+25 $ zr 2005.310858 g
          1001.00c 2.084942e+25 $ h 34.896979 g
mt4134 h-zrh.40t zr-zrh.40t
c 
c 
c
m8732    92235.00c 9.640338e+22 $ u-235 37.627082 g
         92238.00c 3.832026e+23 $ u-238 151.480687 g
         94239.00c 3.983383e+19 $ pu-239 0.015813 g
         62149.00c 1.401212e+19 $ sm-149 0.003465 g
         40000.66c 1.320951e+25 $ zr 2001.037126 g
          1001.00c 2.080498e+25 $ h 34.822606 g
mt8732 h-zrh.40t zr-zrh.40t
c 
c 
c
m8733    92235.00c 9.674856e+22 $ u-235 37.761810 g
         92238.00c 3.846420e+23 $ u-238 152.049711 g
         94239.00c 4.171174e+19 $ pu-239 0.016558 g
         62149.00c 1.406229e+19 $ sm-149 0.003477 g
         40000.66c 1.325872e+25 $ zr 2008.491114 g
          1001.00c 2.088248e+25 $ h 34.952323 g
mt8733 h-zrh.40t zr-zrh.40t
c 
c 
c
m8734    92235.00c 9.637362e+22 $ u-235 37.615467 g
         92238.00c 3.831001e+23 $ u-238 151.440185 g
         94239.00c 4.022927e+19 $ pu-239 0.015970 g
         62149.00c 1.400779e+19 $ sm-149 0.003464 g
         40000.66c 1.320588e+25 $ zr 2000.487359 g
          1001.00c 2.079927e+25 $ h 34.813039 g
mt8734 h-zrh.40t zr-zrh.40t
c 
c 
c
m8735    92235.00c 9.822079e+22 $ u-235 38.336434 g
         92238.00c 3.907071e+23 $ u-238 154.447264 g
         94239.00c 4.469424e+19 $ pu-239 0.017742 g
         62149.00c 1.427628e+19 $ sm-149 0.003530 g
         40000.66c 1.346640e+25 $ zr 2039.951004 g
          1001.00c 2.120957e+25 $ h 35.499797 g
mt8735 h-zrh.40t zr-zrh.40t
c 
c 
c
m8736    92235.00c 9.788822e+22 $ u-235 38.206628 g
         92238.00c 3.893713e+23 $ u-238 153.919220 g
         94239.00c 4.421188e+19 $ pu-239 0.017551 g
         62149.00c 1.422794e+19 $ sm-149 0.003518 g
         40000.66c 1.342043e+25 $ zr 2032.988537 g
          1001.00c 2.113718e+25 $ h 35.378634 g
mt8736 h-zrh.40t zr-zrh.40t
c 
c           
c                        
c
c --End Fuel Materials--
c
c --End Materials--
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c
c ------------------------------
c ----- Source definitions -----
c ------------------------------
c
c
ksrc  0.0500  4.1038  45.8284
      0.0500  4.1038  30.4716
      0.0500  4.1038  15.1147
      0.0500  4.1038  -0.2421
      0.0500  4.1038  -15.5989
      3.5605  2.0769  45.8284
      3.5605  2.0769  30.4716
      3.5605  2.0769  15.1147
      3.5605  2.0769  -0.2421
      3.5605  2.0769  -15.5989
      3.5605  -1.9769  45.8284
      3.5605  -1.9769  30.4716
      3.5605  -1.9769  15.1147
      3.5605  -1.9769  -0.2421
      3.5605  -1.9769  -15.5989
      0.0500  -4.0038  45.8284
      0.0500  -4.0038  30.4716
      0.0500  -4.0038  15.1147
      0.0500  -4.0038  -0.2421
      0.0500  -4.0038  -15.5989
      -3.4605  -1.9769  45.8284
      -3.4605  -1.9769  30.4716
      -3.4605  -1.9769  15.1147
      -3.4605  -1.9769  -0.2421
      -3.4605  -1.9769  -15.5989
      -3.4605  2.0769  45.8284
      -3.4605  2.0769  30.4716
      -3.4605  2.0769  15.1147
      -3.4605  2.0769  -0.2421
      -3.4605  2.0769  -15.5989
      0.0500  8.0307  45.8284
      0.0500  8.0307  30.4716
      0.0500  8.0307  15.1147
      0.0500  8.0307  -0.2421
      0.0500  8.0307  -15.5989
      4.0403  6.9613  45.8284
      4.0403  6.9613  30.4716
      4.0403  6.9613  15.1147
      4.0403  6.9613  -0.2421
      4.0403  6.9613  -15.5989
      6.9613  4.0403  45.8284
      6.9613  4.0403  30.4716
      6.9613  4.0403  15.1147
      6.9613  4.0403  -0.2421
      6.9613  4.0403  -15.5989
      8.0307  0.0500  45.8284
      8.0307  0.0500  30.4716
      8.0307  0.0500  15.1147
      8.0307  0.0500  -0.2421
      8.0307  0.0500  -15.5989
      4.0403  -6.8613  45.8284
      4.0403  -6.8613  30.4716
      4.0403  -6.8613  15.1147
      4.0403  -6.8613  -0.2421
      4.0403  -6.8613  -15.5989
      0.0500  -7.9307  45.8284
      0.0500  -7.9307  30.4716
      0.0500  -7.9307  15.1147
      0.0500  -7.9307  -0.2421
      0.0500  -7.9307  -15.5989
      -3.9403  -6.8613  45.8284
      -3.9403  -6.8613  30.4716
      -3.9403  -6.8613  15.1147
      -3.9403  -6.8613  -0.2421
      -3.9403  -6.8613  -15.5989
      -7.9307  0.0500  45.8284
      -7.9307  0.0500  30.4716
      -7.9307  0.0500  15.1147
      -7.9307  0.0500  -0.2421
      -7.9307  0.0500  -15.5989
      -6.8613  4.0403  45.8284
      -6.8613  4.0403  30.4716
      -6.8613  4.0403  15.1147
      -6.8613  4.0403  -0.2421
      -6.8613  4.0403  -15.5989
      -3.9403  6.9613  45.8284
      -3.9403  6.9613  30.4716
      -3.9403  6.9613  15.1147
      -3.9403  6.9613  -0.2421
      -3.9403  6.9613  -15.5989
      0.0500  11.9956  45.8284
      0.0500  11.9956  30.4716
      0.0500  11.9956  15.1147
      0.0500  11.9956  -0.2421
      0.0500  11.9956  -15.5989
      4.1353  11.2753  45.8284
      4.1353  11.2753  30.4716
      4.1353  11.2753  15.1147
      4.1353  11.2753  -0.2421
      4.1353  11.2753  -15.5989
      7.7287  9.2004  45.8284
      7.7287  9.2004  30.4716
      7.7287  9.2004  15.1147
      7.7287  9.2004  -0.2421
      7.7287  9.2004  -15.5989
      10.3949  6.0228  45.8284
      10.3949  6.0228  30.4716
      10.3949  6.0228  15.1147
      10.3949  6.0228  -0.2421
      10.3949  6.0228  -15.5989
      11.8140  2.1237  45.8284
      11.8140  2.1237  30.4716
      11.8140  2.1237  15.1147
      11.8140  2.1237  -0.2421
      11.8140  2.1237  -15.5989
      11.8140  -2.0237  45.8284
      11.8140  -2.0237  30.4716
      11.8140  -2.0237  15.1147
      11.8140  -2.0237  -0.2421
      11.8140  -2.0237  -15.5989
      10.3949  -5.9228  45.8284
      10.3949  -5.9228  30.4716
      10.3949  -5.9228  15.1147
      10.3949  -5.9228  -0.2421
      10.3949  -5.9228  -15.5989
      7.7287  -9.1004  45.8284
      7.7287  -9.1004  30.4716
      7.7287  -9.1004  15.1147
      7.7287  -9.1004  -0.2421
      7.7287  -9.1004  -15.5989
      4.1353  -11.1753  45.8284
      4.1353  -11.1753  30.4716
      4.1353  -11.1753  15.1147
      4.1353  -11.1753  -0.2421
      4.1353  -11.1753  -15.5989
      0.0500  -11.8956  45.8284
      0.0500  -11.8956  30.4716
      0.0500  -11.8956  15.1147
      0.0500  -11.8956  -0.2421
      0.0500  -11.8956  -15.5989
      -4.0353  -11.1753  45.8284
      -4.0353  -11.1753  30.4716
      -4.0353  -11.1753  15.1147
      -4.0353  -11.1753  -0.2421
      -4.0353  -11.1753  -15.5989
      -7.6287  -9.1004  45.8284
      -7.6287  -9.1004  30.4716
      -7.6287  -9.1004  15.1147
      -7.6287  -9.1004  -0.2421
      -7.6287  -9.1004  -15.5989
      -10.2949  -5.9228  45.8284
      -10.2949  -5.9228  30.4716
      -10.2949  -5.9228  15.1147
      -10.2949  -5.9228  -0.2421
      -10.2949  -5.9228  -15.5989
      -11.7140  -2.0237  45.8284
      -11.7140  -2.0237  30.4716
      -11.7140  -2.0237  15.1147
      -11.7140  -2.0237  -0.2421
      -11.7140  -2.0237  -15.5989
      -11.7140  2.1237  45.8284
      -11.7140  2.1237  30.4716
      -11.7140  2.1237  15.1147
      -11.7140  2.1237  -0.2421
      -11.7140  2.1237  -15.5989
      -10.2949  6.0228  45.8284
      -10.2949  6.0228  30.4716
      -10.2949  6.0228  15.1147
      -10.2949  6.0228  -0.2421
      -10.2949  6.0228  -15.5989
      -7.6287  9.2004  45.8284
      -7.6287  9.2004  30.4716
      -7.6287  9.2004  15.1147
      -7.6287  9.2004  -0.2421
      -7.6287  9.2004  -15.5989
      -4.0353  11.2753  45.8284
      -4.0353  11.2753  30.4716
      -4.0353  11.2753  15.1147
      -4.0353  11.2753  -0.2421
      -4.0353  11.2753  -15.5989
      4.1689  15.4228  45.8284
      4.1689  15.4228  30.4716
      4.1689  15.4228  15.1147
      4.1689  15.4228  -0.2421
      4.1689  15.4228  -15.5989
      8.0078  13.8328  45.8284
      8.0078  13.8328  30.4716
      8.0078  13.8328  15.1147
      8.0078  13.8328  -0.2421
      8.0078  13.8328  -15.5989
      11.3040  11.3040  45.8284
      11.3040  11.3040  30.4716
      11.3040  11.3040  15.1147
      11.3040  11.3040  -0.2421
      11.3040  11.3040  -15.5989
      13.9242  8.0078  45.8284
      13.9242  8.0078  30.4716
      13.9242  8.0078  15.1147
      13.9242  8.0078  -0.2421
      13.9242  8.0078  -15.5989
      15.4228  4.1689  45.8284
      15.4228  4.1689  30.4716
      15.4228  4.1689  15.1147
      15.4228  4.1689  -0.2421
      15.4228  4.1689  -15.5989
      15.9656  0.0500  45.8284
      15.9656  0.0500  30.4716
      15.9656  0.0500  15.1147
      15.9656  0.0500  -0.2421
      15.9656  0.0500  -15.5989
      15.4228  -4.0689  45.8284
      15.4228  -4.0689  30.4716
      15.4228  -4.0689  15.1147
      15.4228  -4.0689  -0.2421
      15.4228  -4.0689  -15.5989
      13.9242  -7.9078  45.8284
      13.9242  -7.9078  30.4716
      13.9242  -7.9078  15.1147
      13.9242  -7.9078  -0.2421
      13.9242  -7.9078  -15.5989
      11.3040  -11.2040  45.8284
      11.3040  -11.2040  30.4716
      11.3040  -11.2040  15.1147
      11.3040  -11.2040  -0.2421
      11.3040  -11.2040  -15.5989
      8.0078  -13.7328  45.8284
      8.0078  -13.7328  30.4716
      8.0078  -13.7328  15.1147
      8.0078  -13.7328  -0.2421
      8.0078  -13.7328  -15.5989
      4.1689  -15.3228  45.8284
      4.1689  -15.3228  30.4716
      4.1689  -15.3228  15.1147
      4.1689  -15.3228  -0.2421
      4.1689  -15.3228  -15.5989
      0.0500  -15.8656  45.8284
      0.0500  -15.8656  30.4716
      0.0500  -15.8656  15.1147
      0.0500  -15.8656  -0.2421
      0.0500  -15.8656  -15.5989
      -4.0689  -15.3228  45.8284
      -4.0689  -15.3228  30.4716
      -4.0689  -15.3228  15.1147
      -4.0689  -15.3228  -0.2421
      -4.0689  -15.3228  -15.5989
      -7.9078  -13.7328  45.8284
      -7.9078  -13.7328  30.4716
      -7.9078  -13.7328  15.1147
      -7.9078  -13.7328  -0.2421
      -7.9078  -13.7328  -15.5989
      -11.2040  -11.2040  45.8284
      -11.2040  -11.2040  30.4716
      -11.2040  -11.2040  15.1147
      -11.2040  -11.2040  -0.2421
      -11.2040  -11.2040  -15.5989
      -13.8242  -7.9078  45.8284
      -13.8242  -7.9078  30.4716
      -13.8242  -7.9078  15.1147
      -13.8242  -7.9078  -0.2421
      -13.8242  -7.9078  -15.5989
      -15.3228  -4.0689  45.8284
      -15.3228  -4.0689  30.4716
      -15.3228  -4.0689  15.1147
      -15.3228  -4.0689  -0.2421
      -15.3228  -4.0689  -15.5989
      -15.8656  0.0500  45.8284
      -15.8656  0.0500  30.4716
      -15.8656  0.0500  15.1147
      -15.8656  0.0500  -0.2421
      -15.8656  0.0500  -15.5989
      -15.3228  4.1689  45.8284
      -15.3228  4.1689  30.4716
      -15.3228  4.1689  15.1147
      -15.3228  4.1689  -0.2421
      -15.3228  4.1689  -15.5989
      -13.8242  8.0078  45.8284
      -13.8242  8.0078  30.4716
      -13.8242  8.0078  15.1147
      -13.8242  8.0078  -0.2421
      -13.8242  8.0078  -15.5989
      -11.2040  11.3040  45.8284
      -11.2040  11.3040  30.4716
      -11.2040  11.3040  15.1147
      -11.2040  11.3040  -0.2421
      -11.2040  11.3040  -15.5989
      -7.9078  13.8328  45.8284
      -7.9078  13.8328  30.4716
      -7.9078  13.8328  15.1147
      -7.9078  13.8328  -0.2421
      -7.9078  13.8328  -15.5989
      -4.0689  15.4228  45.8284
      -4.0689  15.4228  30.4716
      -4.0689  15.4228  15.1147
      -4.0689  15.4228  -0.2421
      -4.0689  15.4228  -15.5989
      0.0500  19.9382  45.8284
      0.0500  19.9382  30.4716
      0.0500  19.9382  15.1147
      0.0500  19.9382  -0.2421
      0.0500  19.9382  -15.5989
      4.1849  19.5026  45.8284
      4.1849  19.5026  30.4716
      4.1849  19.5026  15.1147
      4.1849  19.5026  -0.2421
      4.1849  19.5026  -15.5989
      8.1386  18.2079  45.8284
      8.1386  18.2079  30.4716
      8.1386  18.2079  15.1147
      8.1386  18.2079  -0.2421
      8.1386  18.2079  -15.5989
      11.7404  16.1396  45.8284
      11.7404  16.1396  30.4716
      11.7404  16.1396  15.1147
      11.7404  16.1396  -0.2421
      11.7404  16.1396  -15.5989
      14.8290  13.3573  45.8284
      14.8290  13.3573  30.4716
      14.8290  13.3573  15.1147
      14.8290  13.3573  -0.2421
      14.8290  13.3573  -15.5989
      17.2732  9.9941  45.8284
      17.2732  9.9941  30.4716
      17.2732  9.9941  15.1147
      17.2732  9.9941  -0.2421
      17.2732  9.9941  -15.5989
      18.9656  6.1955  45.8284
      18.9656  6.1955  30.4716
      18.9656  6.1955  15.1147
      18.9656  6.1955  -0.2421
      18.9656  6.1955  -15.5989
      19.8272  2.1206  45.8284
      19.8272  2.1206  30.4716
      19.8272  2.1206  15.1147
      19.8272  2.1206  -0.2421
      19.8272  2.1206  -15.5989
      18.9656  -6.0955  45.8284
      18.9656  -6.0955  30.4716
      18.9656  -6.0955  15.1147
      18.9656  -6.0955  -0.2421
      18.9656  -6.0955  -15.5989
      17.2732  -9.8941  45.8284
      17.2732  -9.8941  30.4716
      17.2732  -9.8941  15.1147
      17.2732  -9.8941  -0.2421
      17.2732  -9.8941  -15.5989
      14.8290  -13.2573  45.8284
      14.8290  -13.2573  30.4716
      14.8290  -13.2573  15.1147
      14.8290  -13.2573  -0.2421
      14.8290  -13.2573  -15.5989
      11.7404  -16.0396  45.8284
      11.7404  -16.0396  30.4716
      11.7404  -16.0396  15.1147
      11.7404  -16.0396  -0.2421
      11.7404  -16.0396  -15.5989
      8.1386  -18.1179  45.8284
      8.1386  -18.1179  30.4716
      8.1386  -18.1179  15.1147
      8.1386  -18.1179  -0.2421
      8.1386  -18.1179  -15.5989
      4.1849  -19.4026  45.8284
      4.1849  -19.4026  30.4716
      4.1849  -19.4026  15.1147
      4.1849  -19.4026  -0.2421
      4.1849  -19.4026  -15.5989
      0.0500  -19.8382  45.8284
      0.0500  -19.8382  30.4716
      0.0500  -19.8382  15.1147
      0.0500  -19.8382  -0.2421
      0.0500  -19.8382  -15.5989
      -4.0849  -19.4026  45.8284
      -4.0849  -19.4026  30.4716
      -4.0849  -19.4026  15.1147
      -4.0849  -19.4026  -0.2421
      -4.0849  -19.4026  -15.5989
      -8.0386  -18.1179  45.8284
      -8.0386  -18.1179  30.4716
      -8.0386  -18.1179  15.1147
      -8.0386  -18.1179  -0.2421
      -8.0386  -18.1179  -15.5989
      -11.6403  -16.0396  45.8284
      -11.6403  -16.0396  30.4716
      -11.6403  -16.0396  15.1147
      -11.6403  -16.0396  -0.2421
      -11.6403  -16.0396  -15.5989
      -14.7290  -13.2573  45.8284
      -14.7290  -13.2573  30.4716
      -14.7290  -13.2573  15.1147
      -14.7290  -13.2573  -0.2421
      -14.7290  -13.2573  -15.5989
      -17.1732  -9.8941  45.8284
      -17.1732  -9.8941  30.4716
      -17.1732  -9.8941  15.1147
      -17.1732  -9.8941  -0.2421
      -17.1732  -9.8941  -15.5989
      -18.8656  -6.0955  45.8284
      -18.8656  -6.0955  30.4716
      -18.8656  -6.0955  15.1147
      -18.8656  -6.0955  -0.2421
      -18.8656  -6.0955  -15.5989
      -19.7272  -2.0206  45.8284
      -19.7272  -2.0206  30.4716
      -19.7272  -2.0206  15.1147
      -19.7272  -2.0206  -0.2421
      -19.7272  -2.0206  -15.5989
      -19.7272  2.1206  45.8284
      -19.7272  2.1206  30.4716
      -19.7272  2.1206  15.1147
      -19.7272  2.1206  -0.2421
      -19.7272  2.1206  -15.5989
      -18.8656  6.1955  45.8284
      -18.8656  6.1955  30.4716
      -18.8656  6.1955  15.1147
      -18.8656  6.1955  -0.2421
      -18.8656  6.1955  -15.5989
      -17.1732  9.9941  45.8284
      -17.1732  9.9941  30.4716
      -17.1732  9.9941  15.1147
      -17.1732  9.9941  -0.2421
      -17.1732  9.9941  -15.5989
      -14.7290  13.3573  45.8284
      -14.7290  13.3573  30.4716
      -14.7290  13.3573  15.1147
      -14.7290  13.3573  -0.2421
      -14.7290  13.3573  -15.5989
      -11.6403  16.1396  45.8284
      -11.6403  16.1396  30.4716
      -11.6403  16.1396  15.1147
      -11.6403  16.1396  -0.2421
      -11.6403  16.1396  -15.5989
      -8.0386  18.2179  45.8284
      -8.0386  18.2179  30.4716
      -8.0386  18.2179  15.1147
      -8.0386  18.2179  -0.2421
      -8.0386  18.2179  -15.5989
      -4.0849  19.5026  45.8284
      -4.0849  19.5026  30.4716
      -4.0849  19.5026  15.1147
      -4.0849  19.5026  -0.2421
      -4.0849  19.5026  -15.5989
c
c
c
c
c
mode  n  
c
kcode 100000 1 15 115 $ kcode card, NIST default is 20000 neutrons, discard 5, run 105 total active cycles
c
kopts blocksize=10 kinetics=yes precursor=yes
c