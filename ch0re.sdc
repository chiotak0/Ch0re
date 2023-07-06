###################################################################

## timing contstraints

# 1000 MHz -> 1ns
create_clock [get_ports clk] -period 10
# 500 MHz -> 2ns
#create_clock [get_ports clk]  -period 2  -waveform {0 1}
#set_clock_uncertainty 0.3  [get_clocks clk]

#set_propagated_clock [get_clocks clk]

#set_clock_transition -rise 0.2 [get_clocks clk]
#set_clock_transition -fall 0.2 [get_clocks clk]

#set_input_delay -clock clk 0.1  [get_ports r]

#set_output_delay -clock clk 0.15  [get_ports {out[*]}]
##set_output_delay -clock clk  1.0  [get_ports {out[7]}]
##set_output_delay -clock clk  1.0  [get_ports {out[6]}]
##set_output_delay -clock clk  1.0  [get_ports {out[5]}]
##set_output_delay -clock clk  1.0  [get_ports {out[4]}]
##set_output_delay -clock clk  1.0  [get_ports {out[3]}]
##set_output_delay -clock clk  1.0  [get_ports {out[2]}]
##set_output_delay -clock clk  1.0  [get_ports {out[1]}]
##set_output_delay -clock clk  1.0  [get_ports {out[0]}]

#set_driving_cell -lib_cell SAEDRVT14_BUF_16 -pin X [get_ports clk]
#set_driving_cell -lib_cell SAEDRVT14_FDPQ_V2_1 -pin Q [get_ports r]

#set_load -pin_load 0.004 [get_ports {out[*]}]
##set_load -pin_load 0.004 [get_ports {out[7]}]
##set_load -pin_load 0.004 [get_ports {out[6]}]
##set_load -pin_load 0.004 [get_ports {out[5]}]
##set_load -pin_load 0.004 [get_ports {out[4]}]
##set_load -pin_load 0.004 [get_ports {out[3]}]
##set_load -pin_load 0.004 [get_ports {out[2]}]
##set_load -pin_load 0.004 [get_ports {out[1]}]
##set_load -pin_load 0.004 [get_ports {out[0]}]
