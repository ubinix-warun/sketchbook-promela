
typedef messageReqServAdd {
  int left;
  int right;
};

typedef messageResServOps {
  int output;
};

typedef reqServiceAdd {
  chan link = [0] of {mtype, int};
  int id;
  messageReqServAdd msg;
};

typedef resServiceAdd {
  chan link = [0] of {mtype, int};
  int id;
  messageResServOps result;
};

typedef errServiceAdd {
  chan link = [0] of {mtype, int};
  int id;
  int errcode;
};

reqServiceAdd reqAdd;
resServiceAdd resAdd;
errServiceAdd errAdd;

proctype ServiceAdd() {

  reqServiceAdd request;
  do
    :: reqAdd.link ? request -> {
      printf("()%d) %d+%d\n", request.id, request.msg.left, request.msg.right);
    };
  od


}


proctype Workflow() {
  run ServiceAdd();

  reqServiceAdd request;
  request.id = 20;
  request.msg.left = 2;;
  request.msg.right = 3;

  reqAdd.link ! request;

}

init {
  printf("Workflow...\n");
  run Workflow();
}
