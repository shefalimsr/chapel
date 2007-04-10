use Sort;

module CGMakeA {

  use Random;

  config const rcond = 0.1;

  iterator makea(type elemType, n, nonzer, shift) {
    var v: [1..nonzer+1] elemType, // BLC: insert domains? or grow as necessary?
        iv: [1..nonzer+1] int;

    var size = 1.0;
    const ratio = rcond ** (1.0 / n);

    var randStr = RandomStream(314159265);
    randStr.getNext();   // drop a value on floor to match NPB version

    for iouter in 1..n {
      var nzv = nonzer;

      sprnvc(elemType, n, nzv, v, iv, randStr);
      vecset(v, iv, nzv, iouter, 0.50);

      // BLC: replace with zippered loop over iv or iv(1..nzv)?
      for ivelt in 1..nzv {
        const jcol = iv(ivelt),
              scale = size * v(ivelt);

        // BLC: replace with zippered loop over iv or iv(1..nzv)?
        for ivelt1 in 1..nzv {
          const irow = iv(ivelt1);

          yield ((irow, jcol), v(ivelt1)*scale);
        }
      }
      size *= ratio;
    }

    for i in 1..n {
      yield ((i, i), rcond - shift);
    }
  }


  iterator genAInds(type elemType, n, nonzer, shift) {
    for (ind, val) in makea(elemType, n, nonzer, shift) {
      yield ind;
    }
  }

  def <(x:2*int, y:2*int) {
    if (x(1) < y(1)) {
      return true;
    } else if (x(1) > y(1)) {
      return false;
    } else {
      return (x(2) < y(2));
    }
  }


  def >(x:2*int, y:2*int) {
    if (x(1) > y(1)) {
      return true;
    } else if (x(1) < y(1)) {
      return false;
    } else {
      return (x(2) > y(2));
    }
  }


  iterator genAIndsSorted(type elemType, n, nonzer, shift) {
    // build associative domain of indices
    var Inds: domain(index(2));
    for i in genAInds(elemType, n, nonzer, shift) {
      Inds += i;
    }
    //  writeln("Inds is: ", Inds);

    // copy into arithmetic domain/array
    var IndArr: [1..Inds.numIndices] index(2);
    for (i,j) in (Inds, 1..) {
      IndArr[j] = i;
    }
    //  writeln("IndArr is: ", IndArr);

    // sort indices
    QuickSort(IndArr);

    //  writeln("After sort, IndArr is: ", IndArr);
    
    for i in IndArr {
      yield i;
    }

    // TODO: should "free" local domains/arrays here by making degenerate
  }


  def sprnvc(type elemType, n, nz, v, iv, randStr) {
    var nn1 = 1;
    while (nn1 < n) do nn1 *= 2;

    var indices: domain(int);

    for nzv in 1..nz {
      var vecelt: elemType, 
          ind: int;

      do {
        vecelt = randStr.getNext();
        ind = (randStr.getNext() * nn1):int + 1;
      } while (ind > n || indices.member?(ind));

      v(nzv) = vecelt;
      iv(nzv) = ind;
      indices += ind;
    }
  }


  def vecset(v, iv, inout nzv, i, val) {
    var set = false;
    for k in 1..nzv {
      if (iv(k) == i) {
        v(k) = val;
        set = true;
      }
    }
    if (!set) {
      nzv += 1;
      v(nzv) = val;
      iv(nzv) = i;
    }
  }
}
