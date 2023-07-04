set DESIGN_NAME        "ch0re_pipeline"                 ; # set design name
set SRC_DIR            "[pwd]/../pipeline"                ; # Get current working directory

# these can be also set in .synopsys_dc.setup file in working directory
# always keep the asterisk in link_library
set target_library  {  /eda/tech-libs/SAED14/EDK/lib/stdcell_rvt/db_nldm/saed14rvt_tt0p8v25c.db /eda/tech-libs/SAED14/EDK/lib/sram/logic_synth/single/saed14sram_tt0p8v25c.db }
set link_library    {* /eda/tech-libs/SAED14/EDK/lib/stdcell_rvt/db_nldm/saed14rvt_tt0p8v25c.db /eda/tech-libs/SAED14/EDK/lib/sram/logic_synth/single/saed14sram_tt0p8v25c.db }

#read_verilog  ../source/johnson.v

## read command can be replaced with:
# Analyze
analyze -format sverilog [glob ${SRC_DIR}/*.sv]
# Elaborate
elaborate ${DESIGN_NAME}

#Set current design
current_design ${DESIGN_NAME}

link
check_design

read_sdc ${SRC_DIR}/corvus.sdc		
compile -exact_map > compile.log

report_constraint > ../results/rpt.constraints.report
report_timing > ../results/rpt.timing.report
report_qor > ../results/rpt.qor.report
report_area -hierarchy > ../results/rpt.area.report
report_power -hierarchy > ../results/rpt.power.report

change_names -rule verilog
write -hierarchy -format verilog -output ../results/johnson.synthesis.v
write -hierarchy -format ddc  -output ../results/johnson.synthesis.ddc

exit
