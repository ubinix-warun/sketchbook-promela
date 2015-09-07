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
