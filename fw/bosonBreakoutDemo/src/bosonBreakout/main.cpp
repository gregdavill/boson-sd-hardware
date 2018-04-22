#include "sam.h"

#include "hw.h"

#include "stdio.h"

extern unsigned char ___hyperRAM_FIFO_hyperRAM_FIFO_hyperRAM_FIFO_Implmnt_sbt_outputs_bitmap_bosonBreakoutTest_bitmap_bin[];
extern unsigned int  ___hyperRAM_FIFO_hyperRAM_FIFO_hyperRAM_FIFO_Implmnt_sbt_outputs_bitmap_bosonBreakoutTest_bitmap_bin_len;

void spi_init()
{
	// fpgaSpiMiso.Mux(7);
	// fpgaSpiMosi.Mux(7);
	// fpgaSpiClk.Mux(7);

	// fpgaSpiMiso.MuxEn(true);
	// fpgaSpiMosi.MuxEn(true);
	// fpgaSpiClk.MuxEn(true);

	fpgaSpiClk.Set();
	fpgaSpiMosi.Set();

	fpgaSpiMiso.Dir(false);
	fpgaSpiMiso.InputEn(true);
	
	fpgaSpiMosi.Dir(true);
	fpgaSpiClk.Dir(true);
}

void spi_dummy_clk(int clks)
{
	// fpgaSpiClk.MuxEn(false);

	for (int i = 0; i < clks; i++) {
		fpgaSpiClk.Clear();
		fpgaSpiClk.Clear();
		fpgaSpiClk.Clear();
		fpgaSpiClk.Clear();
		fpgaSpiClk.Set();
	}

	// fpgaSpiClk.MuxEn(true);
}

void delay(int d)
{
	int y;
	while(d--){
		y = 20;
		while(y--){
			asm("nop");
		}
	}
}

void spi_transmit_byte(unsigned char c)
{
	for (int i = 0; i < 8; i++) {
		fpgaSpiClk.Clear();
		if (c & 0x80)
			fpgaSpiMosi.Set();
		else
			fpgaSpiMosi.Clear();
		fpgaSpiClk.Set();
		c = c << 1;
	}
}

void spi_transmit(const unsigned char* data, unsigned int data_length)
{
	for (uint32_t i = 0; i < data_length; i++) {
		spi_transmit_byte(data[i]);
		ledQspiAct.Toggle();
	}
	ledQspiAct.Set();
}

void fpga_init()
{
	fpgaCDone.InputEn(true);
	fpgaCDone.Set();

	/* Hold FPGA in reset */
	fpgaRst.Clear();
	fpgaRst.Dir(true);

	/* CS line setup */
	fpgaCs.Clear();
	fpgaCs.Dir(true);



	spi_init();
	delay(30);

	/* Release FPGA Reset */
	fpgaRst.Set();

	/* wait ~1.2ms*/
	delay(1200);

	fpgaCs.Set();

	/* Upload Bitstream */
	const unsigned char* ptr = ___hyperRAM_FIFO_hyperRAM_FIFO_hyperRAM_FIFO_Implmnt_sbt_outputs_bitmap_bosonBreakoutTest_bitmap_bin;
	unsigned int len = ___hyperRAM_FIFO_hyperRAM_FIFO_hyperRAM_FIFO_Implmnt_sbt_outputs_bitmap_bosonBreakoutTest_bitmap_bin_len;
	
	spi_transmit(ptr, len);

	spi_transmit_byte(0xFF);

	spi_dummy_clk(64);


}

int main()
{
	ledUsbAct.Dir(true);
	ledSdAct.Dir(true);
	ledQspiAct.Dir(true);
	ledUsbAct.Set();
	ledSdAct.Set();
	ledQspiAct.Set();

	debugTx.Dir(true);
	debugTx.Set();
	debugTx.Clear();

	SdSel.Dir(true);
	SdSel.Set();

	fpga_init();

	while (1) {
		ledUsbAct.Set();

		ledUsbAct.Clear();
	}
}
