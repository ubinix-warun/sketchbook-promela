typedef checkCreditRequestVar {
  int id;
  int customer; // customer (string)
};

typedef checkCreditResponseVar {
  int id;
  int rating;
};

// FaultVar ...
typedef customerUnknownFaultVar {
  int id;
};

chan chan_xtem = [0] of {mtype, int};
proctype ExceptionManager(int scope) {
  // faultName
  // variable
  if
  :: (scope == 1) -> ; // STA "CustomerUnknown"
    customerUnknownFaultVar faultVar;
    chan_xtem ? faultVar;
    printf("CustomeUnknown %d\n",faultVar.id);
  fi

}

chan chan_sta = [0] of {mtype, int};
chan chan_ats = [0] of {mtype, int};
proctype StoreToCreditAgency() { // STA.
      printf("STA. started\n");

      checkCreditRequestVar reqSTA;
      checkCreditResponseVar resSTA;
      customerUnknownFaultVar resSTA_NOF;

      chan_sta ? reqSTA;

      if
      :: (reqSTA.customer != 1) -> ; // 1 = Fred
        resSTA.id = reqSTA.id;
        resSTA.rating = 7;
        chan_ats ! resSTA;
      :: else -> ;
        resSTA_NOF.id = reqSTA.id;
        run ExceptionManager(1);
        chan_xtem ! resSTA_NOF; // throw "CustomerUnknown"
      fi

      printf("STA. stoped\n");
}
