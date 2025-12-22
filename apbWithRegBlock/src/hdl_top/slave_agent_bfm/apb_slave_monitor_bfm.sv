`ifndef APB_SLAVE_MONITOR_BFM_INCLUDED_
`define APB_SLAVE_MONITOR_BFM_INCLUDED_

//-------------------------------------------------------
// Importing apb global package
//-------------------------------------------------------
import apb_global_pkg::*;

//--------------------------------------------------------------------------------------------
// Inteface: apb_slave_monitor_bfm
//  Connects the slave monitor bfm with the monitor proxy 
//  to call the tasks and functions from apb monitor bfm to apb monitor proxy
//--------------------------------------------------------------------------------------------
interface apb_slave_monitor_bfm (input bit pclk,
                                 input bit preset_n,
                                 input logic psel,
                                 input bit [2:0]pprot,
                                 input bit pslverr,
                                 input bit pready,
                                 input logic penable,
                                 input logic pwrite,
                                 input logic [ADDRESS_WIDTH-1:0]paddr,
                                 input logic [DATA_WIDTH-1:0]pwdata,
                                 input logic [(DATA_WIDTH/8)-1:0]pstrb, 
                                 input logic [DATA_WIDTH-1:0]prdata
                               );
  
  //-------------------------------------------------------
  // Importing uvm_pkg file and apb_slave_pkg file
  //-------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  //-------------------------------------------------------
  // Importing apb global package
  //-------------------------------------------------------
  import apb_slave_pkg::*;

  //Variable: apb_slave_mon_proxy_h
  //Declaring handle for apb_slave_monitor_proxy
  apb_slave_monitor_proxy apb_slave_mon_proxy_h;
  
  //Variable: name
  //Assigning the string used in infos
  string name = "APB_SLAVE_MONITOR_BFM"; 
 
  initial begin
    `uvm_info(name, $sformatf("APB_SLAVE_MONITOR_BFM"), UVM_LOW);
  end

  clocking slaveCb @(posedge pclk);
   default input #1 output #1;
   input preset_n, psel, penable,paddr, pwrite,pstrb,pwdata,pprot,pslverr, pready, prdata;

  endclocking

  //-------------------------------------------------------
  // Task: wait_for_preset_n
  //  Waiting for the system reset to be active low
  //-------------------------------------------------------
  task wait_for_preset_n();
    @(negedge preset_n);
    `uvm_info(name, $sformatf("SYSTEM_RESET_DETECTED"), UVM_HIGH)
    
    @(posedge preset_n);
    `uvm_info(name, $sformatf("SYSTEM_RESET_DEACTIVATED"), UVM_HIGH)
  endtask : wait_for_preset_n

  //-------------------------------------------------------
  // Task: sample_data
  //  In this task, the pwdata and prdata is sampled
  //
  // Parameters: 
  //  apb_data_packet - Handle for apb_transfer_char_s class
  //  apb_cfg_packet  - Handle for apb_transfer_cfg_s class
  //-------------------------------------------------------
  task sample_data (output apb_transfer_char_s apb_data_packet, input apb_transfer_cfg_s apb_cfg_packet);
   @(slaveCb); 
    while(slaveCb.psel != 1'b1 || slaveCb.pready != 1'b1) begin
      @(slaveCb);
      `uvm_info(name, $sformatf("Inside while loop PSEL"), UVM_HIGH)
    end

   $display("CHECKED FOR PREADY AND PENABLE @%0t",$time());
   if(slaveCb.pready ==1 && slaveCb.psel ==1)
   begin 

    apb_data_packet.psel= slaveCb.psel;
    apb_data_packet.pslverr  = slaveCb.pslverr;
    apb_data_packet.pprot    = slaveCb.pprot;
    apb_data_packet.pwrite   = slaveCb.pwrite;
    apb_data_packet.paddr    = slaveCb.paddr;
    apb_data_packet.pstrb    = slaveCb.pstrb;
    apb_data_packet.pready = slaveCb.pready;
    apb_data_packet.penable = slaveCb.penable;


    if (slaveCb.pwrite == WRITE) begin
      apb_data_packet.pwdata = slaveCb.pwdata;
    end
    else begin
      apb_data_packet.prdata = slaveCb.prdata;
    end
  end
  else begin 
    apb_data_packet.pready = slaveCb.pready;
    apb_data_packet.penable = slaveCb.penable;
  end 
    `uvm_info(name, $sformatf("\n\n\n\SLAVE_SAMPLE_DATA=%p \n\n\n", apb_data_packet), UVM_MEDIUM)
  endtask : sample_data

endinterface : apb_slave_monitor_bfm

`endif

