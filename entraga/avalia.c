#include <stdio.h>
#include "meuAlocador.h"

int main (long int argc, char** argv) {
  void *a,*b,*c,*d,*e;

  iniciaAlocador(); 
  imprimeMapa();
  printf("\n\n\n");
  // 0) estado inicial

  a=(void *) alocaMem(100);
  imprimeMapa();
  b=(void *) alocaMem(130);
  imprimeMapa();
  c=(void *) alocaMem(120);
  imprimeMapa();
  d=(void *) alocaMem(110);
  imprimeMapa();
  printf ("\n\n\n");
  // 1) Espero ver quatro segmentos ocupados

  liberaMem(b);
  imprimeMapa(); 
  liberaMem(d);
  imprimeMapa(); 
  printf("\n\n\n");
  // 2) Espero ver quatro segmentos alternando
  //    ocupados e livres

  b=(void *) alocaMem(50);
  imprimeMapa();
  d=(void *) alocaMem(90);
  imprimeMapa();
  e=(void *) alocaMem(40);
  imprimeMapa();
  printf("\n\n\n");
  // 3) Deduzam
	
  liberaMem(c);
  imprimeMapa(); 
  liberaMem(a);
  imprimeMapa();
  liberaMem(b);
  imprimeMapa();
  liberaMem(d);
  imprimeMapa();
  liberaMem(e);
  imprimeMapa();
  printf("\n\n\n");
   // 4) volta ao estado inicial

  finalizaAlocador();
}
