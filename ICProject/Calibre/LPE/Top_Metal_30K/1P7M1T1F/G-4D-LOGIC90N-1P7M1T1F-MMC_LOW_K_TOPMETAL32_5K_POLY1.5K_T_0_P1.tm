 #
 #   initialize the infrastructure
 #
 if (!(isfuncdef techFindLayer)) {
    library (cat (getenv MGC_HOME) /pkgs/icxc/model_lib/ics.ma)
    techInit
 
    # NOTE: PLEASE DO NOT ALTER THE FOLLOWING FUNCTION
    func techGetVer {} {return v2005.4_14.17}
 
    #
    #   build a new technology.  note that the technology is attached
    #   to the global variable T
    #
    struct technology       T
 
    #
    #   add layers - order defined by profile
    #
    T = (buildTechnology G-4D-LOGIC90N-1P7M1T1F-MMC_LOW_K_TOPMETAL32_5K_POLY1.5K_T_0_P1 unconditional "ff" "2d" "mc2d")
    techSetIndie T "ON"
 }

untyped         L

# arguments:                             name   thick  type    diel  gds_layer)
# ------------------------- -----------------  ------  ----  ------  ---------

techAddLayer T ( buildLayer        field_base  1.0000    B   0.0000  0 )

techAddLayer T ( buildLayer   field_base_diel  0.4000    D   4.1000  0 )

techAddLayer T ( buildLayer               PLY  0.1500    C   0.0000  0 )
L = (techFindLayer T PLY)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.07 0.105 0.14 0.28)
} else {
   @L.widths = '(0.12)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T PLY spacings 0.17 0.2 0.97
   layerAddDimensions T PLY spacings 0.97 0.03 1
   layerAddDimensions T PLY spacings 1 1 5
} else {
   @L.spacings = '(0.2)
}
layerSetBias T PLY -0.01

techAddLayer T ( buildLayer              CONT  0.2600    V   0.0000  0 )
L = (techFindLayer T CONT)
@L.widths = '(0.1200)
@L.lengths = '(0.1200)
@L.spacings = '(0.1400)
@L.enclosures = '(0.0200)
@L.measured_from = "PLY"
@L.measured_to = "ME1"

techAddLayer T ( buildLayer          PLY_diel  0.0300    D   7.0000  0 )
layerSetPlanarity T PLY_diel "C"
layerSetHeight T PLY_diel "" 0.18
layerSetSWTHK T PLY_diel 0.03
layerSetSWSLOPE T PLY_diel 90.0

techAddLayer T ( buildLayer         PLY_diel2  0.3800    D   4.1000  0 )

techAddLayer T ( buildLayer               ME1  0.2200    C   0.0000  0 )
L = (techFindLayer T ME1)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.13 0.195 0.26 0.52)
} else {
   @L.widths = '(0.2)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME1 spacings 0.11 0.2 0.91
   layerAddDimensions T ME1 spacings 0.91 0.09 1
   layerAddDimensions T ME1 spacings 1 1 5
} else {
   @L.spacings = '(0.2)
}
layerSetIndie T ME1 actual_widths drawn_widths '(0.12 0.24 0.36 0.48)
layerSetIndie T ME1 actual_widths drawn_spacings '(0.12 0.24 0.36 0.48)
layerSetIndie T ME1 actual_widths indie_values '( \
	(0.13 0.1334 0.134 0.145) \
	(0.2082 0.2175 0.2165 0.217) \
	(0.3125 0.3287 0.325 0.3261) \
	(0.423 0.434 0.433 0.43))

layerSetIndie T ME1 actual_rho drawn_widths '(0.12 0.24 0.36 0.48)
layerSetIndie T ME1 actual_rho drawn_spacings '(0.12 0.24 0.36 0.48)
layerSetIndie T ME1 actual_rho indie_values '( \
	(0.12 0.118 0.12 0.104) \
	(0.136 0.128 0.128 0.128) \
	(0.127 0.121 0.122 0.122) \
	(0.127 0.122 0.122 0.122))

layerSetIndie T ME1 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m1_table"
layerSetIndie T ME1 indie_time "Aug 28 18:09:05 2006"
layerSetIndie T ME1 actual_thicknesses density1 0
layerSetIndie T ME1 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V1  0.3200    V   0.0000  0 )
L = (techFindLayer T V1)
@L.widths = '(0.1400)
@L.lengths = '(0.1400)
@L.spacings = '(0.1600)
@L.enclosures = '(0.0000)
@L.measured_from = "ME1"
@L.measured_to = "ME2"

techAddLayer T ( buildLayer          ME1_diel  -0.2000    D   4.1000  0 )

techAddLayer T ( buildLayer         ME1_diel2  0.0500    D   4.5000  0 )

techAddLayer T ( buildLayer         ME1_diel3  0.1200    D   2.9000  0 )

techAddLayer T ( buildLayer         ME1_diel4  0.0300    D   4.5000  0 )

techAddLayer T ( buildLayer         ME1_diel5  0.0500    D   7.0000  0 )

techAddLayer T ( buildLayer         ME1_diel6  0.2700    D   2.9000  0 )

techAddLayer T ( buildLayer               ME2  0.2500    C   0.0000  0 )
L = (techFindLayer T ME2)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.148 0.222 0.296 0.592)
} else {
   @L.widths = '(0.2)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME2 spacings 0.132 0.2 0.932
   layerAddDimensions T ME2 spacings 0.932 0.068 1
   layerAddDimensions T ME2 spacings 1 1 5
} else {
   @L.spacings = '(0.2)
}
layerSetIndie T ME2 actual_widths drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME2 actual_widths drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME2 actual_widths indie_values '( \
	(0.148 0.165 0.164 0.164) \
	(0.2555 0.273 0.273 0.273) \
	(0.38 0.408 0.408 0.408) \
	(0.52 0.544 0.544 0.544))

layerSetIndie T ME2 actual_rho drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME2 actual_rho drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME2 actual_rho indie_values '( \
	(0.115 0.102 0.102 0.102) \
	(0.121 0.112 0.112 0.112) \
	(0.119 0.109 0.11 0.111) \
	(0.113 0.107 0.108 0.109))

layerSetIndie T ME2 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m2_table"
layerSetIndie T ME2 indie_time "Aug 28 15:04:12 2006"
layerSetIndie T ME2 actual_thicknesses density1 0
layerSetIndie T ME2 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V2  0.3200    V   0.0000  0 )
L = (techFindLayer T V2)
@L.widths = '(0.1400)
@L.lengths = '(0.1400)
@L.spacings = '(0.1600)
@L.enclosures = '(0.0000)
@L.measured_from = "ME2"
@L.measured_to = "ME3"

techAddLayer T ( buildLayer          ME2_diel  -0.0300    D   2.9000  0 )

techAddLayer T ( buildLayer         ME2_diel2  0.0300    D   4.1000  0 )

techAddLayer T ( buildLayer         ME2_diel3  0.0500    D   7.0000  0 )

techAddLayer T ( buildLayer         ME2_diel4  0.2700    D   2.9000  0 )

techAddLayer T ( buildLayer               ME3  0.2500    C   0.0000  0 )
L = (techFindLayer T ME3)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.148 0.222 0.296 0.592)
} else {
   @L.widths = '(0.2)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME3 spacings 0.132 0.2 0.932
   layerAddDimensions T ME3 spacings 0.932 0.068 1
   layerAddDimensions T ME3 spacings 1 1 5
} else {
   @L.spacings = '(0.2)
}
layerSetIndie T ME3 actual_widths drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME3 actual_widths drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME3 actual_widths indie_values '( \
	(0.148 0.165 0.164 0.164) \
	(0.2555 0.273 0.273 0.273) \
	(0.38 0.408 0.408 0.408) \
	(0.52 0.544 0.544 0.544))

layerSetIndie T ME3 actual_rho drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME3 actual_rho drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME3 actual_rho indie_values '( \
	(0.115 0.102 0.102 0.102) \
	(0.121 0.112 0.112 0.112) \
	(0.119 0.109 0.11 0.111) \
	(0.113 0.107 0.108 0.109))

layerSetIndie T ME3 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m3_table"
layerSetIndie T ME3 indie_time "Aug 28 18:11:16 2006"
layerSetIndie T ME3 actual_thicknesses density1 0
layerSetIndie T ME3 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V3  0.3200    V   0.0000  0 )
L = (techFindLayer T V3)
@L.widths = '(0.1400)
@L.lengths = '(0.1400)
@L.spacings = '(0.1600)
@L.enclosures = '(0.0000)
@L.measured_from = "ME3"
@L.measured_to = "ME4"

techAddLayer T ( buildLayer          ME3_diel  -0.0300    D   2.9000  0 )

techAddLayer T ( buildLayer         ME3_diel2  0.0300    D   4.1000  0 )

techAddLayer T ( buildLayer         ME3_diel3  0.0500    D   7.0000  0 )

techAddLayer T ( buildLayer         ME3_diel4  0.2700    D   2.9000  0 )

techAddLayer T ( buildLayer               ME4  0.2500    C   0.0000  0 )
L = (techFindLayer T ME4)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.148 0.222 0.296 0.592)
} else {
   @L.widths = '(0.2)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME4 spacings 0.132 0.2 0.932
   layerAddDimensions T ME4 spacings 0.932 0.068 1
   layerAddDimensions T ME4 spacings 1 1 5
} else {
   @L.spacings = '(0.2)
}
layerSetIndie T ME4 actual_widths drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME4 actual_widths drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME4 actual_widths indie_values '( \
	(0.148 0.165 0.164 0.164) \
	(0.2555 0.273 0.273 0.273) \
	(0.38 0.408 0.408 0.408) \
	(0.52 0.544 0.544 0.544))

layerSetIndie T ME4 actual_rho drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME4 actual_rho drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME4 actual_rho indie_values '( \
	(0.115 0.102 0.102 0.102) \
	(0.121 0.112 0.112 0.112) \
	(0.119 0.109 0.11 0.111) \
	(0.113 0.107 0.108 0.109))

layerSetIndie T ME4 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m4_table"
layerSetIndie T ME4 indie_time "Aug 28 18:11:25 2006"
layerSetIndie T ME4 actual_thicknesses density1 0
layerSetIndie T ME4 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V4  0.3200    V   0.0000  0 )
L = (techFindLayer T V4)
@L.widths = '(0.1400)
@L.lengths = '(0.1400)
@L.spacings = '(0.1600)
@L.enclosures = '(0.0000)
@L.measured_from = "ME4"
@L.measured_to = "ME5"

techAddLayer T ( buildLayer          ME4_diel  -0.0300    D   2.9000  0 )

techAddLayer T ( buildLayer         ME4_diel2  0.0300    D   4.1000  0 )

techAddLayer T ( buildLayer         ME4_diel3  0.0500    D   7.0000  0 )

techAddLayer T ( buildLayer         ME4_diel4  0.2700    D   2.9000  0 )

techAddLayer T ( buildLayer               ME5  0.2500    C   0.0000  0 )
L = (techFindLayer T ME5)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.148 0.222 0.296 0.592)
} else {
   @L.widths = '(0.16)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME5 spacings 0.132 0.2 0.932
   layerAddDimensions T ME5 spacings 0.932 0.068 1
   layerAddDimensions T ME5 spacings 1 1 5
} else {
   @L.spacings = '(0.12)
}
layerSetIndie T ME5 actual_widths drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME5 actual_widths drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME5 actual_widths indie_values '( \
	(0.148 0.165 0.164 0.164) \
	(0.2555 0.273 0.273 0.273) \
	(0.38 0.408 0.408 0.408) \
	(0.52 0.544 0.544 0.544))

layerSetIndie T ME5 actual_rho drawn_widths '(0.14 0.28 0.42 0.56)
layerSetIndie T ME5 actual_rho drawn_spacings '(0.14 0.28 0.42 0.56)
layerSetIndie T ME5 actual_rho indie_values '( \
	(0.115 0.102 0.102 0.102) \
	(0.121 0.112 0.112 0.112) \
	(0.119 0.109 0.11 0.111) \
	(0.113 0.107 0.108 0.109))

layerSetIndie T ME5 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m5_table"
layerSetIndie T ME5 indie_time "Aug 28 18:11:32 2006"
layerSetIndie T ME5 actual_thicknesses density1 0
layerSetIndie T ME5 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V5  0.6450    V   0.0000  0 )
L = (techFindLayer T V5)
@L.widths = '(0.2800)
@L.lengths = '(0.2800)
@L.spacings = '(0.2800)
@L.enclosures = '(0.0000)
@L.measured_from = "ME5"
@L.measured_to = "ME6"

techAddLayer T ( buildLayer          ME5_diel  -0.0300    D   2.9000  0 )

techAddLayer T ( buildLayer         ME5_diel2  0.0300    D   4.1000  0 )

techAddLayer T ( buildLayer         ME5_diel3  0.0500    D   7.0000  0 )

techAddLayer T ( buildLayer         ME5_diel4  0.0350    D   7.0000  0 )

techAddLayer T ( buildLayer         ME5_diel5  0.0200    D   3.7000  0 )

techAddLayer T ( buildLayer           MMCBP_C  0.1100    C   0.0000  0 )
L = (techFindLayer T MMCBP_C)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(1.0 1.5 2.0 4.0)
} else {
   @L.widths = '(1)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T MMCBP_C spacings 0.8 0.2 1.2
   layerAddDimensions T MMCBP_C spacings 1.2 0.2 1.3
   layerAddDimensions T MMCBP_C spacings 1.3 1 4.3
} else {
   @L.spacings = '(0.8)
}

techAddLayer T ( buildLayer      MMCBP_C_diel  0.0000    D   7.0000  0 )
layerSetPlanarity T MMCBP_C_diel "C"
layerSetHeight T MMCBP_C_diel "" 0.11
layerSetSWTHK T MMCBP_C_diel 0.035
layerSetSWSLOPE T MMCBP_C_diel 90.0

techAddLayer T ( buildLayer     MMCBP_C_diel2  0.0000    D   4.1000  0 )
layerSetPlanarity T MMCBP_C_diel2 "C"
layerSetHeight T MMCBP_C_diel2 "" 0.12
layerSetSWTHK T MMCBP_C_diel2 0.0
layerSetSWSLOPE T MMCBP_C_diel2 90.0

techAddLayer T ( buildLayer     MMCBP_C_diel3  0.0000    D   7.0000  0 )
layerSetPlanarity T MMCBP_C_diel3 "C"
layerSetHeight T MMCBP_C_diel3 "" 0.133
layerSetSWTHK T MMCBP_C_diel3 0.0
layerSetSWSLOPE T MMCBP_C_diel3 90.0

techAddLayer T ( buildLayer     MMCBP_C_diel4  0.0000    D   4.1000  0 )
layerSetPlanarity T MMCBP_C_diel4 "C"
layerSetHeight T MMCBP_C_diel4 "" 0.143
layerSetSWTHK T MMCBP_C_diel4 0.0
layerSetSWSLOPE T MMCBP_C_diel4 90.0

techAddLayer T ( buildLayer     MMCBP_C_diel5  0.1430    D   3.7000  0 )

techAddLayer T ( buildLayer           MMCTP_C  0.0600    C   0.0000  0 )
L = (techFindLayer T MMCTP_C)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(1.0 1.5 2.0 4.0)
} else {
   @L.widths = '(1)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T MMCTP_C spacings 0.8 0.2 1.2
   layerAddDimensions T MMCTP_C spacings 1.2 0.2 1.3
   layerAddDimensions T MMCTP_C spacings 1.3 1 4.3
} else {
   @L.spacings = '(0.8)
}

techAddLayer T ( buildLayer      MMCTP_C_diel  0.0000    D   7.0000  0 )
layerSetPlanarity T MMCTP_C_diel "C"
layerSetHeight T MMCTP_C_diel "" 0.159
layerSetSWTHK T MMCTP_C_diel 0.094
layerSetSWSLOPE T MMCTP_C_diel 90.0

techAddLayer T ( buildLayer     MMCTP_C_diel2  0.3970    D   3.7000  0 )

techAddLayer T ( buildLayer               ME6  0.5000    C   0.0000  0 )
L = (techFindLayer T ME6)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.3205 0.48075 0.641 1.282)
} else {
   @L.widths = '(0.28)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME6 spacings 0.2395 0.2 0.8395
   layerAddDimensions T ME6 spacings 0.8395 0.2 0.9395
   layerAddDimensions T ME6 spacings 0.9395 0.0605 1
   layerAddDimensions T ME6 spacings 1 1 5
} else {
   @L.spacings = '(0.28)
}
layerSetIndie T ME6 actual_widths drawn_widths '(0.28 0.56 0.84 1.12)
layerSetIndie T ME6 actual_widths drawn_spacings '(0.28 0.56 0.84 1.12)
layerSetIndie T ME6 actual_widths indie_values '( \
	(0.3205 0.321 0.321 0.321) \
	(0.559 0.5874 0.587 0.587) \
	(0.833 0.867 0.867 0.867) \
	(1.1161 1.147 1.147 1.147))

layerSetIndie T ME6 actual_rho drawn_widths '(0.28 0.56 0.84 1.12)
layerSetIndie T ME6 actual_rho drawn_spacings '(0.28 0.56 0.84 1.12)
layerSetIndie T ME6 actual_rho indie_values '( \
	(0.044 0.044 0.044 0.045) \
	(0.048 0.048 0.048 0.048) \
	(0.047 0.047 0.047 0.047) \
	(0.046 0.046 0.046 0.046))

layerSetIndie T ME6 indie_path "/Project/lvslpe/kazumi/XRC_LPE/90N/LOGIC_MIXED_MODE90N-1P9M-LOWK/1P7M1T1F/4G-T.0_P1/m6_table"
layerSetIndie T ME6 indie_time "Aug 28 18:14:30 2006"
layerSetIndie T ME6 actual_thicknesses density1 0
layerSetIndie T ME6 actual_thicknesses density2 0


techAddLayer T ( buildLayer                V6  0.5850    V   0.0000  0 )
L = (techFindLayer T V6)
@L.widths = '(0.5600)
@L.lengths = '(0.5600)
@L.spacings = '(0.5600)
@L.enclosures = '(0.0000)
@L.measured_from = "ME6"
@L.measured_to = "ME7"

techAddLayer T ( buildLayer          ME6_diel  -0.4400    D   5.0000  0 )

techAddLayer T ( buildLayer         ME6_diel2  0.4400    D   3.7000  0 )

techAddLayer T ( buildLayer         ME6_diel3  0.0850    D   7.0000  0 )

techAddLayer T ( buildLayer         ME6_diel4  0.5000    D   3.7000  0 )

techAddLayer T ( buildLayer               ME7  3.2500    C   0.0000  0 )
L = (techFindLayer T ME7)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(2.0 3.0 4.0 8.0)
} else {
   @L.widths = '(0.56)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T ME7 spacings 2 0.2 2.4
   layerAddDimensions T ME7 spacings 2.4 0.2 2.5
   layerAddDimensions T ME7 spacings 2.5 1 4.5
} else {
   @L.spacings = '(0.56)
}

techAddLayer T ( buildLayer               TMV  1.2700    V   0.0000  0 )
L = (techFindLayer T TMV)
@L.widths = '(4.0000)
@L.lengths = '(4.0000)
@L.spacings = '(2.0000)
@L.enclosures = '(0.5000)
@L.measured_from = "ME7"
@L.measured_to = "AL_RDL_C"

techAddLayer T ( buildLayer          ME7_diel  -3.0500    D   5.0000  0 )

techAddLayer T ( buildLayer         ME7_diel2  3.2500    D   3.7000  0 )

techAddLayer T ( buildLayer         ME7_diel3  0.0700    D   7.0000  0 )

techAddLayer T ( buildLayer         ME7_diel4  1.0000    D   4.1000  0 )

techAddLayer T ( buildLayer          AL_RDL_C  1.2000    C   0.0000  0 )
L = (techFindLayer T AL_RDL_C)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(3.0 4.5 6.0 12.0)
} else {
   @L.widths = '(3)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T AL_RDL_C spacings 1.6 0.2 2
   layerAddDimensions T AL_RDL_C spacings 2 0.2 2.1
   layerAddDimensions T AL_RDL_C spacings 2.1 1 4.1
} else {
   @L.spacings = '(1.6)
}

techAddLayer T ( buildLayer     AL_RDL_C_diel  0.4000    D   4.1000  0 )
layerSetPlanarity T AL_RDL_C_diel "C"
layerSetHeight T AL_RDL_C_diel "" 1.2
layerSetSWTHK T AL_RDL_C_diel 0.4
layerSetSWSLOPE T AL_RDL_C_diel 90.0

techAddLayer T ( buildLayer    AL_RDL_C_diel2  0.5000    D   7.0000  0 )
layerSetPlanarity T AL_RDL_C_diel2 "C"
layerSetHeight T AL_RDL_C_diel2 "" 1.3
layerSetSWTHK T AL_RDL_C_diel2 0.5
layerSetSWSLOPE T AL_RDL_C_diel2 90.0

techAddLayer T ( buildLayer       active_base  1.0000    B   0.0000  0 )

techAddLayer T ( buildLayer  active_base_diel  0.0300    D   7.0000  0 )

techAddLayer T ( buildLayer active_base_diel2  0.3800    D   4.1000  0 )

techAddLayer T ( buildLayer       sdcont_base  1.0000    B   0.0000  0 )

techAddLayer T ( buildLayer  sdcont_base_diel  0.2800    D   4.1000  0 )

techAddLayer T ( buildLayer              diff  0.1000    C   0.0000  0 )
L = (techFindLayer T diff)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.12 0.18 0.24 0.48)
} else {
   @L.widths = '(0.12)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T diff spacings 0.14 0.2 0.94
   layerAddDimensions T diff spacings 0.94 0.06 1
   layerAddDimensions T diff spacings 1 1 5
} else {
   @L.spacings = '(0.14)
}

techAddLayer T ( buildLayer            diffco  0.4300    V   0.0000  0 )
L = (techFindLayer T diffco)
@L.widths = '(0.1200)
@L.lengths = '(0.1200)
@L.spacings = '(0.1400)
@L.enclosures = '(0.0000)
@L.measured_from = "diff"
@L.measured_to = "ME1"
@L.min_cond_spacing = 0.0800

techAddLayer T ( buildLayer         diff_diel  0.0200    D   4.1000  0 )

techAddLayer T ( buildLayer      diffcap_base  0.0000    B   0.0000  0 )

techAddLayer T ( buildLayer diffcap_base_diel  0.0000    D   4.1000  0 )

techAddLayer T ( buildLayer             diff2  0.1000    C   0.0000  0 )
L = (techFindLayer T diff2)
if ((techGetMode T) == "calibrate") {
   @L.widths = '(0.12 0.18 0.24 0.48)
} else {
   @L.widths = '(0.12)
}
if ((techGetMode T) == "calibrate") {
   @L.lengths = '(1.0)
} else {
   @L.lengths = '(100.00)
}
if ((techGetMode T) == "calibrate") {
   layerSetDimensions T diff2 spacings 0.14 0.2 0.94
   layerAddDimensions T diff2 spacings 0.94 0.06 1
   layerAddDimensions T diff2 spacings 1 1 5
} else {
   @L.spacings = '(0.14)
}

techAddLayer T ( buildLayer        diff2_diel  0.0000    D   12.0000  0 )
layerSetPlanarity T diff2_diel "C"
layerSetHeight T diff2_diel "" -0.4
layerSetSWTHK T diff2_diel 0.0

techAddLayer T ( buildLayer       diff2_diel2  0.0020    D   4.1000  0 )

techSetLayerProfile T ME1 field
techSetLayerProfile T ME1_diel field
techSetLayerProfile T ME1_diel2 field
techSetLayerProfile T ME1_diel3 field
techSetLayerProfile T ME1_diel4 field
techSetLayerProfile T ME1_diel5 field
techSetLayerProfile T ME1_diel6 field
techSetLayerProfile T ME2 field
techSetLayerProfile T ME2_diel field
techSetLayerProfile T ME2_diel2 field
techSetLayerProfile T ME2_diel3 field
techSetLayerProfile T ME2_diel4 field
techSetLayerProfile T ME3 field
techSetLayerProfile T ME3_diel field
techSetLayerProfile T ME3_diel2 field
techSetLayerProfile T ME3_diel3 field
techSetLayerProfile T ME3_diel4 field
techSetLayerProfile T ME4 field
techSetLayerProfile T ME4_diel field
techSetLayerProfile T ME4_diel2 field
techSetLayerProfile T ME4_diel3 field
techSetLayerProfile T ME4_diel4 field
techSetLayerProfile T ME5 field
techSetLayerProfile T ME5_diel field
techSetLayerProfile T ME5_diel2 field
techSetLayerProfile T ME5_diel3 field
techSetLayerProfile T ME5_diel4 field
techSetLayerProfile T ME5_diel5 field
techSetLayerProfile T MMCBP_C field
techSetLayerProfile T MMCBP_C_diel field
techSetLayerProfile T MMCBP_C_diel2 field
techSetLayerProfile T MMCBP_C_diel3 field
techSetLayerProfile T MMCBP_C_diel4 field
techSetLayerProfile T MMCBP_C_diel5 field
techSetLayerProfile T MMCTP_C field
techSetLayerProfile T MMCTP_C_diel field
techSetLayerProfile T MMCTP_C_diel2 field
techSetLayerProfile T ME6 field
techSetLayerProfile T ME6_diel field
techSetLayerProfile T ME6_diel2 field
techSetLayerProfile T ME6_diel3 field
techSetLayerProfile T ME6_diel4 field
techSetLayerProfile T ME7 field
techSetLayerProfile T ME7_diel field
techSetLayerProfile T ME7_diel2 field
techSetLayerProfile T ME7_diel3 field
techSetLayerProfile T ME7_diel4 field
techSetLayerProfile T AL_RDL_C field
techSetLayerProfile T AL_RDL_C_diel field
techSetLayerProfile T AL_RDL_C_diel2 field
techSetLayerProfile T PLY field
techSetLayerProfile T PLY_diel field
techSetLayerProfile T PLY_diel2 field

techAddProfile T (buildProfile field field_base \
   '( field_base_diel PLY CONT PLY_diel PLY_diel2 ME1 V1 ME1_diel ME1_diel2 ME1_diel3 ME1_diel4 ME1_diel5 ME1_diel6 ME2 V2 ME2_diel ME2_diel2 ME2_diel3 ME2_diel4 ME3 V3 ME3_diel ME3_diel2 ME3_diel3 ME3_diel4 ME4 V4 ME4_diel ME4_diel2 ME4_diel3 ME4_diel4 ME5 V5 ME5_diel ME5_diel2 ME5_diel3 ME5_diel4 ME5_diel5 MMCBP_C MMCBP_C_diel MMCBP_C_diel2 MMCBP_C_diel3 MMCBP_C_diel4 MMCBP_C_diel5 MMCTP_C MMCTP_C_diel MMCTP_C_diel2 ME6 V6 ME6_diel ME6_diel2 ME6_diel3 ME6_diel4 ME7 TMV ME7_diel ME7_diel2 ME7_diel3 ME7_diel4 AL_RDL_C AL_RDL_C_diel AL_RDL_C_diel2 ) \
   '( ) \
   '( ) \
   '( ) \
 )

techAddProfile T (buildProfile active active_base \
   '( active_base_diel active_base_diel2 ME1 ME1_diel ME1_diel2 ME1_diel3 ME1_diel4 ME1_diel5 ME1_diel6 ME2 ME2_diel ME2_diel2 ME2_diel3 ME2_diel4 ME3 ME3_diel ME3_diel2 ME3_diel3 ME3_diel4 ME4 ME4_diel ME4_diel2 ME4_diel3 ME4_diel4 ME5 ME5_diel ME5_diel2 ME5_diel3 ME5_diel4 ME5_diel5 MMCBP_C MMCBP_C_diel MMCBP_C_diel2 MMCBP_C_diel3 MMCBP_C_diel4 MMCBP_C_diel5 MMCTP_C MMCTP_C_diel MMCTP_C_diel2 ME6 ME6_diel ME6_diel2 ME6_diel3 ME6_diel4 ME7 ME7_diel ME7_diel2 ME7_diel3 ME7_diel4 AL_RDL_C AL_RDL_C_diel AL_RDL_C_diel2 ) \
   '( ) \
   '( ) \
   '( NSD PSD ) \
 )

techAddProfile T (buildProfile sdcont sdcont_base \
   '( sdcont_base_diel diff diffco diff_diel PLY PLY_diel PLY_diel2 ME1 ME1_diel ME1_diel2 ME1_diel3 ME1_diel4 ME1_diel5 ME1_diel6 ME2 ME2_diel ME2_diel2 ME2_diel3 ME2_diel4 ME3 ME3_diel ME3_diel2 ME3_diel3 ME3_diel4 ME4 ME4_diel ME4_diel2 ME4_diel3 ME4_diel4 ME5 ME5_diel ME5_diel2 ME5_diel3 ME5_diel4 ME5_diel5 MMCBP_C MMCBP_C_diel MMCBP_C_diel2 MMCBP_C_diel3 MMCBP_C_diel4 MMCBP_C_diel5 MMCTP_C MMCTP_C_diel MMCTP_C_diel2 ME6 ME6_diel ME6_diel2 ME6_diel3 ME6_diel4 ME7 ME7_diel ME7_diel2 ME7_diel3 ME7_diel4 AL_RDL_C AL_RDL_C_diel AL_RDL_C_diel2 ) \
   '( ) \
   '( diff ) \
   '( NSD PSD ) \
 )

techAddProfile T (buildProfile diffcap diffcap_base \
   '( diffcap_base_diel diff2 diff2_diel diff2_diel2 PLY PLY_diel PLY_diel2 ME1 ME1_diel ME1_diel2 ME1_diel3 ME1_diel4 ME1_diel5 ME1_diel6 ME2 ME2_diel ME2_diel2 ME2_diel3 ME2_diel4 ME3 ME3_diel ME3_diel2 ME3_diel3 ME3_diel4 ME4 ME4_diel ME4_diel2 ME4_diel3 ME4_diel4 ME5 ME5_diel ME5_diel2 ME5_diel3 ME5_diel4 ME5_diel5 MMCBP_C MMCBP_C_diel MMCBP_C_diel2 MMCBP_C_diel3 MMCBP_C_diel4 MMCBP_C_diel5 MMCTP_C MMCTP_C_diel MMCTP_C_diel2 ME6 ME6_diel ME6_diel2 ME6_diel3 ME6_diel4 ME7 ME7_diel ME7_diel2 ME7_diel3 ME7_diel4 AL_RDL_C AL_RDL_C_diel AL_RDL_C_diel2 ) \
   '( ) \
   '( diff2 ) \
   '( NSD PSD ) \
 )

