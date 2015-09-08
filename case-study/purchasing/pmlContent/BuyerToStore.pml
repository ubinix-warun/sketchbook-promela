#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"

typedef buyRequestVar {
  int id;
  int customer; // customer (string)
};

typedef buyResponseVar {
  int id;
};

chan chan_bts = [0] of {mtype, int};
chan chan_stb = [0] of {mtype, int};
proctype BuyerToStore() {
    printf("BTS started\n");

    buyRequestVar reqBTS;
    buyResponseVar resSTB;

    chan_bts ? reqBTS;

    checkCreditRequestVar reqSTCA;
    checkCreditResponseVar resSTCA;
    customerUnknownFaultVar resSTCA_NOF;
    resSTCA_NOF.id = 22

    run StoreToCreditAgency();

    reqSTCA.id = reqBTS.id;
    reqSTCA.customer = reqBTS.customer; // ref '1' to 'FRED'

    chan_stca ! reqSTCA;
    chan_cats ? resSTCA, resSTCA_NOF;

    deliverRequestVar reqSTL;
    deliverResponseVar resSTL;


    if
    :: (resSTCA.rating > 5) -> ;
      run StoreToLogistics();

      reqSTL.id = resSTCA.id;
      chan_stl ! reqSTL;
      chan_lts ? resSTL;

      resSTB.id = resSTL.id;
      chan_stb ! resSTB;

    :: else -> ;
      // TODO throw BuyFailed
      printf("BuyFailed\n");
    fi unless {
      (resSTCA_NOF.id != 0) -> ;
        printf(">>> CustomerUnknown %d\n",resSTCA_NOF.id);
      }


    printf("BTS stoped\n");
}
