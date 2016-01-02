#include "StoreToLogistics.pml"
#include "StoreToCreditAgency.pml"
#include "BuyerToStore.pml"

vars_bts argsBTS;
vars_stb argsSTB;

active proctype xyz() {

  argsBTS.b_req.id = 27;
  argsBTS.b_req.customer = 0; // ref 1 => Fred (Unknown)

  chan_bts ! MSG_TYPE_REQ_BUY, argsBTS;
  chan_stb ? MSG_TYPE_RES_BUY, argsSTB;

}

// spin -a pmlContent-v4/purchasing.pml
// gcc -o  pan pan.c // SAFETY?
// ./pan -a -N p1

// have problem to access argsCATS?
//ltl p1 { (argsBTS.b_req.id == 27) -> <> (argsCATS.c_res.rating == 7)}
