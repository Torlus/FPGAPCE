/*
 * genren.c
 *
 * Sega Genesis rendering engine. Draws a frame based on save state data.
 *
 * Usage:   genren <savestate> [options]
 * Options: -?, -h		Show help text
 *			-draw={abs}	Draw Scroll A, B, sprites (e.g. -draw=as for Scroll A
 *                      and sprites only)
 *			-clear=#	Clear buffer initially with the specified hexadecimal
 *						24-bit RGB value (background color will only be used
 *						for 0 pixels of Scroll B) instead of background color
 *			-nocrop		Show full 336x224 display buffer with safety borders
 *			-vdpinfo	Print VDP state information to stdout
 *			-dumpvdp	Dump the VDP context to vdp.bin
 *
 * NOTE: When a user-defined clear color is specified it will overwrite palette
 * entry 63 so as not to confuse the sprite engine. This means that if the VDP
 * background color is set to 63, the clear color will be used for Scroll B 0
 * pixels instead of the background color.
 *
 * NOTE: This code will only work properly on little-endian systems. It should
 * be a trivial matter, however, to port it to big-endian architectures.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "types.h"

// VDC
UINT16 SAT[0x100];
UINT16 VRAM[0x8000];

UINT16 MAWR;    // Memory Address Write Register
UINT16 MARR;    // Memory Address Read Register

UINT16 CR;      // Control Register
UINT16 RCR;     // Raster Compare Register
UINT16 BXR;     // Background X-Scroll Register
UINT16 BYR;     // Background Y-Scroll Register
UINT16 MWR;     // Memory Width Register

UINT16 HSR;     // Horizontal Sync Register
UINT16 HDR;     // Horizontal Display Register
UINT16 VSR;
UINT16 VDR;

UINT16 VCR;
UINT16 DCR;
UINT16 SOUR;
UINT16 DESR;
UINT16 LENR;
UINT16 SATB;

//VCE
UINT16 VCE_COL[0x200];
UINT16 VCE_CR;

//BMP
#define MAX_WIDTH 682
#define MAX_HEIGHT 263
UINT32 bmp_pal[256];
UINT8 bmp_img[MAX_WIDTH*MAX_HEIGHT];

// PCE color (GGGRRRBBB) to BMP palette entry number (BBGGGRRR) conversion
static inline UINT8 pce2bmp(UINT16 col) {
	int g = (col>>6)&0x7;
	int r = (col>>3)&0x7;
	int b = (col>>1)&0x3;
	return (UINT8)( (b<<6) | (g<<3) | (r<<0) );
}

void render(void);

/*****************************************************************************
 BMP Output
 
 Code to write BMP files
*****************************************************************************/

/*
 * struct bmp_header:
 *
 * BMP file header. Must be initialized properly.
 *
 * NOTE: Each line of the image data must be padded out to 4 byte boundaries.
 * Therefore, the image data size is not simply xres * yres.
 */

struct bmp_header
{
	UINT8	sig[2]			PACKED;	// set to 'BM'
	UINT32	file_size		PACKED;	// size of entire BMP file: 54 + palette_entries * 4 + image data size
	UINT32	reserved		PACKED;	// unused, set to 0
	UINT32	img_offset		PACKED;	// offset of beginning of image data: 54 + palette_entries * 4
	UINT32	info_size		PACKED;	// size of BMP info header (40 bytes)
	UINT32	width			PACKED;	// image width in pixels
	UINT32	height			PACKED;	// height
	UINT16	planes			PACKED;	// number of planes (must be 1)
	UINT16	bpp				PACKED;	// bits per pixel (8 or 24)
	UINT32	compression		PACKED;	// compression type (set to 0)
	UINT32	img_size		PACKED;	// image data size (if not compressed, leave it 0)
	UINT32	xpelspermeter	PACKED;	// horizontal pixels per meter (leave it 0)
	UINT32	ypelspermeter	PACKED;	// vertical pixels per meter (0)
	UINT32	num_colors		PACKED;	// number of palette entries 
	UINT32	imp_colors		PACKED;	// number of important colors (set to 0)
};

/*
 * InitBMPHeader():
 *
 * Initializes a BMP header structure. The number of palette entries is
 * calculated based on the bpp (1, 4, 8 or 24 only.)
 */
 
static void InitBMPHeader(struct bmp_header *bmp_header, INT xres, INT yres, INT bpp)
{
	UINT	pal_size, line_size, img_size;
	
	/*
	 * Calculate the number of palette entries and the size of the image data.
	 * Each line of the image data must be of a size divisible by 4 and
	 * thus additional padding may be needed.
	 */
	 
	pal_size = (bpp == 24) ? 0 : (1 << bpp);
	
	line_size = xres;
	if (bpp == 24)
		line_size *= 4;
	else if (bpp == 1)
		line_size /= 8;
	else if (bpp == 4)
		line_size /= 2;
	line_size = (line_size + 3) & (~3);	// align to 4 byte boundaries
	
	img_size = line_size * yres;
	
	memset(bmp_header, 0, sizeof(struct bmp_header));	
	bmp_header->sig[0] = 'B';
	bmp_header->sig[1] = 'M';
	bmp_header->file_size = 54 + pal_size * 4 + img_size;
	bmp_header->img_offset = 54 + pal_size * 4;
	bmp_header->info_size = 40;
	bmp_header->width = xres;
	bmp_header->height = yres;
	bmp_header->planes = 1;
	bmp_header->bpp = bpp;
	bmp_header->num_colors = pal_size;
}
	 
/*
 * WriteBMP8():
 *
 * Writes a BMP image to an output file.
 */
 
static BOOL WriteBMP8(const char *fname, const UINT8 *img, const UINT32 pal[256], INT xres, INT yres)
{
	struct bmp_header	bmp_header;
	FILE				*fp;
	INT					i, line_size;
	UINT8				pad[4] = { 0, 0, 0, 0 };
		
	/*
	 * Open the BMP file and write the header
	 */
	 
	fp = fopen(fname, "wb");
	if (fp == NULL)
		return 1;		
	
	InitBMPHeader(&bmp_header, xres, yres, 8);
	fwrite(&bmp_header, sizeof(struct bmp_header), 1, fp);
	
	/*
	 * Write the palette data
	 */
	 
	for (i = 0; i < 256; i++)
		fwrite(&pal[i], sizeof(UINT32), 1, fp);
		
	/*
	 * Write the image data bottom-up
	 */
	 
	line_size = (xres + 3) & (~3);
	
	for (i = yres - 1; i >= 0; i--)
	{
		fwrite(&img[i * xres + 0], sizeof(UINT8), xres, fp);
		fwrite(pad, sizeof(UINT8), (line_size - xres), fp);	// pad to 4 byte boundaries
	}
	
	fclose(fp);
	
	return 0;
}

/*****************************************************************************
 Main Program
*****************************************************************************/

/*
 * int main(int argc, char **argv);
 *
 * Program entry point.
 */
 
int main(int argc, char **argv)
{	
	char	*fname;	
	FILE *fp;
	int i, r, g, b;
	
	// int x,y,col;
	
	if (argc <= 1)
	{
		puts("genren: Usage: pceren <savestate>");
		return 0;
	}
	fname = argv[1];	

	// Load "save state"
	fp = fopen(fname, "rb");
	if (fp == NULL)
		exit(1);
	
	// RAMs (VDC,VCE)
	fread(VRAM, sizeof(UINT16), 0x8000, fp);
	fread(SAT, sizeof(UINT16), 0x100, fp);
	
	fread(VCE_COL, sizeof(UINT16), 0x200, fp);
	// Registers (VDC,VCE)
	fread(&MAWR, sizeof(UINT16), 1, fp);
	fread(&MARR, sizeof(UINT16), 1, fp);
	fread(&CR, sizeof(UINT16), 1, fp);
	fread(&RCR, sizeof(UINT16), 1, fp);
	fread(&BXR, sizeof(UINT16), 1, fp);
	fread(&BYR, sizeof(UINT16), 1, fp);
	fread(&MWR, sizeof(UINT16), 1, fp);
	fread(&HSR, sizeof(UINT16), 1, fp);
	fread(&HDR, sizeof(UINT16), 1, fp);
	fread(&VSR, sizeof(UINT16), 1, fp);
	fread(&VDR, sizeof(UINT16), 1, fp);
	fread(&VCR, sizeof(UINT16), 1, fp);
	fread(&DCR, sizeof(UINT16), 1, fp);
	fread(&SOUR, sizeof(UINT16), 1, fp);
	fread(&DESR, sizeof(UINT16), 1, fp);
	fread(&LENR, sizeof(UINT16), 1, fp);
	fread(&SATB, sizeof(UINT16), 1, fp);
	// printf("SATB = %04X\n", SATB);


	// BYR = 0x01A0;
	// BXR = 0x0000;
	
	fread(&VCE_CR, sizeof(UINT8), 1, fp);
	fclose(fp);

	fp = fopen("regs.vhd","wb");
	fprintf(fp, "CR <= x\"%04X\";\n", CR);
	fprintf(fp, "RCR <= x\"%04X\";\n", RCR);
	fprintf(fp, "MWR <= x\"%04X\";\n", MWR);
	fprintf(fp, "HPR <= x\"%04X\";\nHDR <= x\"%04X\";\nVSR <= x\"%04X\";\nVDR <= x\"%04X\";\nVDE <= x\"%04X\";\n", HSR, HDR, VSR, VDR, VCR);
	fprintf(fp, "BXR <= x\"%04X\";\n", BXR);
	fprintf(fp, "BYR <= x\"%04X\";\n", BYR);
	fprintf(fp, "DCR <= x\"%04X\";\n", DCR);
	fprintf(fp, "SATB <= x\"%04X\";\n", SATB);

	fclose(fp);
	
	fp = fopen("vram.txt","wb");
	for(i = 0; i < 0x8000; i++) {
		fprintf(fp,"%02X%02X\n", (VRAM[i]>>8)&0xFF, VRAM[i]&0xFF);
	}
	fclose(fp);

	fp = fopen("vram.bin","wb");
	for(i = 0; i < 0x8000; i++) {
		fwrite( ((char *)&VRAM[i])+1, 1, 1, fp);
		fwrite( ((char *)&VRAM[i]), 1, 1, fp);
	}
	fclose(fp);
	
	fp = fopen("flash.txt","wb");
	for(i = 0; i < 0x8000; i++) {
		fprintf(fp,"%02X\n%02X\n", (VRAM[i]>>8)&0xFF, VRAM[i]&0xFF); // Big endian
	}
	fclose(fp);
	
	fp = fopen("vce.mif","wb");
	fprintf(fp, "WIDTH = 16;\n");
	fprintf(fp, "DEPTH = 512;\n");
	fprintf(fp, "ADDRESS_RADIX = HEX;\n");
	fprintf(fp, "DATA_RADIX = HEX;\n");
	fprintf(fp, "CONTENT\n");
	fprintf(fp, "BEGIN\n");
	for(i = 0; i < 0x200; i++) {
		fprintf(fp,"%04X : %02X%02X;\n", i, (VCE_COL[i]>>8)&0xFF, VCE_COL[i]&0xFF);
		// fprintf(fp,"%04X : %02X%02X;\n", i, 0, 0);
	}
	fprintf(fp, "END;\n");
	fclose(fp);


	fp = fopen("sat.mif","wb");
	fprintf(fp, "WIDTH = 16;\n");
	fprintf(fp, "DEPTH = 256;\n");
	fprintf(fp, "ADDRESS_RADIX = HEX;\n");
	fprintf(fp, "DATA_RADIX = HEX;\n");
	fprintf(fp, "CONTENT\n");
	fprintf(fp, "BEGIN\n");
	for(i = 0; i < 0x100; i++) {
		fprintf(fp,"%04X : %02X%02X;\n", i, (SAT[i]>>8)&0xFF, SAT[i]&0xFF);
		// fprintf(fp,"%04X : %02X%02X;\n", i, 0, 0);
	}
	fprintf(fp, "END;\n");
	fclose(fp);
	
	// Initialize BMP
	memset(bmp_pal, 0, sizeof(UINT32) * 256);
	memset(bmp_img, 0, sizeof(UINT8) * MAX_WIDTH * MAX_HEIGHT);
 	// Set up BBGGGRRR palette
	for(i = 0; i < 256; i++) {
		b = (i&0xC0);
		g = (i&0x38)<<2;
		r = (i&0x07)<<5;
		bmp_pal[i] = (r<<16) | (g<<8) | (b<<0);
	}
	
	render();
	
	// Palette test
	/*for(y = 0; y < MAX_HEIGHT; y++) {
		for(x = 0; x < MAX_WIDTH; x++) {
			col = x & 0x1FF; // PCE col
			bmp_img[y*MAX_WIDTH+x] = pce2bmp(col);
		}
	}*/
	
	// Write output
	WriteBMP8("out.bmp", bmp_img, bmp_pal, MAX_WIDTH, MAX_HEIGHT);

	return 0;
}


// ======================================================================================
// ======================================================================================
// ======================================================================================
typedef struct {
	UINT8 pri;
	UINT8 zero;
	UINT8 col[16];
	UINT16 x;
} sprite_buffer_t;

sprite_buffer_t sp_buf[16];

void render(void) {
	int x,y,x_max,y_max;

	int bg_hs, bg_vs; // Background sizes
	int bg_y;
	int bg_tx, bg_px;
	int tx, tpx;
	UINT16 nt_addr;
	UINT16 nt_entry;
	
	UINT16 bg_name;
	UINT16 bg_pal;
	UINT16 bg_addr;
	UINT16 bg_01;
	UINT16 bg_23;
	
	int i,k;
	int sp_cur_y;
	int sp_nb;
		
	UINT16 bg_buf[1024];
	UINT16 line_buf[1024];
	
	UINT16 HSW = HSR & 0x1F;
	UINT16 HDS = (HSR >> 8) & 0x7F;
	UINT16 HDW = HDR & 0x7F;
	UINT16 HDE = (HDR >> 8) & 0x7F;
	
	UINT16 VSW = VSR & 0x1F;
	UINT16 VDS = (VSR >> 8) & 0xFF;
	UINT16 VDW = VDR & 0x1FF;
	VCR = VCR & 0xFF;

	printf("HSW = %d, HDS = %d, HDW = %d, HDE = %d\n", HSW, HDS, HDW, HDE);
	
	x_max = (HSW+1+HDS+1+HDW+1+HDE+1)<<3;
	y_max = (VSW+1+VDS+2+VDW+1+VCR);
	printf("width = %d, height = %d\n", x_max, y_max);
	if (x_max > MAX_WIDTH) x_max = MAX_WIDTH;
	if (y_max > MAX_HEIGHT) y_max = MAX_HEIGHT;
	
	bg_vs = (MWR>>6)&1;
	bg_hs = (MWR>>4)&3;
	printf("bg_vs = %d bg_hs = %d\n", bg_vs, bg_hs);
	
	for(y = 0; y < y_max; y++) {
	
		// Overscan (left)
		for(x = 0; x < (HSW+1+HDS+1)<<3; x++) {
			line_buf[x] = 0x100;
		}

		if ((y >= VSW+1+VDS+2) && (y < VSW+1+VDS+2+VDW+1)) {
		
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// ==================== SPRITES
////////////////////////////////////////////////////////////////////////////////////////////		
////////////////////////////////////////////////////////////////////////////////////////////
		
			sp_cur_y = y - (VSW+1+VDS+2) + 64;
			sp_nb = 0;
			for(i = 0; i < 16; i++) {
					sp_buf[i].x = -1;
			}
			for(i = 0; i < 64; i++) {
				UINT16 sp_y = SAT[(i<<2)] & 0x3FF;
				
				UINT16 sp_x = SAT[(i<<2) + 1] & 0x3FF;
				
				UINT16 sp_cg = SAT[(i<<2) + 2]&1;
				UINT16 sp_name = (SAT[(i<<2) + 2]>>1) & 0x3FF;
				
				UINT16 sp_vf = (SAT[(i<<2) + 3]>>15)&1;
				UINT16 sp_cgy = (SAT[(i<<2) + 3]>>12)&3;
				UINT16 sp_hf = (SAT[(i<<2) + 3]>>11)&1;
				UINT16 sp_cgx = (SAT[(i<<2) + 3]>>8)&1;
				UINT16 sp_pri = (SAT[(i<<2) + 3]>>7)&1;
				UINT16 sp_pal = SAT[(i<<2) + 3]&0xF;
				
				UINT16 sp_h;
				switch(sp_cgy) {
					case 0: sp_h = 16; break;
					case 1: sp_h = 32; sp_name &= ~0x2; break;
					default: sp_h = 64; sp_name &= ~0x6; break;
				}
				UINT16 sp_w;
				switch(sp_cgx) {
					case 0: sp_w = 16; break;
					default: sp_w = 32; sp_name &= ~0x1; break;
				}
				
				if (!(sp_cur_y >= sp_y && sp_cur_y < sp_y+sp_h)) continue;
				printf("sp_cur_y = %d, spL %d cgx=%d cgy=%d hf=%d vf=%d SAT@%02X=%04X %04X %04X %04X\n", sp_cur_y, i, sp_cgx, sp_cgy, sp_hf, sp_vf, i<<2, 
					SAT[(i<<2)], SAT[(i<<2)+1], SAT[(i<<2)+2], SAT[(i<<2)+3]);
				UINT16 y_ofs = sp_cur_y - sp_y;
				if (sp_vf) {
					y_ofs = sp_h - 1 - y_ofs;
				}
				if (sp_cgx && sp_hf) {
					sp_name |= 1;
				}
				sp_name |= ((y_ofs>>4)<<1);
		
				printf("sp_cur_y = %d, spL %d NAME=%04X ADDR=%04X\n", sp_cur_y, i, sp_name, (sp_name<<6) + (y_ofs&0xF));
		
				UINT16 sp_p0 = VRAM[(sp_name<<6) + (y_ofs&0xF)];
				UINT16 sp_p1 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 16];
				UINT16 sp_p2 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 32];
				UINT16 sp_p3 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 48];
				
				sp_buf[sp_nb].pri = sp_pri;
				sp_buf[sp_nb].zero = (i == 0);
				sp_buf[sp_nb].x = sp_x + ((HSW+1+HDS+1)<<3) - 32;
				
				for(k = 0; k < 16; k++) {
					int col = 0;
					UINT16 px = k;
					if (sp_hf)
						px = 15 - px;
					col |= ((sp_p0>>(15-px))&1);
					col |= ((sp_p1>>(15-px))&1)<<1;
					col |= ((sp_p2>>(15-px))&1)<<2;
					col |= ((sp_p3>>(15-px))&1)<<3;
					
					sp_buf[sp_nb].col[px] = col | (sp_pal<<4);
				}

				sp_nb++;
				if (sp_nb == 16)
					break;
				if (!sp_cgx) continue;
				printf("sp_cur_y = %d, spR %d cgx=%d cgy=%d hf=%d vf=%d SAT@%02X=%04X %04X %04X %04X\n", sp_cur_y, i, sp_cgx, sp_cgy, sp_hf, sp_vf, i<<2, 
					SAT[(i<<2)], SAT[(i<<2)+1], SAT[(i<<2)+2], SAT[(i<<2)+3]);
				// Second part of a 32-wide sprite
				sp_name ^= 1;
				
				printf("sp_cur_y = %d, spR %d NAME=%04X ADDR=%04X\n", sp_cur_y, i, sp_name, (sp_name<<6) + (y_ofs&0xF));
				
				sp_p0 = VRAM[(sp_name<<6) + (y_ofs&0xF)];
				sp_p1 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 16];
				sp_p2 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 32];
				sp_p3 = VRAM[(sp_name<<6) + (y_ofs&0xF) + 48];
				
				sp_buf[sp_nb].pri = sp_pri;
				sp_buf[sp_nb].zero = (i == 0);
				sp_buf[sp_nb].x = sp_x + ((HSW+1+HDS+1)<<3) - 32 + 16;
				
				for(k = 0; k < 16; k++) {
					int col = 0;
					UINT16 px = k;
					if (sp_hf)
						px = 15 - px;
					col |= ((sp_p0>>(15-px))&1);
					col |= ((sp_p1>>(15-px))&1)<<1;
					col |= ((sp_p2>>(15-px))&1)<<2;
					col |= ((sp_p3>>(15-px))&1)<<3;
					
					sp_buf[sp_nb].col[px] = col | (sp_pal<<4);
				}

				sp_nb++;
				if (sp_nb == 16)
					break;
			}
			// printf("y=%d sp_nb %d\n", y, sp_nb);
		
////////////////////////////////////////////////////////////////////////////////////////////		
////////////////////////////////////////////////////////////////////////////////////////////
// ==================== BACKGROUND
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
			bg_y = y - (VSW+1+VDS+2) + (BYR & 0x1FF);
			switch( bg_vs ) {
			case 0: // 32 tiles height
				bg_y = bg_y & 0xFF; // (32*8-1)
				break;
			default: // 64 tiles height
				bg_y = bg_y & 0x1FF; // (64*8-1)
				break;
			}
			
			bg_tx = (BXR & 0x3FF)>>3; // Starting tile
			/*switch( bg_hs ) {
				case 0: // 32 tiles width
					bg_tx = bg_tx & 0x1F;
					break;
				case 1: // 64 tiles width
					bg_tx = bg_tx & 0x3F;
					break;
				default: // 128 tiles width
					bg_tx = bg_tx & 0x7F;
					break;
			}*/
			bg_px = ((HSW+1+HDS+1)<<3) - ((BXR & 0x3FF)&7); // Starting position in line buffer

			for(tx = 0; tx < HDW+1+2; tx++) { // 2 extra tiles
				nt_addr = (bg_y>>3);
				switch( bg_hs ) {
					case 0: // 32 tiles width
						nt_addr <<= 5;
						nt_addr += ((bg_tx+tx) & 0x1F);
						break;
					case 1: // 64 tiles width
						nt_addr <<= 6;
						nt_addr += ((bg_tx+tx) & 0x3F);
						break;
					default: // 128 tiles width
						nt_addr <<= 7;
						nt_addr += ((bg_tx+tx) & 0x7F);
						break;
				}
				// printf("y=%d bg_y=%d tx=%d nt_addr=%08X\n", y, bg_y, tx, nt_addr);
				nt_entry = VRAM[nt_addr];
				// bg_name = nt_entry & 0x0FFF;
				bg_name = nt_entry & 0x07FF;
				bg_pal = (nt_entry >> 12) & 0x0F;
				
				bg_addr = bg_name << 4; // 4 bytes = 8 pixels = 2 words => 64 pixels = 16 words
				bg_addr += (bg_y&7);
				
				// printf("bg_pal = %d\n", bg_pal);
				
				// printf("bg_addr = %08X\n", bg_addr);
				bg_01 = VRAM[bg_addr];
				bg_23 = VRAM[bg_addr + 8];
			
				printf("BG BG_Y=%04X NT_ADDR=%04X BG_ADDR=%04X,%04X READ=%04X,%04X\n", bg_y, nt_addr, bg_addr, bg_addr+8, VRAM[bg_addr], VRAM[bg_addr+8]);
			
				// printf("bg0123(%04X (on 8 bits)) = %04X %04X\n", bg_addr<<1, bg_01, bg_23);
				for(tpx = 0; tpx < 8; tpx++) {
					int col = 0;
					col |= ( (bg_01>>(0+7-tpx)) & 1 );
					col |= ( (bg_01>>(8+7-tpx)) & 1 )<<1;
					col |= ( (bg_23>>(0+7-tpx)) & 1 )<<2;
					col |= ( (bg_23>>(8+7-tpx)) & 1 )<<3;
					// printf("bg_px=%d col=%02X vce=%03X\n", bg_px, col | (bg_pal<<4), VCE_COL[ col | (bg_pal<<4) ]);
					if ( (bg_px >= ((HSW+1+HDS+1)<<3)) && (bg_px < ((HSW+1+HDS+1+HDW+1)<<3))) {
						printf("[%d] %02X |", bg_px, col | (bg_pal<<4));
						bg_buf[bg_px] = col | (bg_pal<<4);
					}
					bg_px++;
				}
				printf("\n");
			}
			
			// Sprite/BG mix
			for( x = (HSW+1+HDS+1)<<3; x < (HSW+1+HDS+1+HDW+1)<<3; x++) {
				UINT16 bg_col = bg_buf[x];
				UINT16 sp_col = 0;
				UINT8 sp_pri = 0;
				for(k = 15; k >= 0; k--) {
					if ( (x >= sp_buf[k].x) && (x < sp_buf[k].x+16) ) {
						if (sp_buf[k].col[x - sp_buf[k].x] & 0x0F) {
							sp_col = sp_buf[k].col[x - sp_buf[k].x];
							sp_pri = sp_buf[k].pri;
						}
					}
				}
				if (sp_pri > 0) {
					line_buf[x] = sp_col | 0x100;
				} else if (bg_col & 0x0F) {
					line_buf[x] = bg_col;
				} else if (sp_col & 0x0F) {
					line_buf[x] = sp_col | 0x100;
				} else {
					line_buf[x] = 0;
				}
			
				// Clear background buffer
				bg_buf[x] = 0;
			}
			
		} else {
			// Overscan (Top/Bottom)
			for( x = (HSW+1+HDS+1)<<3; x < (HSW+1+HDS+1+HDW+1)<<3; x++) {
				line_buf[x] = 0x100;
			}
		}
		
		// Overscan (right)
		for(x = (HSW+1+HDS+1+HDW+1)<<3; x < x_max; x++) {
			line_buf[x] = 0x100;
		}
	
		// VCE + write to BMP buffer
		for(x = 0; x < x_max; x++) {
			bmp_img[y * MAX_WIDTH + x] = pce2bmp( VCE_COL[line_buf[x] & 0x1FF] );
			//printf("y=%d x=%d col=%03X aft=%02X\n", y, x, VCE_COL[line_buf[x] & 0x1FF], pce2bmp( VCE_COL[line_buf[x] & 0x1FF] ));
		}
		
	} // y
	
	
	
}