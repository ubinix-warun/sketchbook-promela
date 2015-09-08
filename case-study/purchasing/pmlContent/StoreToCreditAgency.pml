typedef checkCreditRequestVar {
  int id;
  int customer; // customer (string)
};

typedef checkCreditResponseVar {
  int id;
  int rating;
};


chan chan_stca = [0] of {mtype, int};
chan chan_cats = [0] of {mtype, int};

// --------------------------------------------------
// FaultVar ...
typedef customerUnknownFaultVar {
  int id;
};

chan chan_xtem = [0] of {mtype, int};
proctype ExceptionManager(int scope) {
  // faultName
  // variable
  if
  :: (scope == 1) -> ; // STCA "CustomerUnknown"
    checkCreditResponseVar resSTA;
    customerUnknownFaultVar resSTA_NOF;
    chan_xtem ? resSTA_NOF;
    printf(" ! CustomeUnknown %d\n",resSTA_NOF.id);
    chan_cats ! resSTA, resSTA_NOF;
  fi

}
// --------------------------------------------------

proctype StoreToCreditAgency() { // STA.
      printf("STCA. started\n");

      checkCreditRequestVar reqSTCA;
      checkCreditResponseVar resSTCA;
      customerUnknownFaultVar resSTCA_NOF;

      chan_stca ? reqSTCA;

      if
      :: (reqSTCA.customer != 1) -> ; // 1 = Fred

        printf(" > reqWithId = \"%d\" and !Fred\n",reqSTCA.id);
        resSTCA.id = reqSTCA.id;
        resSTCA.rating = 7;
        printf(" > resWithId = \"%d\" and rating =\"%d\"\n", reqSTCA.id, resSTCA.rating);

        chan_cats ! resSTCA, resSTCA_NOF;

      :: else -> ;

        printf(" > reqWithId = \"%d\" and isFred\n",reqSTCA.id);
        resSTCA_NOF.id = reqSTCA.id;
        printf(" ! throw \"CustomerUnknown\" to ExceptionManager\n");

        run ExceptionManager(1);
        chan_xtem ! resSTCA_NOF; // throw "CustomerUnknown"

      fi

      printf("STCA. stoped\n");
}
