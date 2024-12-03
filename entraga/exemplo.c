#include <stdio.h>
#include "meuAlocador.h"

int main (){
  void *a, *b, *c, *d;

  iniciaAlocador();               // Impressão esperada
  imprimeMapa();                  // <vazio>

  a = (void *) alocaMem(50);
  imprimeMapa();                  // ################**********
  b = (void *) alocaMem(10);
  imprimeMapa();
  c = (void*) alocaMem (100);
  liberaMem (a);
 imprimeMapa();
  liberaMem (b);
imprimeMapa();
  liberaMem(c);
imprimeMapa();
  b = (void *)alocaMem(10);

  



  imprimeMapa();                  // ################**********##############****
  liberaMem(b);
  imprimeMapa();                  // ################----------##############****
  //liberaMem(b);                   // ################----------------------------
                                  // ou
                                  // <vazio>
  finalizaAlocador();

  return 0;
}
