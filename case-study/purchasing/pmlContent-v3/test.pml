#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"
#include "BuyerToStore.pml"

proctype Testflow_STL_RequestId27() {
    printf("Testflow_STL_RequestId27 ... started\n");

    run StoreToLogistics();

    vars_stl argsSTL;
    vars_lts argsLTS;

    argsSTL.d_req.id = 27;

    chan_stl ! MSG_TYPE_REQ_DELIVER, argsSTL;
    chan_lts ? MSG_TYPE_RES_DELIVER, argsLTS;

    assert(argsLTS.d_res.id == 27);

    printf("Testflow_STL_RequestId27 ... stoped\n");
}

proctype Testflow_STCA_RequestWithNotFred() {
    printf("Testflow_STCA_RequestWithNotFred ... started\n");

    run StoreToCreditAgency();

    vars_stca argsSTCA;
    vars_cats argsCATS;

    argsSTCA.c_req.id = 27;
    argsSTCA.c_req.customer = 2; // 1 Fred

    chan_stca ! MSG_TYPE_REQ_CREDIT, argsSTCA;
    chan_cats ? MSG_TYPE_RES_CREDIT, argsCATS;

    assert(argsCATS.c_res.id == 27);

    printf("Testflow_STCA_RequestWithNotFred ... stoped\n");
}

proctype Testflow_STCA_RequestWithFred() {
    printf("Testflow_STCA_RequestWithFred ... started\n");

    run StoreToCreditAgency();

    vars_stca argsSTCA;
    vars_cats argsCATS;

    argsSTCA.c_req.id = 27;
    argsSTCA.c_req.customer = 1; // 1 Fred

    chan_stca ! MSG_TYPE_REQ_CREDIT, argsSTCA;
    chan_cats ? MSG_TYPE_RES_CREDIT, argsCATS;

    assert(argsCATS.c_res.id == 0);
    assert(argsCATS.u_fault.id == 27);

    printf("Testflow_STCA_RequestWithFred ... stoped\n");
}

proctype Testflow_BTS_RequestWithNotFred() {
    printf("Testflow_BTS_RequestWithNotFred ... started\n");

    run BuyerToStore();

    vars_bts argsBTS;
    vars_stb argsSTB;

    argsBTS.b_req.id = 27;
    argsBTS.b_req.customer = 2; // ref 1 => Fred (Unknown)

    chan_bts ! MSG_TYPE_REQ_BUY, argsBTS;
    chan_stb ? MSG_TYPE_RES_BUY, argsSTB;

    // Confirm ?
    assert(argsSTB.b_res.id == 27);

    printf("Testflow_BTS_RequestWithNotFred ... stoped\n");
}

proctype Testflow_BTS_RequestWithFred() {
    printf("Testflow_BTS_RequestWithFred ... started\n");

    run BuyerToStore();

    vars_bts argsBTS;
    vars_stb argsSTB;

    argsBTS.b_req.id = 27;
    argsBTS.b_req.customer = 1; // ref 1 => Fred (Unknown)

    chan_bts ! MSG_TYPE_REQ_BUY, argsBTS;
    chan_stb ? MSG_TYPE_RES_BUY, argsSTB;

    // Fail ?
    assert(argsSTB.b_res.id == 0);
    assert(argsSTB.n_fault.id == 27);

    printf("Testflow_BTS_RequestWithFred ... stoped\n");
}

init {
  printf("Testing\n");
  /*run Testflow_STL_RequestId27();*/
  /*run Testflow_STCA_RequestWithNotFred();*/
  /*run Testflow_STCA_RequestWithFred();*/
  /*run Testflow_BTS_RequestWithNotFred();*/
  run Testflow_BTS_RequestWithFred();
  /* Testflow_BTS_RequestWithKate (Kate's Credit <= 5)*/

}
