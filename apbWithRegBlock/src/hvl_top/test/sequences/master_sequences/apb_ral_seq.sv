`ifndef APB_RAL_SEQ
`define APB_RAL_SEQ 

class apb_ral_seq extends apb_master_base_seq;
`uvm_object_utils(apb_ral_seq)

 int a;

extern function new (string name = "apb_ral_seq");
extern virtual task body();

endclass
 

function apb_ral_seq ::new(string name = "apb_ral_seq");
  super.new(name);
endfunction 

task apb_ral_seq :: body();
  super.body();
  `ifdef USE_RAL
     env_config.reg_block.reg0.write(status ,.value('h 616),.parent(this));
     env_config.reg_block.reg0.read(status,.value(a),.parent(this));
     $display("THE STATUS IS %s",status);
     #1000;
  `endif
 endtask

`endif

