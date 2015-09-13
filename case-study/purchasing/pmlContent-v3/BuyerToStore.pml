#define MSG_TYPE_REQ_BUY 0
#define MSG_TYPE_RES_BUY 1

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
chan chan_bts = [0] of {mtype, int, vars_bts};
chan chan_stb = [0] of {mtype, int, vars_stb};
// -------------------------------------

#define MSG_TYPE_EXCEPTION_U 1
chan chan_stem_s = [0] of {mtype, int, customerUnknownFaultVar};
proctype ExceptionManager_Store() {

  customerUnknownFaultVar u_fault;
  chan_stem_s ? MSG_TYPE_EXCEPTION_U, u_fault;

  printf(">>> CustomerUnknown %d\n",u_fault.id);

  vars_stb repy_vars;
  repy_vars.n_fault.id = u_fault.id;

  chan_stb ! MSG_TYPE_RES_BUY, repy_vars;
}

// -------------------------------------

proctype BuyerToStore() {
    printf("BTS started\n");

    vars_bts recv_vars;
    vars_stb repy_vars;

    chan_bts ? MSG_TYPE_REQ_BUY, recv_vars;

    run StoreToCreditAgency();

    vars_stca argsSTCA;
    vars_cats argsCATS;

    argsSTCA.c_req.id = recv_vars.b_req.id;
    argsSTCA.c_req.customer = recv_vars.b_req.customer;

    chan_stca ! MSG_TYPE_REQ_CREDIT, argsSTCA;
    chan_cats ? MSG_TYPE_RES_CREDIT, argsCATS;

    if
    :: (argsCATS.c_res.rating > 5) -> ;
      run StoreToLogistics();

      vars_stl argsSTL;
      vars_lts argsLTS;

      argsSTL.d_req.id = argsCATS.c_res.id;

      chan_stl ! MSG_TYPE_REQ_DELIVER, argsSTL;
      chan_lts ? MSG_TYPE_RES_DELIVER, argsLTS;

      repy_vars.b_res.id = argsLTS.d_res.id;

      chan_stb ! MSG_TYPE_RES_BUY, repy_vars;

    :: else -> ;

      repy_vars.b_fault.id = argsCATS.c_res.id;

      chan_stb ! MSG_TYPE_RES_BUY, repy_vars;

    fi unless {
      (argsCATS.u_fault.id != 0) -> ;
        run ExceptionManager_Store();
        chan_stem_s ! MSG_TYPE_EXCEPTION_U, argsCATS.u_fault;

      }

    printf("BTS stoped\n");
}
