`ifndef APB_REG_ADAPTER

`define APB_REG_ADAPTER

class apb_reg_adapter extends uvm_reg_adapter;
`uvm_object_utils(apb_reg_adapter);

  extern function new(string name = "apb_reg_adapter");
  extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  extern virtual function void bus2reg(uvm_sequence_item,ref uvm_reg_bus_op rw);
endclass

function apb_reg_adapter :: new (string name ="apb_reg_adapter"); 
  super.new(name);
endfunction 

function uvm_sequence_item apb_reg_adapter::reg2bus(const ref uvm_reg_bus_op rw);
  apb_master_tx bus = apb_master_tx :: type_id :: create("apb_master_tx");
   $display("THE ADDRESS IS %0d",rw.addr);
   bus.paddr = rw.addr;
   bus.pwrite = tx_type_e'((rw.kind ==UVM_READ) ? 0: 1);
   $display("TEH DAYA IS %0d",rw.data);
   bus.pwdata = rw.data;
   bus.pstrb = {(DATA_WIDTH/8){1'b1}};
   return bus;

endfunction 

function void apb_reg_adapter :: bus2reg (uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
  apb_master_tx bus;
  if(!$cast(bus,bus_item)) 
    `uvm_fatal(get_type_name(),"provided bus is wrong type")
  rw.kind = (bus.pwrite == 0) ? UVM_WRITE : UVM_READ;
  rw.addr = bus.paddr;
  rw.data = bus.pwdata;
  rw.status = UVM_IS_OK;
endfunction 

`endif

