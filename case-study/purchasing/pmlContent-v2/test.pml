#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"
#include "BuyerToStore.pml"

proctype Testflow_STL_RequestId27() {
    printf("Testflow_STL_RequestId27 ... started\n");

    run StoreToLogistics();

    vars_stl reqSTL;
    vars_lts resSTL;

    reqSTL.d_req.id = 27;

    chan_stl ! reqSTL;
    chan_lts ? resSTL;

    assert(resSTL.d_res.id == 27);

    printf("Testflow_STL_RequestId27 ... stoped\n");
}

proctype Testflow_STCA_RequestWithNotFred() {
    printf("Testflow_STCA_RequestWithNotFred ... started\n");

    run StoreToCreditAgency();

    vars_stca reqSTCA;
    vars_cats resSTCA;

    reqSTCA.c_req.id = 27;
    reqSTCA.c_req.customer = 2; // 1 Fred

    chan_stca ! reqSTCA;
    chan_cats ? resSTCA;

    assert(resSTCA.c_res.id == 27);

    printf("Testflow_STCA_RequestWithNotFred ... stoped\n");
}

proctype Testflow_STCA_RequestWithFred() {
    printf("Testflow_STCA_RequestWithFred ... started\n");

    run StoreToCreditAgency();

    vars_stca reqSTCA;
    vars_cats resSTCA;

    reqSTCA.c_req.id = 27;
    reqSTCA.c_req.customer = 1; // 1 Fred

    chan_stca ! reqSTCA;
    chan_cats ? resSTCA;

    assert(resSTCA.c_res.id == 0);
    /*assert(resSTCA.u_fault.id == 27);*/

    printf("Testflow_STCA_RequestWithFred ... stoped\n");
}

proctype Testflow_BTS_RequestWithNotFred() {
    printf("Testflow_BTS_RequestWithNotFred ... started\n");

    run BuyerToStore();

    vars_bts reqBTS;
    vars_stb resBTS;

    reqBTS.b_req.id = 27;
    reqBTS.b_req.customer = 2; // ref 1 => Fred (Unknown)

    chan_bts ! reqBTS;
    chan_stb ? resBTS;

    // Confirm ?
    assert(resBTS.b_res.id == 27);

    printf("Testflow_BTS_RequestWithNotFred ... stoped\n");
}

proctype Testflow_BTS_RequestWithFred() {
    printf("Testflow_BTS_RequestWithFred ... started\n");

    run BuyerToStore();

    vars_bts reqBTS;
    vars_stb resBTS;

    reqBTS.b_req.id = 27;
    reqBTS.b_req.customer = 1; // ref 1 => Fred (Unknown)

    chan_bts ! reqBTS;
    chan_stb ? resBTS;

    // Fail ?
    assert(resBTS.b_res.id == 0);
    /*assert(resBTS.n_fault.id == 27);
    assert(resBTS.b_fault.id == 27);*/

    printf("Testflow_BTS_RequestWithFred ... stoped\n");
}

        /*printf(" ! throw \"CustomerUnknown\" to ExceptionManager\n");*/

        /*run ExceptionManager(1);
        chan_xtem ! resSTCA_NOF; // throw "CustomerUnknown"*/

init {
  printf("Testing\n");
  /*run Testflow_STL_RequestId27();*/
  /*run Testflow_STCA_RequestWithNotFred();*/
  /*run Testflow_STCA_RequestWithFred(); // Have problem to send "multiple-var" */
  /*run Testflow_BTS_RequestWithNotFred();*/
  /*run Testflow_BTS_RequestWithFred(); // Have problem to send "multiple-var"*/

}
