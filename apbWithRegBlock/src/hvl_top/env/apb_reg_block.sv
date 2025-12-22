`ifndef APB_REG_BLOCK
`define APB_REG_BLOCK 


class apb_reg_block extends uvm_reg_block;

  `uvm_object_utils(apb_reg_block)
  apb_dummy_reg reg0;
  uvm_reg_map bus_map;

  extern function new(string name = "apb_reg_block");
  extern virtual function void build ();

endclass 


function apb_reg_block::new( string name = "apb_reg_block");
  super.new(name,UVM_NO_COVERAGE);
endfunction 

function void apb_reg_block :: build();
  reg0 = apb_dummy_reg :: type_id :: create("reg0");
  reg0.configure(this);
  reg0.build();
  bus_map = create_map("bus_map",'h100,4,UVM_LITTLE_ENDIAN);
  default_map = bus_map; // can have multiple maps 
  bus_map.add_reg(reg0,'h4,"RW");
  lock_model();
endfunction 
`endif
