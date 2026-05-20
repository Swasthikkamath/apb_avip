#Set the design top in a variable
set top apb_slave

# enable witness trace for property 
#set_fml_var fml_witness_on true


# Compilation
# single step analyze + elaborate
read_file -top $top -format sverilog -sva -vcs {-f ../apbFormalCompile.flist}


create_clock PCLK -period 100 -initial 0
create_reset PRESETn -low

# define the reset and active level - here it is active low

#Setup grid
#set_grid_usage -type RTDA=12 -control { nc run -wl -ep -r redhat x86_64 RAM/32000}
sim_force PRESETn -apply 0

sim_run 2

sim_force PRESETn -apply 1 

fvassume -expr {PENABLE inside {0,1}}
fvassume -expr {PSEL inside {0,1}}
#fvassume -expr {full inside {0, 1}}
#fvassume -expr {empty inside {0, 1}}

# 2. Ensure your TB logic doesn't see 'X' on flow_has_data
# fvassume -expr {flow_has_data != 'x}
sim_run -stable

sim_save_reset
#
#check_fv
#
