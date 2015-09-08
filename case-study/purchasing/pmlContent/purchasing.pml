#include "BuyerToStore.pml"

proctype Workflow() {
    printf("Workflow started\n");

    run BuyerToStore();

    buyRequestVar reqBTS;
    buyResponseVar resBTS;

    reqBTS.id = 27;
    reqBTS.customer = 2; // ref 1 => Fred (Unknown)

    chan_bts ! reqBTS
    chan_stb ? resBTS;



    printf("Workflow stoped\n");
}

init {
  printf("Purchasing\n");
  run Workflow();
}
