#include <stdio.h>
#include "meuAlocador.h"

int main (){
  void *a, *b, *c, *d;

  iniciaAlocador();               // Impressão esperada
  imprimeMapa();                  // <vazio>

  a = (void *) alocaMem(5000);
  //imprimeMapa();                  // ################**********
  b = (void *) alocaMem(10);

  liberaMem (a);
  liberaMem (b);
  a = (void *)alocaMem(10);

  



  imprimeMapa();                  // ################**********##############****
  liberaMem(a);
  imprimeMapa();                  // ################----------##############****
  //liberaMem(b);                   // ################----------------------------
                                  // ou
                                  // <vazio>
  finalizaAlocador();

  return 0;
}
