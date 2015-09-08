
typedef buyRequestVar {
  int id;
  int customer; // customer (string)
};

typedef buyResponseVar {
  int id;
};

typedef accountNotFoundFaultVar {
  int id;
};

typedef buyFailedFaultVar {
  int id;
};

// -------------------------------------
typedef vars_bts {
  buyRequestVar b_req;
}
typedef vars_stb {
  buyResponseVar b_res;
  accountNotFoundFaultVar n_fault;
  buyFailedFaultVar b_fault;
}
chan chan_bts = [0] of {mtype, int};
chan chan_stb = [0] of {mtype, int};
// -------------------------------------

proctype BuyerToStore() {
    printf("BTS started\n");

    vars_bts recv_vars;
    vars_stb repy_vars;

    chan_bts ? recv_vars;

    run StoreToCreditAgency();

    vars_stca reqSTCA;
    vars_cats resSTCA;

    reqSTCA.c_req.id = recv_vars.b_req.id;
    reqSTCA.c_req.customer = recv_vars.b_req.customer;

    chan_stca ! reqSTCA;
    chan_cats ? resSTCA;

    if
    :: (resSTCA.c_res.rating > 5) -> ;
      run StoreToLogistics();

      vars_stl reqSTL;
      vars_lts resSTL;

      reqSTL.d_req.id = resSTCA.c_res.id;

      chan_stl ! reqSTL;
      chan_lts ? resSTL;

      repy_vars.b_res.id = resSTL.d_res.id;

      chan_stb ! repy_vars;

    :: else -> ;

      repy_vars.b_fault.id = resSTCA.c_res.id;

      chan_stb ! repy_vars;

    fi
    /*unless {
      (resSTCA_NOF.id != 0) -> ;
        printf(">>> CustomerUnknown %d\n",resSTCA_NOF.id);
      }*/

    printf("BTS stoped\n");
}
