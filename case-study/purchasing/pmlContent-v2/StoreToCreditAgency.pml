typedef checkCreditRequestVar {
  int id;
  int customer; // customer (string)
};

typedef checkCreditResponseVar {
  int id;
  int rating;
};

typedef customerUnknownFaultVar {
  int id;
};

// ----------------------------------------------
typedef vars_stca {
  checkCreditRequestVar c_req;
}
typedef vars_cats {
  checkCreditResponseVar c_res;
  customerUnknownFaultVar u_fault;
}
chan chan_stca = [0] of {mtype, int};
chan chan_cats = [0] of {mtype, int};
// ----------------------------------------------

proctype StoreToCreditAgency() { // STA.
      printf("STCA. started\n");

      vars_stca recv_vars;
      vars_cats repy_vars;

      chan_stca ? recv_vars;

      if
      :: (recv_vars.c_req.customer != 1) -> ; // 1 = Fred

        printf(" > reqWithId = \"%d\" and !Fred\n",recv_vars.c_req.id);
        repy_vars.c_res.id = recv_vars.c_req.id;
        repy_vars.c_res.rating = 7;
        printf(" > resWithId = \"%d\" and rating =\"%d\"\n",
          repy_vars.c_res.id, repy_vars.c_res.rating);

        chan_cats ! repy_vars;

      :: else -> ;

        printf(" > reqWithId = \"%d\" and isFred\n",recv_vars.c_req.id);
        repy_vars.u_fault.id = recv_vars.c_req.id;
        printf(" > resWithId = \"%d\" by \"CustomerUnknown\"\n", repy_vars.u_fault.id);

        chan_cats ! repy_vars;

      fi

      printf("STCA. stoped\n");
}
