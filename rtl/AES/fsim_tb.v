 
 `timescale 1ns / 10ps
 module test ;
 aes a0 (); 

 always @(negedge a0.clk) begin
   #4 $fs_strobe(a0.done);
   #4 $fs_strobe(a0.done2);
   #4 $fs_strobe(a0.text_out2);
   #4 $fs_strobe(a0.text_out);
   end
   
 initial
   if($test$plusargs("dumpfsdb"))
     $fsdbDumpvars;
 endmodule



