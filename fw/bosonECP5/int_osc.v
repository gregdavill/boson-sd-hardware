module OSC_TOP(OSC_CLK);
	output OSC_CLK;
	OSCG #(7) OSCinst0 (.OSC(OSC_CLK));
	//defparam OSCinst0.DIV = "7"; /* 44.3MHz */
endmodule