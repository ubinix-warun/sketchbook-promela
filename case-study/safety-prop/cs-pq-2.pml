#define mutex (critical <= 1)

bool wantP = false, wantQ = false;
int critical

// critical section problem

active proctype P() {
  do :: wantP = true;
        !wantQ;
        critical++;
        critical--;
        wantP = false
  od
}

active proctype Q() {
  do :: wantQ = true;
        !wantP;
        critical++;
        critical--;
        wantQ = false;
  od
}

ltl p1 { ![]mutex }
