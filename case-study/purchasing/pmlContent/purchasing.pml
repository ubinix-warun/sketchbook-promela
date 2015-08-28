
typedef deliverRequestVar {
  int id;
};

typedef deliverResponseVar {
  int id;
  // deliverDate ???
};

chan chan_stl = [0] of {mtype, int};
chan chan_lts = [0] of {mtype, int};
proctype StoreToLogistics() { // STL.
    printf("STL. started\n");

    deliverRequestVar reqSTL;
    deliverResponseVar resSTL;

    chan_stl ? reqSTL;

    printf(" > reqWithId = \"%d\"\n",reqSTL.id);
    resSTL.id = reqSTL.id;
    //resSTL.date = ""; // sample process
    printf(" > resWithId = \"%d\"\n",reqSTL.id);

    chan_lts ! resSTL;

    printf("STL. stoped\n");
}

typedef checkCreditRequestVar {
  int id;
  int customer; // customer (string)
};

typedef checkCreditResponseVar {
  int id;
  int rating;
};

/*typedef customerUnknownFaultVar {
  int id;
};*/

chan chan_sta = [0] of {mtype, int};
chan chan_ats = [0] of {mtype, int};
proctype StoreToCreditAgency() { // STA.
      printf("STA. started\n");

      checkCreditRequestVar reqSTA;
      checkCreditResponseVar resSTA;
      /*customerUnknownFaultVar resSTA_NOF;*/

      chan_sta ? reqSTA;

      if
      :: (reqSTA.customer != 1) -> ;
        resSTA.id = reqSTA.id;
        resSTA.rating = 7;
        chan_ats ! resSTA;
      :: else -> ;
      // else throw!!!
      fi

      printf("STA. stoped\n");
}

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
