/*------------------------------------------------------------------------/
/  Foolproof MMCv3/SDv1/SDv2 (in SPI mode) control module
/-------------------------------------------------------------------------/
/
/  Copyright (C) 2013, ChaN, all right reserved.
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------/
  Features and Limitations:

  * Easy to Port Bit-banging SPI
    It uses only four GPIO pins. No complex peripheral needs to be used.

  * Platform Independent
    You need to modify only a few macros to control the GPIO port.

  * Low Speed
    The data transfer rate will be several times slower than hardware SPI.

  * No Media Change Detection
    Application program needs to perform a f_mount() after media change.

/-------------------------------------------------------------------------*/

#include "diskio.h" /* Common include file for FatFs and disk I/O layer */
#include <stdint.h>

#define NULL (0)

extern void print(const char *);
extern void dump(const BYTE *buff, WORD cnt);

void memcpy(uint8_t *dst, uint8_t *src, uint32_t count)
{
	if (count == 0)
		return;

	while (count--)
		*dst++ = *src++;
}

/*-------------------------------------------------------------------------*/
/* Platform dependent macros and functions needed to be modified           */
/*-------------------------------------------------------------------------*/

/* ---  SDC Configurations  --- */
#define SDC_BASE (0x02100000)
#define SDC_ARGUMENT *(uint32_t *)(SDC_BASE + 0x00)
#define SDC_COMMAND *(uint32_t *)(SDC_BASE + 0x04)
#define SDC_RESPONSE0 *(uint32_t *)(SDC_BASE + 0x08)
#define SDC_RESPONSE1 *(uint32_t *)(SDC_BASE + 0x0C)
#define SDC_RESPONSE2 *(uint32_t *)(SDC_BASE + 0x10)
#define SDC_RESPONSE3 *(uint32_t *)(SDC_BASE + 0x14)
#define SDC_DATA_TIMEOUT *(uint32_t *)(SDC_BASE + 0x18)
#define SDC_CONTROL *(uint32_t *)(SDC_BASE + 0x1C)
#define SDC_CMD_TIMEOUT *(uint32_t *)(SDC_BASE + 0x20)
#define SDC_CLOCK_DIVIDER *(uint32_t *)(SDC_BASE + 0x24)
#define SDC_RESET *(uint32_t *)(SDC_BASE + 0x28)
#define SDC_VOLTAGE *(uint32_t *)(SDC_BASE + 0x2C)
#define SDC_CAPABILITES *(uint32_t *)(SDC_BASE + 0x30)
#define SDC_CMD_EVENT_STATUS *(uint32_t *)(SDC_BASE + 0x34)
#define SDC_CMD_EVENT_ENABLE *(uint32_t *)(SDC_BASE + 0x38)
#define SDC_DATA_EVENT_STATUS *(uint32_t *)(SDC_BASE + 0x3C)
#define SDC_DATA_EVENT_ENABLE *(uint32_t *)(SDC_BASE + 0x40)
#define SDC_BLOCKSIZE *(uint32_t *)(SDC_BASE + 0x44)
#define SDC_BLOCKCOUNT *(uint32_t *)(SDC_BASE + 0x48)
#define SDC_DST_SRC_ADDRESS *(uint32_t *)(SDC_BASE + 0x60)

static void dly_us(UINT n) /* Delay n microseconds (avr-gcc -Os) */
{

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile("rdcycle %0"
					 : "=r"(cycles_begin));

	uint32_t cycles_total = n * 48;

	while (1)
	{
		__asm__ volatile("rdcycle %0"
						 : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > cycles_total)
		{
			break;
		}
	}
}

/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

/* ----- MMC/SDC command ----- */
#define CMD0 (0)		   /* GO_IDLE_STATE */
#define CMD1 (1)		   /* SEND_OP_COND (MMC) */
#define CMD2 (2)		   /* ALL_SEND_CID */
#define CMD3 (3)		   /* SEND_RELATIVE_ADDR */
#define ACMD6 (6 | 0x80)   /* SET_BUS_WIDTH (SDC) */
#define CMD7 (7)		   /* SELECT_CARD */
#define CMD8 (8)		   /* SEND_IF_COND */
#define CMD9 (9)		   /* SEND_CSD */
#define CMD10 (10)		   /* SEND_CID */
#define CMD12 (12)		   /* STOP_TRANSMISSION */
#define CMD13 (13)		   /* SEND_STATUS */
#define ACMD13 (13 | 0x80) /* SD_STATUS (SDC) */
#define CMD16 (16)		   /* SET_BLOCKLEN */
#define CMD17 (17)		   /* READ_SINGLE_BLOCK */
#define CMD18 (18)		   /* READ_MULTIPLE_BLOCK */
#define CMD23 (23)		   /* SET_BLK_COUNT (MMC) */
#define ACMD23 (23 | 0x80) /* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24 (24)		   /* WRITE_BLOCK */
#define CMD25 (25)		   /* WRITE_MULTIPLE_BLOCK */
#define CMD32 (32)		   /* ERASE_ER_BLK_START */
#define CMD33 (33)		   /* ERASE_ER_BLK_END */
#define CMD38 (38)		   /* ERASE */
#define ACMD41 (41 | 0x80) /* SEND_OP_COND (SDC) */
#define CMD55 (55)		   /* APP_CMD */

/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

static volatile DSTATUS Stat = STA_NOINIT; /* Disk status */

static volatile WORD Timer[2]; /* 1000Hz decrement timer for Transaction and Command */

static WORD CardRCA;	   /* Assigned RCA */
static BYTE CardType,	  /* Card type flag */
	CardInfo[16 + 16 + 4]; /* CSD(16), CID(16), OCR(4) */

/* Block transfer buffer (located in USB RAM) */
//static DWORD blockBuff[128] __attribute__((section(".scratchpadRam0")));

/*-----------------------------------------------------------------------*/
/* Send a command token to the card and receive a response               */
/*-----------------------------------------------------------------------*/

static int send_cmd(			/* Returns 1 when function succeeded otherwise returns 0 */
					UINT idx,   /* Command index (bit[5..0]), ACMD flag (bit7) */
					DWORD arg,  /* Command argument */
					UINT rt,	/* Expected response type. None(0), Short(1) or Long(2), 4 Read Data, 8 Write Data */
					DWORD *buff /* Response return buffer */
)
{
	UINT s, mc;

	if (idx & 0x80)
	{														/* Send a CMD55 prior to the specified command if it is ACMD class */
		if (!send_cmd(CMD55, (DWORD)CardRCA << 16, 1, buff) /* When CMD55 is faild, */
			|| !(buff[0] & 0x00000020))
			return 0; /* exit with error */
	}
	idx &= 0x3F; /* Mask out ACMD flag */

	SDC_CMD_EVENT_ENABLE = 0x1F;
	SDC_DATA_EVENT_ENABLE = 0x1F;

	mc = (idx << 8) | 0x18; /* Enable bit + index */
	if (rt & 1)
		mc |= 0x01; /* Set Response bit to reveice short resp */
	if (rt & 0x2)
		mc |= 0x02; /* Set Response and LongResp bit to receive long resp */

	/* Do we have to send/recv data after the cmd */
	if (rt & 0x4) /* Read */
		mc |= 0x20;
	if (rt & 0x8) /* Read */
		mc |= 0x40;
	//mc |= ((rt & 0xC) << 3);

	SDC_CMD_EVENT_STATUS = 0;

	SDC_COMMAND = mc;   /* Initiate command transaction */
	SDC_ARGUMENT = arg; /* Set the argument into argument register */

	for (;;)
	{ /* Wait for end of the cmd/resp transaction */

		s = SDC_CMD_EVENT_STATUS; /* Get the transaction status */
		if (rt == 0)
		{
			if (s & 0x01)
				return 1; /* CmdSent */
		}
		else
		{
			if (s & 0x01)
				break; /* CmdRespEnd */
			if (s & 0x08)
			{ /* CmdCrcFail */
				if (idx == 1 || idx == 12 || idx == 41)
					break; /* Ignore resp CRC error on CMD1/12/41 */
				return 0;
			}
			if (s & 0x04)
				return 0; /* CmdTimeOut */
		}
	}

	buff[0] = SDC_RESPONSE0; /* Read the response words */
	if (rt == 2)
	{
		buff[1] = SDC_RESPONSE1;
		buff[2] = SDC_RESPONSE2;
		buff[3] = SDC_RESPONSE3;
	}

	return 1; /* Return with success */
}

/*-----------------------------------------------------------------------*/
/* Wait card ready                                                       */
/*-----------------------------------------------------------------------*/

static int wait_ready(		   /* Returns 1 when card is tran state, otherwise returns 0 */
					  WORD tmr /* Timeout in unit of 1ms */
)
{
	DWORD rc;

	Timer[0] = tmr;
	while (Timer[0]--)
	{
		if (send_cmd(CMD13, (DWORD)CardRCA << 16, 1, &rc) && ((rc & 0x01E00) == 0x00800))
			break;

		dly_us(1000);

		/* This loop takes a time. Insert rot_rdq() here for multitask envilonment. */
	}
	return Timer[0] ? 1 : 0;
}

/*-----------------------------------------------------------------------*/
/* Swap byte order                                                       */
/*-----------------------------------------------------------------------*/

static void bswap_cp(BYTE *dst, const DWORD *src)
{
	DWORD d;

	d = *src;
	*dst++ = (BYTE)(d >> 24);
	*dst++ = (BYTE)(d >> 16);
	*dst++ = (BYTE)(d >> 8);
	*dst++ = (BYTE)(d >> 0);
}

/*--------------------------------------------------------------------------

   Public Functions

---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize(BYTE pdrv)
{
	UINT cmd, n;
	DWORD resp[4];
	BYTE ty;

	if (Stat & STA_NODISK)
		return Stat; /* No card in the socket */

	//print("1");

	SDC_RESET = 1;
	//power_on();									  /* Force socket power on */
	//MCI_CLOCK = 0x100 | (PCLK / MCLK_ID / 2 - 1); /* Set MCICLK = MCLK_ID */
	dly_us(1000); /* 10ms */

	SDC_RESET = 0;
	SDC_CLOCK_DIVIDER = 10;

	SDC_DATA_TIMEOUT = 25000;
	SDC_CMD_TIMEOUT = 2500;

	dly_us(1000); /* 10ms */

	send_cmd(CMD0, 0, 0, NULL); /* Put the card into idle state */
	CardRCA = 0;

	/*---- Card is 'idle' state ----*/

	int Timer = 1000;				   /* Initialization timeout of 1000 msec */
	if (send_cmd(CMD8, 0x1AA, 1, resp) /* Is the card SDv2? */
		&& (resp[0] & 0xFFF) == 0x1AA)
	{ /* The card can work at vdd range of 2.7-3.6V */
		do
		{ /* Wait while card is busy state (use ACMD41 with HCS bit) */

			dly_us(1000); /* 1ms */

			/* This loop takes a time. Insert task rotation here for multitask envilonment. */

			if (!Timer--)
				goto di_fail;
		} while (!send_cmd(ACMD41, 0x40FF8000, 1, resp) || !(resp[0] & 0x80000000));
		ty = (resp[0] & 0x40000000) ? CT_SD2 | CT_BLOCK : CT_SD2; /* Check CCS bit in the OCR */
	}
	else
	{ /* SDv1 or MMCv3 */
		if (send_cmd(ACMD41, 0x00FF8000, 1, resp))
		{
			ty = CT_SD1;
			cmd = ACMD41; /* ACMD41 is accepted -> SDC Ver1 */
		}
		else
		{
			ty = CT_MMC;
			cmd = CMD1; /* ACMD41 is rejected -> MMC */
		}
		do
		{ /* Wait while card is busy state (use ACMD41 or CMD1) */

			/* This loop will take a time. Insert task rotation here for multitask envilonment. */

			if (!Timer--)
				goto di_fail;
		} while (!send_cmd(cmd, 0x00FF8000, 1, resp) || !(resp[0] & 0x80000000));
	}

	CardType = ty;				   /* Save card type */
	bswap_cp(&CardInfo[32], resp); /* Save OCR */

	/*---- Card is 'ready' state ----*/

	if (!send_cmd(CMD2, 0, 2, resp))
		goto di_fail; /* Enter ident state */
	for (n = 0; n < 4; n++)
		bswap_cp(&CardInfo[n * 4 + 16], &resp[n]); /* Save CID */

	/*---- Card is 'ident' state ----*/

	if (ty & CT_SDC)
	{ /* SDC: Get generated RCA and save it */
		if (!send_cmd(CMD3, 0, 1, resp))
			goto di_fail;
		CardRCA = (WORD)(resp[0] >> 16);
	}
	else
	{ /* MMC: Assign RCA to the card */
		if (!send_cmd(CMD3, 1 << 16, 1, resp))
			goto di_fail;
		CardRCA = 1;
	}

	/*---- Card is 'stby' state ----*/

	if (!send_cmd(CMD9, (DWORD)CardRCA << 16, 2, resp))
		goto di_fail; /* Get CSD and save it */
	for (n = 0; n < 4; n++)
		bswap_cp(&CardInfo[n * 4], &resp[n]);
	if (!send_cmd(CMD7, (DWORD)CardRCA << 16, 1, resp))
		goto di_fail; /* Select card */

	/*---- Card is 'tran' state ----*/

	if (!(ty & CT_BLOCK))
	{ /* Set data block length to 512 (for byte addressing cards) */
		if (!send_cmd(CMD16, 512, 1, resp) || (resp[0] & 0xFDF90000))
			goto di_fail;
	}

	/* For now we are disabling 4bit mode. */
	if (0)
	//	if (ty & CT_SDC)
	{ /* Set wide bus mode (for SDCs) */
		if (!send_cmd(ACMD6, 2, 1, resp) || (resp[0] & 0xFDF90000))
		{ /* Set wide bus mode of SDC */
			goto di_fail;
		}

		SDC_CONTROL = 1; /* Enable Wide bus */
	}

	/* Set clock speed to 24MHz */
	SDC_CLOCK_DIVIDER = 1;

	Stat &= ~STA_NOINIT; /* Clear STA_NOINIT */
	return Stat;

di_fail:
	print("Init Fail\r\n");
	
	Stat |= STA_NOINIT; /* Set STA_NOINIT */
	return Stat;
}

/*-----------------------------------------------------------------------*/
/* Get Disk Status                                                       */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status(BYTE pdrv)
{
	return Stat;
}

/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/
DRESULT disk_read(
	BYTE pdrv,
	BYTE *buff,   /* Pointer to the data buffer to store read data */
	DWORD sector, /* Start sector number (LBA) */
	UINT count	/* Sector count (1..127) */
)
{
	DWORD resp;
	UINT cmd;
	BYTE rp;

	if (count < 1 || count > 127)
		return RES_PARERR; /* Check parameter */
	if (Stat & STA_NOINIT)
		return RES_NOTRDY; /* Check drive status */

	if (!(CardType & CT_BLOCK))
		sector *= 512; /* Convert LBA to byte address if needed */
	if (!wait_ready(500))
		return RES_ERROR; /* Make sure that card is tran state */

	/* Tell SDC DMA about out data */
	SDC_DST_SRC_ADDRESS = (uint32_t)buff;
	SDC_BLOCKSIZE = 0x1FF;
	SDC_BLOCKCOUNT = count - 1;
	SDC_DATA_EVENT_ENABLE = 0x1F;
	SDC_DATA_TIMEOUT = 50000; /* 2ms, Extend this based on blocks? */
	SDC_DATA_EVENT_STATUS = 0;

	cmd = (count > 1) ? CMD18 : CMD17;		  /* Transfer type: Single block or Multiple block */
	if (send_cmd(cmd, sector, 1 | 0x4, &resp) /* Start to read */
		&& !(resp & 0xC0580000))
	{
		/* What errors could we see when reading? */
		//return RES_ERROR;
		
	}

	/* Wait for data to finish Xfer, or a timeout */
	while (SDC_DATA_EVENT_STATUS == 0)
		;

	/* Maybe needed? Testing on hradware required */
	if (cmd == CMD18)
	{ /* Terminate to read if needed */
		send_cmd(CMD12, 0, 1, &resp);
	}

	/* Timeout or CRC error */
	if (!(SDC_DATA_EVENT_STATUS & 1))
	{
		return RES_ERROR;
	}


	return RES_OK;
	//return count ? RES_ERROR : RES_OK;
}

/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

DRESULT disk_write(
	BYTE pdrv,
	const BYTE *buff, /* Pointer to the data to be written */
	DWORD sector,	 /* Start sector number (LBA) */
	UINT count		  /* Sector count (1..127) */
)
{
	DWORD resp;
	UINT cmd;
	BYTE wp, xc;

	if (count < 1 || count > 127)
		return RES_PARERR; /* Check parameter */
	if (Stat & STA_NOINIT)
		return RES_NOTRDY; /* Check drive status */
	if (Stat & STA_PROTECT)
		return RES_WRPRT; /* Check write protection */

	if (!(CardType & CT_BLOCK))
		sector *= 512; /* Convert LBA to byte address if needed */
	if (!wait_ready(500))
		return RES_ERROR; /* Make sure that card is tran state */

	if (count == 1)
	{ /* Single block write */
		cmd = CMD24;
	}
	else
	{ /* Multiple block write */
		cmd = (CardType & CT_SDC) ? ACMD23 : CMD23;
		if (!send_cmd(cmd, count, 1, &resp) /* Preset number of blocks to write */
			|| (resp & 0xC0580000))
		{
			return RES_ERROR;
		}
		cmd = CMD25;
	}

	/* Tell SDC DMA about out data */
	SDC_DST_SRC_ADDRESS = buff;
	SDC_BLOCKCOUNT = count - 1;
	SDC_BLOCKSIZE = 0x1FF;
	SDC_DATA_EVENT_ENABLE = 0x1F;
	SDC_DATA_EVENT_STATUS = 0;

	/* Timeout is set for 100ms due to slow SD cards on first write. */
	SDC_DATA_TIMEOUT = 2500000; /* 100ms */

	if (!send_cmd(cmd, sector, 1 | 0x8, &resp) /* Send a write command */
		|| (resp & 0xC0580000))
	{
//		return RES_ERROR;
	}

	/* Wait for data to finish Xfer */
	while (SDC_DATA_EVENT_STATUS == 0)
		;

	/* Maybe required?, Would we need to terminate if we had a CRC error? */
	if (cmd == CMD25 && (CardType & CT_SDC))
	{ /* Terminate to write if needed */
		send_cmd(CMD12, 0, 1, &resp);
	}

	if (!(SDC_DATA_EVENT_STATUS & 1))
	{
		return RES_ERROR;
	}

	return RES_OK;
}

/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT disk_ioctl(
	BYTE pdrv,
	BYTE cmd,  /* Control code */
	void *buff /* Buffer to send/receive data block */
)
{
	DRESULT res;
	BYTE b, *ptr = buff, sdstat[64];
	DWORD resp[4], d, *dp, st, ed;
	static const DWORD au_size[] = {1, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 24576, 32768, 49152, 65536, 131072};

	if (Stat & STA_NOINIT)
		return RES_NOTRDY;

	res = RES_ERROR;

	switch (cmd)
	{
	case CTRL_SYNC: /* Make sure that all data has been written on the media */
		if (wait_ready(500))
			res = RES_OK; /* Wait for card enters tarn state */
		break;

	case GET_SECTOR_COUNT: /* Get number of sectors on the disk (DWORD) */
		if ((CardInfo[0] >> 6) == 1)
		{ /* SDC CSD v2.0 */
			d = CardInfo[9] + ((WORD)CardInfo[8] << 8) + ((DWORD)(CardInfo[7] & 63) << 16) + 1;
			*(DWORD *)buff = d << 10;
		}
		else
		{ /* MMC or SDC CSD v1.0 */
			b = (CardInfo[5] & 15) + ((CardInfo[10] & 128) >> 7) + ((CardInfo[9] & 3) << 1) + 2;
			d = (CardInfo[8] >> 6) + ((WORD)CardInfo[7] << 2) + ((WORD)(CardInfo[6] & 3) << 10) + 1;
			*(DWORD *)buff = d << (b - 9);
		}
		res = RES_OK;
		break;

	case GET_BLOCK_SIZE: /* Get erase block size in unit of sectors (DWORD) */
		if (CardType & CT_SD2)
		{ /* SDC ver 2.00 */
			if (disk_ioctl(pdrv, MMC_GET_SDSTAT, sdstat))
				break;
			*(DWORD *)buff = au_size[sdstat[10] >> 4];
		}
		else
		{ /* SDC ver 1.XX or MMC */
			if (CardType & CT_SD1)
			{ /* SDC v1 */
				*(DWORD *)buff = (((CardInfo[10] & 63) << 1) + ((WORD)(CardInfo[11] & 128) >> 7) + 1) << ((CardInfo[13] >> 6) - 1);
			}
			else
			{ /* MMC */
				*(DWORD *)buff = ((WORD)((CardInfo[10] & 124) >> 2) + 1) * (((CardInfo[11] & 3) << 3) + ((CardInfo[11] & 224) >> 5) + 1);
			}
		}
		res = RES_OK;
		break;

	case CTRL_TRIM: /* Erase a block of sectors */
		if (!(CardType & CT_SDC) || (!(CardInfo[0] >> 6) && !(CardInfo[10] & 0x40)))
			break; /* Check if sector erase can be applied to the card */
		dp = buff;
		st = dp[0];
		ed = dp[1];
		if (!(CardType & CT_BLOCK))
		{
			st *= 512;
			ed *= 512;
		}
		if (send_cmd(CMD32, st, 1, resp) && send_cmd(CMD33, ed, 1, resp) && send_cmd(CMD38, 0, 1, resp) && wait_ready(30000))
		{
			res = RES_OK;
		}
		break;

	case CTRL_POWER_OFF:
		//power_off(); /* Power off */
		res = RES_OK;
		break;

	case MMC_GET_TYPE: /* Get card type flags (1 byte) */
		*ptr = CardType;
		res = RES_OK;
		break;

	case MMC_GET_CSD: /* Get CSD (16 bytes) */
		memcpy(buff, &CardInfo[0], 16);
		res = RES_OK;
		break;

	case MMC_GET_CID: /* Get CID (16 bytes) */
		memcpy(buff, &CardInfo[16], 16);
		res = RES_OK;
		break;

	case MMC_GET_OCR: /* Get OCR (4 bytes) */
		memcpy(buff, &CardInfo[32], 4);
		res = RES_OK;
		break;

	case MMC_GET_SDSTAT: /* Receive SD status as a data block (64 bytes) */
		if (CardType & CT_SDC)
		{ /* SDC */
			print("Get Data Block ");
			if (wait_ready(500))
			{
				print("Ready?");
				SDC_BLOCKSIZE = 63;
				SDC_BLOCKCOUNT = 0x1;
				//ready_reception(1, 64);			 /* Ready to receive data blocks */
				if (send_cmd(ACMD13, 0, 1 | 0x4, resp) /* Start to read */
					&& !(resp[0] & 0xC0580000))
				{
					res = RES_OK;
				}
			}
			print("\r\n");
			//stop_transfer(); /* Close data path */
		}
		break;

	default:
		res = RES_PARERR;
	}

	return res;
}
