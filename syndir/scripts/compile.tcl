set DESIGN_NAME         "ch0re_pipeline"

# these can be also set in .synopsys_dc.setup file in working directory
# always keep the asterisk in link_library
set target_library  {  /eda/tech-libs/SAED14/EDK/lib/stdcell_rvt/db_nldm/saed14rvt_tt0p8v25c.db /eda/tech-libs/SAED14/EDK/lib/sram/logic_synth/single/saed14sram_tt0p8v25c.db }
set link_library    {* /eda/tech-libs/SAED14/EDK/lib/stdcell_rvt/db_nldm/saed14rvt_tt0p8v25c.db /eda/tech-libs/SAED14/EDK/lib/sram/logic_synth/single/saed14sram_tt0p8v25c.db }

 
#../memory_models/mem_sync_sp_syn14/saed14sram.v

set svfiles {\
 ../ch0re_types.sv\
 ../memory_models/regfile_2r1w/regfile_2r1w.sv\
 ../memory_models/mem_sync_sp_syn14/mem_sync_sp_syn.sv\
 ../pipeline/alu/ch0re_alu.sv\
 ../pipeline/decoder/ch0re_idecoder.sv\
 ../pipeline/ch0re_pipeline.sv\
}

#../pipeline/ch0re_pipeline.sv

# Analyze
analyze -format sverilog ${svfiles}
#read_file ../pipeline/ch0re_pipeline.sv -define SIM -format sverilog

# Elaborate
elaborate ${DESIGN_NAME}

#Set current design
current_design ${DESIGN_NAME}


link
check_design

read_sdc ../ch0re.sdc
compile -exact_map > compile.log

report_constraint > results/rpt.constraints.report
report_timing > results/rpt.timing.report
report_qor > results/rpt.qor.report
report_area -hierarchy > results/rpt.area.report
report_power -hierarchy > results/rpt.power.report

change_names -rule verilog
write -hierarchy -format verilog -output results/ch0re.synthesis.v
write -hierarchy -format ddc  -output results/ch0re.synthesis.ddc

exit
