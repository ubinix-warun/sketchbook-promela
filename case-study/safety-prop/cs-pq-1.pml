bool wantP = false, wantQ = false;

// critical section problem

active proctype P() {
  do :: wantP = true;
        !wantQ;
        wantP = false
  od
}

active proctype Q() {
  do :: wantQ = true;
        !wantP;
        wantQ = false;
  od
}
