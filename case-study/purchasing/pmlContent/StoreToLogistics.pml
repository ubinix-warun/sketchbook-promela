typedef deliverRequestVar {
  int id;
};

typedef deliverResponseVar {
  int id;
  // deliverDate ???
};

chan chan_stl = [0] of {mtype, int};
chan chan_lts = [0] of {mtype, int};
proctype StoreToLogistics() { // STL.
    printf("STL. started\n");

    deliverRequestVar reqSTL;
    deliverResponseVar resSTL;

    chan_stl ? reqSTL;

    printf(" > reqWithId = \"%d\"\n",reqSTL.id);
    resSTL.id = reqSTL.id;
    //resSTL.date = ""; // sample process
    printf(" > resWithId = \"%d\"\n",reqSTL.id);

    chan_lts ! resSTL;

    printf("STL. stoped\n");
}
