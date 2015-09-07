#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"

proctype Workflow() {
    printf("Workflow started\n");

    deliverRequestVar reqSTL;
    deliverResponseVar resSTL;

/*
    run StoreToLogistics();

    reqSTL.id = 99;
    chan_stl ! reqSTL;
    chan_lts ? resSTL;
*/

    // ...

    checkCreditRequestVar reqSTA;
    checkCreditResponseVar resSTA;

    run StoreToCreditAgency();

    reqSTA.id = 27;
    reqSTA.customer = 2; // ref '1' to 'FRED'

    chan_sta ! reqSTA;
    chan_ats ? resSTA;

    if
    :: (resSTA.rating > 5) -> ;
      run StoreToLogistics();

      reqSTL.id = 28;
      chan_stl ! reqSTL;
      chan_lts ? resSTL;
    fi

    printf("Workflow stoped\n");
}

init {
  printf("Purchasing\n");
  run Workflow();
}
