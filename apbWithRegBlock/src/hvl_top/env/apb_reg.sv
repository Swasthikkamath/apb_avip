`ifndef APB_DUMMY_REG
`define APB_DUMMY_REG

class apb_dummy_reg extends uvm_reg;
  `uvm_object_utils(apb_dummy_reg)
  rand uvm_reg_field dummy_field;
  extern function new(string name = "apb_dummy_reg");
  extern virtual function void build();

endclass : apb_dummy_reg
 
function apb_dummy_reg :: new(string name = "apb_dummy_reg");
  super.new(name,32,UVM_NO_COVERAGE);
endfunction 

function void apb_dummy_reg :: build();
  dummy_field = uvm_reg_field :: type_id :: create("dummy_field");
  dummy_field.configure(this,32,0,"RW",1,32'h0,1,1,1);
endfunction 

`endif
