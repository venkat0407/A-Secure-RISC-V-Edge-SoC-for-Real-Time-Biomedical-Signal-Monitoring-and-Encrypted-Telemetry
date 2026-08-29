sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-sv" "-f" "file.f" "-top" "tb_axi_interconnect_wrap_1x9"
debLoadSimResult \
           /home/student/Documents/nani/rtl/interconnect/tb_axi_interconnect_wrap_1x9.fsdb
wvCreateWindow
verdiWindowResize -win $_Verdi_1 "330" "84" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvGetSignalSetScope -win $_nWave2 \
           "/tb_axi_interconnect_wrap_1x9/dut/axi_interconnect_inst"
wvGetSignalSetScope -win $_nWave2 \
           "/tb_axi_interconnect_wrap_1x9/dut/axi_interconnect_inst/arb_inst"
wvGetSignalSetScope -win $_nWave2 \
           "/tb_axi_interconnect_wrap_1x9/dut/axi_interconnect_inst/arb_inst/priority_encoder_inst"
wvGetSignalSetScope -win $_nWave2 \
           "/tb_axi_interconnect_wrap_1x9/dut/axi_interconnect_inst/arb_inst/priority_encoder_masked"
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9/u_mem00"
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_axi_interconnect_wrap_1x9/s00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arlen\[7:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arsize\[2:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awlen\[7:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rlast} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wlast} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wstrb\[3:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wuser\[0:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           )} 
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_axi_interconnect_wrap_1x9/s00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arlen\[7:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arsize\[2:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_arvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awlen\[7:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rlast} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rvalid} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wlast} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wready} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wstrb\[3:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wuser\[0:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           )} 
wvSetPosition -win $_nWave2 {("G1" 17)}
wvGetSignalClose -win $_nWave2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 11 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 8 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 7 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 6 7 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 5 6 7 8 9 10 11 12 13 14 15 16 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 4 5 6 7 8 9 10 11 12 13 14 15 16 17 )} \
           
wvSelectSignal -win $_nWave2 {( "G1" 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 )} \
           
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSelectGroup -win $_nWave2 {G1}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9/dut"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9/dut"
wvGetSignalSetScope -win $_nWave2 "/tb_axi_interconnect_wrap_1x9"
wvSetPosition -win $_nWave2 {("G1" 52)}
wvSetPosition -win $_nWave2 {("G1" 52)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_axi_interconnect_wrap_1x9/clk} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_rresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 )} 
wvSetPosition -win $_nWave2 {("G1" 52)}
wvSetPosition -win $_nWave2 {("G1" 52)}
wvSetPosition -win $_nWave2 {("G1" 52)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_axi_interconnect_wrap_1x9/clk} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_rresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m00_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m01_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m02_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m03_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m04_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m05_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m06_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m07_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/m08_axi_wdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_araddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_awaddr\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_bresp\[1:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_rdata\[31:0\]} \
{/tb_axi_interconnect_wrap_1x9/s00_axi_wdata\[31:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 )} 
wvSetPosition -win $_nWave2 {("G1" 52)}
wvGetSignalClose -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 4
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
verdiCaptureWindow -win $_nWave2
wvCapture -win $_nWave2 -file \
          "/home/student/Documents/nani/rtl/interconnect/tb_inter1.png"
verdiCloseDialog -win $_nWave2 -widget capturePreview
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
verdiCaptureWindow -win $_nWave2
wvCapture -win $_nWave2 -file \
          "/home/student/Documents/nani/rtl/interconnect/tb_inter2.png"
verdiCloseDialog -win $_nWave2 -widget capturePreview
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
debExit
