// ...

proctype Workflow() {
    printf("Workflow started\n");

    printf("Workflow stoped\n");
}

init {
  printf("Purchasing\n");
  run Workflow();
}
