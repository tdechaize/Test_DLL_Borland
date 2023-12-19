//*********************  File : ProgCode.cpp (program main test of dll, with load implicit)  *****************
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include "dllcode.h"

/* pragma suppresses "calling argument not used" warnings during compilation */
#pragma argsused

int main(int argc, char** argv)
{
	int  aa,bb,cc;
	aa = 4;
	bb = 7;

	cc = Add(aa, bb);

	printf("La somme de %i plus %i vaut %i. (from application %s)\n", aa, bb, cc, argv[0]);

	cc = Multiply(aa, bb);

	printf("Le produit de %i par %i vaut %i. (from application %s)\n", aa, bb, cc, argv[0]);

	return EXIT_SUCCESS;
}
// ****************************************   End ProgCode.cpp   *********************************************
