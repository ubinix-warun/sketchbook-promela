

mtype = { MSG_TYPE_REQ_DELIVER, MSG_TYPE_RES_DELIVER,
            MSG_TYPE_REQ_CREDIT, MSG_TYPE_RES_CREDIT,
            MSG_TYPE_REQ_BUY, MSG_TYPE_RES_BUY,

          MSG_TYPE_EXCEPTION_U};

// ----------------------------------------------

typedef deliverRequestVar {
  int id;
};

typedef deliverResponseVar {
  int id;
  // deliverDate ???
};

typedef vars_stl {
  deliverRequestVar d_req;
}

typedef vars_lts {
  deliverResponseVar d_res;
}

chan chan_stl = [0] of {mtype}
chan chan_lts = [0] of {mtype};

vars_stl req_stl;
vars_lts res_lst;

proctype StoreToLogistics() {

  printf("STL. running\n");

  chan_stl ? MSG_TYPE_REQ_DELIVER;

  printf(" > reqWithId = \"%d\"\n",req_stl.d_req.id);
  res_lst.d_res.id = req_stl.d_req.id;
  //resSTL.date = ""; // sample process
  printf(" > resWithId = \"%d\"\n",res_lst.d_res.id);

  chan_lts ! MSG_TYPE_RES_DELIVER;

  printf("STL. end\n");

}

// ----------------------------------------------

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

typedef vars_stca {
  checkCreditRequestVar c_req;
}

typedef vars_cats {
  checkCreditResponseVar c_res;
  customerUnknownFaultVar u_fault;
}

chan chan_stca = [0] of {mtype};
chan chan_cats = [0] of {mtype};

vars_stca req_stca;
vars_cats res_cats;

proctype StoreToCreditAgency() { // STA.
    printf("STCA. running\n");

    chan_stca ? MSG_TYPE_REQ_CREDIT;

    if
    :: (req_stca.c_req.customer != 1) -> ; // 1 = Fred

      printf(" > reqWithId = \"%d\" and !Fred\n",req_stca.c_req.id);
      res_cats.c_res.id = req_stca.c_req.id;
      res_cats.c_res.rating = 7;
      printf(" > resWithId = \"%d\" and rating =\"%d\"\n",
        res_cats.c_res.id, res_cats.c_res.rating);

      chan_cats ! MSG_TYPE_RES_CREDIT;

    :: else -> ;

      printf(" > reqWithId = \"%d\" and isFred\n",req_stca.c_req.id);
      res_cats.u_fault.id = req_stca.c_req.id;
      printf(" > resWithId = \"%d\" by \"CustomerUnknown\"\n", res_cats.u_fault.id);

      chan_cats ! MSG_TYPE_RES_CREDIT;

    fi

    printf("STCA. end\n");
}

// ----------------------------------------------

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

typedef vars_bts {
  buyRequestVar b_req;
}

typedef vars_stb {
  buyResponseVar b_res;
  accountNotFoundFaultVar n_fault;
  buyFailedFaultVar b_fault;
}

chan chan_bts = [0] of {mtype};
chan chan_stb = [0] of {mtype};

vars_bts req_bts;
vars_stb res_stb;

chan chan_stem_s = [0] of {mtype};
customerUnknownFaultVar u_fault;

proctype ExceptionManager_Store() {

  chan_stem_s ? MSG_TYPE_EXCEPTION_U;

  printf(">>> CustomerUnknown %d\n",u_fault.id);

  res_stb.n_fault.id = u_fault.id;

  chan_stb ! MSG_TYPE_RES_BUY;

}

proctype BuyerToStore() {
    printf("BTS running\n");

    chan_bts ? MSG_TYPE_REQ_BUY;

    run StoreToCreditAgency();

    req_stca.c_req.id = req_bts.b_req.id;
    req_stca.c_req.customer = req_bts.b_req.customer;

    chan_stca ! MSG_TYPE_REQ_CREDIT;
    chan_cats ? MSG_TYPE_RES_CREDIT;

    if
    :: (res_cats.c_res.rating > 5) -> ;
      run StoreToLogistics();

      vars_stl argsSTL;
      vars_lts argsLTS;

      req_stl.d_req.id = res_cats.c_res.id;

      chan_stl ! MSG_TYPE_REQ_DELIVER;
      chan_lts ? MSG_TYPE_RES_DELIVER;

      res_stb.b_res.id = res_lst.d_res.id;

      chan_stb ! MSG_TYPE_RES_BUY;

    :: else -> ;

      res_stb.b_fault.id = res_cats.c_res.id;

      chan_stb ! MSG_TYPE_RES_BUY;

    fi unless {
      (res_cats.u_fault.id != 0) -> ;
        run ExceptionManager_Store();

        u_fault.id = res_cats.u_fault.id;

        chan_stem_s ! MSG_TYPE_EXCEPTION_U;

      }

    printf("BTS terminated\n");
}


active proctype xyz() {

  run BuyerToStore();

  req_bts.b_req.id = 27;
  req_bts.b_req.customer = 1; // ref 1 => Fred (Unknown)

  chan_bts ! MSG_TYPE_REQ_BUY;
  chan_stb ? MSG_TYPE_RES_BUY;

}

ltl p1 { []((req_stl.d_req.id == 20) -> <> (res_lst.d_res.id == 20)) }
ltl p2 { []((req_bts.b_req.customer == 1) -> <> (u_fault.id == 1)) }
