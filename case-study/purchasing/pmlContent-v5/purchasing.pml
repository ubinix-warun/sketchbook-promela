//#include "StoreToLogistics.pml"

#define MSG_TYPE_REQ_DELIVER 0
#define MSG_TYPE_RES_DELIVER 1

typedef deliverRequestVar {
  int id;
};
typedef deliverResponseVar {
  int id;
  // deliverDate ???
};

// ----------------------------------------------
typedef vars_stl {
  deliverRequestVar d_req;
}
typedef vars_lts {
  deliverResponseVar d_res;
}
chan chan_stl = [0] of {mtype, int, vars_stl};
chan chan_lts = [0] of {mtype, int, vars_lts};
// ----------------------------------------------

active proctype StoreToLogistics() { // STL.
    printf("STL. started\n");

    do
    ::
      vars_stl recv_vars;
      vars_lts repy_vars;

      chan_stl ? MSG_TYPE_REQ_DELIVER, recv_vars;

      printf(" > reqWithId = \"%d\"\n",recv_vars.d_req.id);
      repy_vars.d_res.id = recv_vars.d_req.id;
      //resSTL.date = ""; // sample process
      printf(" > resWithId = \"%d\"\n",repy_vars.d_res.id);

      chan_lts ! MSG_TYPE_RES_DELIVER, repy_vars;
    od;

    printf("STL. stoped\n");
}

//#include "StoreToCreditAgency.pml"

#define MSG_TYPE_REQ_CREDIT 0
#define MSG_TYPE_RES_CREDIT 1

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
chan chan_stca = [0] of {mtype, int, vars_stca};
chan chan_cats = [0] of {mtype, int, vars_cats};
// ----------------------------------------------

proctype StoreToCreditAgency() { // STA.
    printf("STCA. started\n");

    do
    ::
      vars_stca recv_vars;
      vars_cats repy_vars;

      chan_stca ? MSG_TYPE_REQ_CREDIT, recv_vars;

      if
      :: (recv_vars.c_req.customer != 1) -> ; // 1 = Fred

        printf(" > reqWithId = \"%d\" and !Fred\n",recv_vars.c_req.id);
        repy_vars.c_res.id = recv_vars.c_req.id;
        repy_vars.c_res.rating = 7;
        printf(" > resWithId = \"%d\" and rating =\"%d\"\n",
          repy_vars.c_res.id, repy_vars.c_res.rating);

        chan_cats ! MSG_TYPE_RES_CREDIT, repy_vars;

      :: else -> ;

        printf(" > reqWithId = \"%d\" and isFred\n",recv_vars.c_req.id);
        repy_vars.u_fault.id = recv_vars.c_req.id;
        printf(" > resWithId = \"%d\" by \"CustomerUnknown\"\n", repy_vars.u_fault.id);

        chan_cats ! MSG_TYPE_RES_CREDIT, repy_vars;

      fi
    od;

    printf("STCA. stoped\n");
}

//#include "BuyerToStore.pml"


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

vars_stca argsSTCA;
vars_cats argsCATS;

active proctype BuyerToStore() {
    printf("BTS started\n");

    do
    ::
      vars_bts recv_vars;
      vars_stb repy_vars;

      chan_bts ? MSG_TYPE_REQ_BUY, recv_vars;

      run StoreToCreditAgency();

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
    od;

    printf("BTS stoped\n");
}


vars_bts argsBTS;
vars_stb argsSTB;

int test

active proctype xyz() {

  argsBTS.b_req.id = 27;
  argsBTS.b_req.customer = 0; // ref 1 => Fred (Unknown)

  test = 6;

  chan_bts ! MSG_TYPE_REQ_BUY, argsBTS;
  chan_stb ? MSG_TYPE_RES_BUY, argsSTB;

}

// spin -a pmlContent-v5/purchasing.pml
// gcc -o  pan pan.c // SAFETY?
// ./pan -a -N p1

//ltl p1 { (argsBTS.b_req.id == 27) -> <> (argsCATS.c_res.rating == 7)}
//ltl p2 { (argsBTS.b_req.id == 27) -> <> (argsCATS.c_res.rating == 0)}
//ltl p3 { !(argsBTS.b_req.id == 27) }
