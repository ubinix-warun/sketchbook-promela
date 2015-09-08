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
chan chan_stl = [0] of {mtype, int};
chan chan_lts = [0] of {mtype, int};
// ----------------------------------------------

proctype StoreToLogistics() { // STL.
    printf("STL. started\n");

    vars_stl recv_vars;
    vars_lts repy_vars;

    chan_stl ? recv_vars;

    printf(" > reqWithId = \"%d\"\n",recv_vars.d_req.id);
    repy_vars.d_res.id = recv_vars.d_req.id;
    //resSTL.date = ""; // sample process
    printf(" > resWithId = \"%d\"\n",repy_vars.d_res.id);

    chan_lts ! repy_vars;

    printf("STL. stoped\n");
}
