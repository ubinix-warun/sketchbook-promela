#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"
#include "BuyerToStore.pml"

vars_bts argsBTS;
vars_stb argsSTB;

active proctype xyz() {

  argsBTS.b_req.id = 27;
  argsBTS.b_req.customer = 1; // ref 1 => Fred (Unknown)

  chan_bts ! MSG_TYPE_REQ_BUY, argsBTS;
  chan_stb ? MSG_TYPE_RES_BUY, argsSTB;

}

ltl p1 { (argsBTS.b_req.id == 27) -> <> (argsSTB.b_res.id == 0)}
