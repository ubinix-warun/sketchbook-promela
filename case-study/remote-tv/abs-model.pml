
// TODO array mapping ... 1=>11

chan chan_ir = [0] of {mtype, int};

proctype RemoteInferace(int id) {
  printf("Remote's Active\n");
  // TODO switch id => cmd
  run TelevisionIR();
  chan_ir ! 11
}

proctype TelevisionIR() {
  printf("TelevisionIR's Ok\n");

  int cmd = 0;
  chan_ir ? cmd;

  // TODO if cmd == 11, toggle power-flag


}

// TODO LTL ?
//  p = power-flag's on
//  q = push power-toggle, ~p

init {
  printf("remote-tv\n");
  run RemoteInferace(1); // first-button, power-toggle
}
