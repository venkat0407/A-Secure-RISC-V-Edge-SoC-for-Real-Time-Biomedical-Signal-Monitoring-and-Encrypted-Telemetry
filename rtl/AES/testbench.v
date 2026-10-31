/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Test Bench                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1ns / 10ps

module test;

reg		clk;
reg		rst;

reg		kld;
reg	[127:0]	key;
reg	[127:0]	text_in;
wire	[127:0]	text_out;
wire	[127:0]	text_out2;
reg	[127:0]	text_exp;
wire		done, done2;
reg test_se;
reg test_si;
integer		n, error_cnt, ol,start,success;
initial
    begin
        success = $value$plusargs("T=%d", start);
    end

initial
   begin

if($test$plusargs("dumpfsdb"))
begin
`ifdef ZOIX
  $fsdbDumpfile("zoix.fsdb");
`else
  $fsdbDumpfile("vcs.fsdb");
`endif
  $fsdbDumpvars;
end
	$display("\n\n");
	$display("*****************************************************");
	$display("* AES Test bench ...");
	$display("*****************************************************");
	$display("\n");
`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif

	kld = 0;
	clk = 0;
	rst = 0;
	key = 128'hx;
	text_in = 128'hx;
	error_cnt = 0;
	repeat(4)	@(posedge clk);
	rst = 1;
	repeat(20)	@(posedge clk);

	$display("");
	$display("");
	$display("Started random test ...");

     for(ol=0; ol<1; ol=ol+1)
       begin
for(n=start;n<start+50;n=n+2)
   begin
	@(posedge clk);
	#1;
	kld = 1;
	case(n)
	    0: begin
		key =  128'h000102030405060708090a0b0c0d0e0f;
		text_in=128'h00112233445566778899aabbccddeeff;
	      end
	   default:
	      begin
		key =  {$random, $random, $random, $random};
		text_in= {$random, $random, $random, $random};
	      end
	endcase

	@(posedge clk);
	#1;
	kld = 0;
	key = 128'hx;
	text_exp = text_in;
	text_in = 128'hx;
	@(posedge clk);

	while(!done2)	@(posedge clk);

	$display("INFO: Vector %0d: xpected %x, Got %x", n, text_exp, text_out2);

	if(text_out2 != text_exp)
	   begin
		$display("ERROR: Vector %0d mismatch. Expected %x, Got %x",
			n, text_exp, text_out2);
		error_cnt = error_cnt + 1;
	   end

	@(posedge clk);
   end // for (n=0;n<284;n=n+1)
       end // for (ol=0; ol< 100 ; ol=ol+1)
     

	$display("");
	$display("");
	$display("Test Done. Found %0d Errors.", error_cnt);
	$display("");
	$display("");
	repeat(100)	@(posedge clk);
	$finish;
end

always #5 clk = ~clk;

always @(negedge rst)
  start=0;



//always @(negedge clk)
//#4 $fs_strobe(a0);

initial
begin

test_se = 1'b0;
end

initial
begin
if ($test$plusargs("dumpevcd"))
  $dumpports(test.a0,"vec1.evcd");
end

aes a0 (.*);  //( clk, rst, kld, key, text_in, text_out, text_out2, done, done2, test_si, test_se );

endmodule


