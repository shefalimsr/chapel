record Foo {
  type t;
  var x;

  proc init(xVal) where !xVal: Foo {
    this.init(xVal.type, xVal);
  }

  proc init(type tVal, xVal) {
    t = tVal;
    x = xVal;
    super.init();
  }
}

var foo = new Foo(2);
writeln(foo.type: string);
writeln(foo);
