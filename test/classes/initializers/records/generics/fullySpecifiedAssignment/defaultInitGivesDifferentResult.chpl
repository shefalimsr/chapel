record MyRec {
  param field;

  proc init(param p) {
    field = p + 2;
    super.init();
  }
}
var rec: MyRec(5) = new MyRec(3);
writeln(rec.type: string);
writeln(rec.field);

