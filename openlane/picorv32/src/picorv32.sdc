set_units -time ns
create_clock [get_ports clk]  -name core_clock  -period $::env(CLOCK_PERIOD) 

# Clock non-idealities
set_propagated_clock [all_clocks]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINTY) [get_clocks {core_clock}]

set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks {core_clock}]

# Maximum transition time for the design nets
set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]

# Maximum fanout
set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]


# Reset input delay
set_input_delay [expr $::env(CLOCK_PERIOD) * 0.5] -clock [get_clocks {core_clock}] [get_ports {resetn}]


# Get all inputs except for clock
#set all_inputs_ex_clk [remove_from_collection \
[all_inputs] [all_clocks]]

set all_inputs_ex_clk "mem_ready mem_rdata irq"

### Set I/O delay for all in/outputs, excluding Clk port
# Input delay
set_input_delay -max 1.5 -clock [get_clocks {core_clock}] $all_inputs_ex_clk
# Output delay
set_output_delay -max 1 -clock [get_clocks {core_clock}] [all_outputs]

# Output loads
set_load 0.19 [all_outputs]
