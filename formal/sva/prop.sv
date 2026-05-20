module apb_slave_tb #(
    parameter ADDR_WIDTH = 5,      // Address bus width
    parameter DATA_WIDTH = 32,     // Data bus width
    parameter MEM_DEPTH  = 32     // Memory depth (number of locations)
)(
    // APB Global Signals
    input  wire                    PCLK,       // Clock
    input  wire                    PRESETn,    // Active-low reset
    // APB Slave Signals
    input  wire [ADDR_WIDTH-1:0]   PADDR,      // Address
    input  wire                    PSEL,       // Slave select
    input  wire                    PENABLE,    // Enable
    input  wire                    PWRITE,     // Write control (1=Write, 0=Read)
    input  wire [DATA_WIDTH-1:0]   PWDATA,     // Write data
    input  wire [DATA_WIDTH/8-1:0] PSTRB,      // Write strobe (byte enables)
    input reg  [DATA_WIDTH-1:0]   PRDATA,     // Read data
    input wire                    PREADY,     // Ready signal
    input  wire                    PSLVERR     // Error signal
);
   bit[ADDR_WIDTH-1:0] symAddr;
   bit[DATA_WIDTH-1:0]symData;
   bit symIn,symOut;
   bit selCame; 
   always_ff@(posedge PCLK or negedge PRESETn) begin 
     if(!PRESETn) begin 
        symData=0;
        symIn=0;
        selCame=0;
     end 
     else begin
       if(PSEL==1 ) begin 
         selCame=1;
       end 
       if(PSEL==1 && PENABLE==1 && PREADY==1) begin 
          selCame=0;
       end 
       if(PSEL==1 && PENABLE==1 && PWRITE==1 && (symAddr==PADDR) && PREADY==1 && (symData==PWDATA)) begin 
         symIn=1;
       end
       if(PSEL==1 && PENABLE==1 && PWRITE==0 && (symAddr==PADDR) && PREADY==1) begin
         symOut=1;
       end
        
     end 

   end 

  default disable iff (!PRESETn);
  CHE:assert property(@(posedge PCLK) (PSEL && PENABLE==0)|=> (PSEL==1 && PENABLE));

  PROTOCOL_STRUCT:assert property(@(posedge PCLK) ($rose(PSEL)|-> (PENABLE==0)));

  PROTOCOL_STRUCT2:assert property(@(posedge PCLK) PSEL==1 &&PENABLE==1 && PREADY==0 |=> (PSEL==1 && PENABLE==1));

  PROTOCOL_STRUCT1:assert property(@(posedge PCLK) $rose(PSEL) |=> (##[0:$](PREADY && PENABLE==1)));

  STAB:assert property (@(posedge PCLK) PSEL==1 && PENABLE==1|-> ($stable(PADDR) &&  $stable(PWRITE) && $stable(PWDATA) && $stable(PSTRB)));
  
  assert property(@(posedge PCLK) PSEL==1 && PENABLE==1 && PREADY==1 && PWRITE==1 |=> apb_slave.memory[$past(PADDR,1)] == $past(PWDATA,1));
  
  assert property(@(posedge PCLK)(symIn==1 && symOut==0 &&  PSEL==1 && PENABLE==1 && PREADY &&(PADDR==symAddr) && (PWRITE==0)) |=> PRDATA==symData);
  
  assume property(@(posedge PCLK)
     PSEL==1 && selCame==0 |=> (PSEL==1 && PENABLE==1)); 
  
  assume property(@(posedge PCLK)
    PSEL==1 && selCame==0 |-> PENABLE==0);

  assume property(@(posedge PCLK) 
    (PSEL==1 && PENABLE==1) |-> ($stable(PADDR) && $stable(PWRITE) && $stable(PWDATA) && $stable(PSTRB))); // not with resp to ready as it can be proactive slave 
 assume property(@(posedge PCLK) 
    (PSEL==1 && selCame==1 && PENABLE==1 && PREADY==1)|=>(PSEL==0 && PENABLE==0) );  

 assume property(@(posedge PCLK)
    (selCame==1 && PREADY==0)|->(PSEL==1 && PENABLE==1) );

 assume property(@(posedge PCLK) PSTRB==15);

 assume property(@(posedge PCLK) $stable(symAddr));

 assume property(@(posedge PCLK) symIn==1 |-> (((PADDR != symAddr) && PWRITE ==1) || PWRITE==0));

 assume property(@(posedge PCLK) $stable(symData));
endmodule

bind apb_slave apb_slave_tb inst(.*);

