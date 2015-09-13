
typedef deliverRequest {
  chan req = [0] of {mtype, int};
  int id;
};

typedef deliverResponse {
  chan res = [0] of {mtype, int};
  int id;
  int idx;
  int idy;
  // deliverDate ???
};

typedef msg_sample {
  deliverRequest req;
  int id;
  /*deliverRequest req;*/
  deliverResponse res;
  // deliverDate ???
};

deliverRequest ch1;
deliverResponse ch2;
proctype StoreToLogistics() {
    printf("Logistics started\n");
    mtype ope;
    msg_sample exam;
    ch1.req ? ope, exam;
    printf("%d, %d\n", exam.id, ch2.idx); // var passing
    if
    :: (ope == 1) -> { printf("Get 1 %d,%d\n", exam.req.id, exam.res.id);  ch2.res ! 1; }
    fi
    printf("Logistics stoped\n");
}


proctype Workflow() {
    printf("Workflow started\n");
    run StoreToLogistics();
    msg_sample test;
    test.id = 26;
    test.req.id = 7;
    test.res.id = 6;
    ch2.idx = 9;
    ch1.req ! 1, test; // send multiple date
    mtype ope;
    ch2.res ? ope;
    printf("Workflow stoped\n");
}

init {
  printf("Purchasing\n");
  run Workflow();
}
