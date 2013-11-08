#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char **argv)
{	
	FILE *fp;
	int i, j;
	
	//long voltab[32][32*3];
	long voltab[32][128];
	
	for(i = 0; i < 32; i++) {
		// long sample = (i - 16)<<(21-5);
		
		// double step = (double)((1<<21)-1) / (double)31;
		double step = (double)((1<<24)-1) / (double)31 / (double)6;
		long sample = (long)( (double)(i - 15.5) * step ); 
		
		printf("\nSAMPLE %02X : %d %06X\n", i, sample, sample & ((1<<24)-1) );
	
		for(j = 0; j < 32*3; j++) {
			//double att = pow( (double)10, (double)( j ) * -(double)0.15 );
			double att = pow( (double)10, (double)( j ) * -(double)0.07 );
			long final = (long)( (double)sample * att );
			printf("%d %06X\n", final, final & ((1<<24)-1));
			voltab[i][j] = final;
		}
		for(j = 32*3; j<128; j++) {
			voltab[i][j] = 0;
		}
	}
	
	int a = 0;
	fp = fopen("voltab.mif","wb");
	fprintf(fp, "WIDTH = 24;\n");
	fprintf(fp, "DEPTH = 4096;\n");
	fprintf(fp, "ADDRESS_RADIX = HEX;\n");
	fprintf(fp, "DATA_RADIX = HEX;\n");
	fprintf(fp, "CONTENT\n");
	fprintf(fp, "BEGIN\n");
	for(i = 0; i < 32; i++) {
		for(j = 0; j < /*32*3*/ 128; j++) {
			fprintf(fp,"%04X : %06X;\n", a++, voltab[i][j] & ((1<<24)-1));
		}
	}
	while(a < 4096) {
		fprintf(fp,"%04X : %06X;\n", a++, 0);
	}
	fprintf(fp, "END;\n");
	fclose(fp);

	return 0;
}
