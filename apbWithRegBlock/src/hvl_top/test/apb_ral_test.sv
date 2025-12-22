`ifndef APB_RAL_TEST
`define APB_RAL_TEST

class apb_ral_test extends apb_base_test;
 `uvm_component_utils(apb_ral_test)

  apb_ral_seq test_seq;
  apb_slave_8b_write_seq  slave_seq;
  extern function new(string name = "apb_ral_test",uvm_component parent);

  extern virtual function void build_phase(uvm_phase phase);
  
  extern virtual task run_phase(uvm_phase phase);

endclass

function apb_ral_test :: new(string name = "apb_ral_test",uvm_component parent);
  super.new(name,parent);
endfunction 


function void apb_ral_test :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  
endfunction 

task apb_ral_test::run_phase(uvm_phase phase);
  test_seq = apb_ral_seq :: type_id :: create("test_seq");
    test_seq.env_config = apb_env_cfg_h;
   slave_seq = apb_slave_8b_write_seq  :: type_id :: create("slave_seq");

   phase.raise_objection(this);
    fork 
       begin
            test_seq.start(apb_env_h.apb_master_agent_h.apb_master_seqr_h);
        end

        begin 
            forever  begin
           slave_seq.start(apb_env_h.apb_slave_agent_h[0].apb_slave_seqr_h);
            end
        end
    join_any 
   #1000;
   phase.drop_objection(this);
endtask

`endif


