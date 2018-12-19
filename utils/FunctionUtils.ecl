EXPORT FunctionUtils := MODULE

  /*
    Create a set by repeating a given item i n times.
    Given: 
      i: item (of type B) to repeat.
      n: number of times to repeat.
    Return:
      set[B]
  */
  EXPORT RepeatSet(i, n) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(value)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)

    #SET(ttype, #GETDATATYPE(i))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'ttype'%, 'string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 1)
    #SET(value, '[')
    #LOOP
      #IF(%idx% > n)
        #BREAK
      #END
      #IF(%'value'% != '[')
        #APPEND(value, ', ')
      #END
      #IF(%isStringSet% = 1)
        #APPEND(value, '\'' + i + '\'')
      #ELSE
        #APPEND(value, i)
      #END
      #SET(idx, %idx% + 1)
    #END
    #APPEND(value, ']')
    LOCAL #EXPAND('set of ' + %'ttype'%) outputSet := %value%;
    RETURN outputSet;
  ENDMACRO;

  /*
    Check if there exists any item in the input set satisfying a given predicate.
    Given: 
      p: A -> Boolean
      ds[A]
    Return: 
      - TRUE: if there exists an item such that p = True.
      - FALSE: otherwise.
  */
  EXPORT AnySetItem(p, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(resultStr)
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(stype)
    #UNIQUENAME(isStringSet)

    #SET(idx, 1)
    #SET(size, COUNT(inputSet))
    #SET(resultStr, 'FALSE')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(p(inputSet[%idx%]))
        #SET(resultStr, 'TRUE')
        #BREAK
      #END
      #SET(idx, %idx% + 1)
    #END

    LOCAL BOOLEAN resultVal := %resultStr%;
    RETURN resultVal;
  ENDMACRO;

  /*
    Check if all items in the input set satisfying a given predicate.
    Given: 
      p: A -> Boolean
      ds[A]
    Return: 
      - TRUE: if all items satisfy predicate p.
      - FALSE: otherwise.
  */
  EXPORT AllSetItems(p, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(resultStr)
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(stype)
    #UNIQUENAME(isStringSet)

    #SET(idx, 1)
    #SET(size, COUNT(inputSet))
    #SET(resultStr, 'TRUE')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(NOT p(inputSet[%idx%]))
        #SET(resultStr, 'FALSE')
        #BREAK
      #END
      #SET(idx, %idx% + 1)
    #END

    LOCAL BOOLEAN resultVal := %resultStr%;
    RETURN resultVal;
  ENDMACRO;

  /*
    Filter set, return set of items satisfying a given predicate.
    Given: 
      p: A -> Boolean (function).
      set[A]
    Return:
      set[A] such that p(A) = True
  */
  EXPORT FilterSet(p, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype)
    #UNIQUENAME(isStringSet)

    #SET(stype, #GETDATATYPE(inputSet))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'stype'%, 'set of string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 1)
    #SET(size, COUNT(inputSet))
    #SET(value, '[')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(p(inputSet[%idx%]))
        #IF(%'value'% != '[')
          #APPEND(value, ', ')
        #END
        #IF(%isStringSet% = 1)
          #APPEND(value, '\'' + inputSet[%idx%] + '\'')
        #ELSE
          #APPEND(value, inputSet[%idx%])
        #END
      #END
      #SET(idx, %idx% + 1)
    #END
    #APPEND(value, ']')
    LOCAL TYPEOF(inputSet) outputSet := %value%;
    RETURN outputSet;
  ENDMACRO;

  /*
    Map (transform) set of type A to type B.
    Given: 
      f: A -> B (function).
      set[A]
    Return:
      set[B]
  */
  EXPORT MapSet(f, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)

    #SET(stype, #GETDATATYPE(inputSet))
    #SET(dtype, %'stype'%[8..])
    #SET(ttype, #GETDATATYPE(f((%dtype%)'')))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'ttype'%, 'string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 1)
    #SET(size, COUNT(inputSet))
    #SET(value, '[')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(%'value'% != '[')
        #APPEND(value, ', ')
      #END
      #IF(%isStringSet% = 1)
        #APPEND(value, '\'' + f(inputSet[%idx%]) + '\'')
      #ELSE
        #APPEND(value, f(inputSet[%idx%]))
      #END
      #SET(idx, %idx% + 1)
    #END
    #APPEND(value, ']')
    LOCAL #EXPAND('set of ' + %'ttype'%) outputSet := %value%;
    RETURN outputSet;
  ENDMACRO;

  /*
    Map (transform) two sets of type A and type B to type C.
    Given: 
      f: (A, B) -> C (binary function).
      set1[A]
      set2[B]
    Return:
      set[C]
  */
  EXPORT Map2Sets(f, inputSet1, inputSet2) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype1)
    #UNIQUENAME(dtype1)
    #UNIQUENAME(stype2)
    #UNIQUENAME(dtype2)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)

    #SET(stype1, #GETDATATYPE(inputSet1))
    #SET(dtype1, %'stype1'%[8..])
    #SET(stype2, #GETDATATYPE(inputSet2))
    #SET(dtype2, %'stype2'%[8..])
    #SET(ttype, #GETDATATYPE(f((%dtype1%)'', (%dtype2%)'')))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'ttype'%, 'string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 1)
    #SET(size, MIN(COUNT(inputSet1), COUNT(inputSet2)))
    #SET(value, '[')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(%'value'% != '[')
        #APPEND(value, ', ')
      #END
      #IF(%isStringSet% = 1)
        #APPEND(value, '\'' + f(inputSet1[%idx%], inputSet2[%idx%]) + '\'')
      #ELSE
        #APPEND(value, f(inputSet1[%idx%], inputSet2[%idx%]))
      #END
      #SET(idx, %idx% + 1)
    #END
    #APPEND(value, ']')
    LOCAL #EXPAND('set of ' + %'ttype'%) outputSet := %value%;
    RETURN outputSet;
  ENDMACRO;

  /*
    Map (transform) three sets of type A, type B, and type C to type D.
    Given: 
      f: (A, B, C) -> D (ternary function).
      set1[A]
      set2[B]
      set3[C]
    Return:
      set[D]
  */
  EXPORT Map3Sets(f, inputSet1, inputSet2, inputSet3) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype1)
    #UNIQUENAME(dtype1)
    #UNIQUENAME(stype2)
    #UNIQUENAME(dtype2)
    #UNIQUENAME(stype3)
    #UNIQUENAME(dtype3)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)

    #SET(stype1, #GETDATATYPE(inputSet1))
    #SET(dtype1, %'stype1'%[8..])
    #SET(stype2, #GETDATATYPE(inputSet2))
    #SET(dtype2, %'stype2'%[8..])
    #SET(stype3, #GETDATATYPE(inputSet3))
    #SET(dtype3, %'stype3'%[8..])
    #SET(ttype, #GETDATATYPE(f((%dtype1%)'', (%dtype2%)'', (%dtype3%)'')))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'ttype'%, 'string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 1)
    #SET(size, MIN(COUNT(inputSet1), COUNT(inputSet2), COUNT(inputSet3)))
    #SET(value, '[')
    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(%'value'% != '[')
        #APPEND(value, ', ')
      #END
      #IF(%isStringSet% = 1)
        #APPEND(value, '\'' + f(inputSet1[%idx%], inputSet2[%idx%], inputSet3[%idx%]) + '\'')
      #ELSE
        #APPEND(value, f(inputSet1[%idx%], inputSet2[%idx%], inputSet3[%idx%]))
      #END
      #SET(idx, %idx% + 1)
    #END
    #APPEND(value, ']')
    LOCAL #EXPAND('set of ' + %'ttype'%) outputSet := %value%;
    RETURN outputSet;
  ENDMACRO;

  /*
    Reduce the set (from left to right) to an element using the specified associative binary operator.
    Given: 
      f: (A, A) -> A
      set[A]
    Return:
      A
  */
  EXPORT ReduceSet(f, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)

    #SET(stype, #GETDATATYPE(inputSet))
    #SET(dtype, %'stype'%[8..])
    #SET(ttype, %'dtype'%)

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'stype'%, 'set of string'))
      #SET(isStringSet, 1)
    #END

    #SET(idx, 2)
    #SET(size, COUNT(inputSet))
    #IF(%size% > 0)
      #IF(%isStringSet% = 1)
        #SET(value, '\'' + inputSet[1] + '\'')
      #ELSE
        #SET(value, inputSet[1])
      #END
    #ELSE
      #SET(value, (%dtype%)'')
    #END

    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #END
      #IF(%isStringSet% = 1)
        #SET(value, '\'' + f(%value%, inputSet[%idx%]) + '\'')
      #ELSE
        #SET(value, f(%value%, inputSet[%idx%]))
      #END
      #SET(idx, %idx% + 1)
    #END
    #IF((%'value'% = '') AND (%isStringSet% = 1))
      #SET(value, '\'\'')
    #END
    LOCAL %ttype% reducedResult := %value%;
    RETURN reducedResult;
  ENDMACRO;

  /*
    Aggregate the results of applying an operator to subsequent elements.
    Given: 
      f: (B, B) -> B
      m: (A, B) -> B
        m and f are functions
      z[B]
      set[A]
    Return:
      B
  */
  EXPORT AggregateSet(f, m, z, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;

    #UNIQUENAME(stype)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)

    #SET(stype, #GETDATATYPE(inputSet))
    #SET(dtype, %'stype'%[8..])
    #SET(ttype, #GETDATATYPE(z))

    LOCAL g(%dtype% input) := m(input, z);
    LOCAL mappedSet := %FunctionUtils%.MapSet(g, inputSet);
    LOCAL %ttype% reducedResult := %FunctionUtils%.ReduceSet(f, mappedSet);
    RETURN reducedResult;
  ENDMACRO;

  /*
    Aggregate the results of applying an operator to subsequent elements.
    Given: 
      f: (C, C) -> C
      m: (A, B, C) -> C
        m and f are functions
      z[C]
      set1[A]
      set2[B]
    Return:
      C
  */
  EXPORT Aggregate2Sets(f, m, z, inputSet1, inputSet2) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;

    #UNIQUENAME(stype1)
    #UNIQUENAME(dtype1)
    #UNIQUENAME(stype2)
    #UNIQUENAME(dtype2)
    #UNIQUENAME(ttype)

    #SET(stype1, #GETDATATYPE(inputSet1))
    #SET(dtype1, %'stype1'%[8..])
    #SET(stype2, #GETDATATYPE(inputSet2))
    #SET(dtype2, %'stype2'%[8..])
    #SET(ttype, #GETDATATYPE(z))

    LOCAL g(%dtype1% input1, %dtype2% input2) := m(input1, input2, z);
    LOCAL mappedSet := %FunctionUtils%.Map2Sets(g, inputSet1, inputSet2);
    LOCAL %ttype% reducedResult := %FunctionUtils%.ReduceSet(f, mappedSet);
    RETURN reducedResult;
  ENDMACRO;

  /*
    Aggregate the results of applying an operator to subsequent elements.
    Given: 
      f: (D, D) -> D
      m: (A, B, C, D) -> D
        m and f are functions
      z[D]
      set1[A]
      set2[B]
      set3[C]
    Return:
      D
  */
  EXPORT Aggregate3Sets(f, m, z, inputSet1, inputSet2, inputSet3) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;

    #UNIQUENAME(stype1)
    #UNIQUENAME(dtype1)
    #UNIQUENAME(stype2)
    #UNIQUENAME(dtype2)
    #UNIQUENAME(stype3)
    #UNIQUENAME(dtype3)
    #UNIQUENAME(ttype)

    #SET(stype1, #GETDATATYPE(inputSet1))
    #SET(dtype1, %'stype1'%[8..])
    #SET(stype2, #GETDATATYPE(inputSet2))
    #SET(dtype2, %'stype2'%[8..])
    #SET(stype3, #GETDATATYPE(inputSet3))
    #SET(dtype3, %'stype3'%[8..])
    #SET(ttype, #GETDATATYPE(z))

    LOCAL g(%dtype1% input1, %dtype2% input2, %dtype3% input3) := m(input1, input2, input3, z);
    LOCAL mappedSet := %FunctionUtils%.Map3Sets(g, inputSet1, inputSet2, inputSet3);
    LOCAL %ttype% reducedResult := %FunctionUtils%.ReduceSet(f, mappedSet);
    RETURN reducedResult;
  ENDMACRO;

  /*
    Produce a set containing cumulative results of applying the operator going left to right or right to left.
    Given: 
      f: (B, A) -> B (from left to right) or (A, B) -> B (from right to left).
      z[B]
      set[A]
      isFromRight: optional, scan from right -> left or left -> right, default left -> right.
    Return:
      set[B]
  */
  EXPORT ScanSet(f, z, inputSet, isFromRight = FALSE) := FUNCTIONMACRO
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #UNIQUENAME(stype)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)
    #UNIQUENAME(isStringSet)
    #UNIQUENAME(fval)

    #SET(stype, #GETDATATYPE(inputSet))
    #SET(dtype, %'stype'%[8..])
    #SET(ttype, #GETDATATYPE(z))

    #SET(isStringSet, 0)
    #IF(%StdStr%.StartsWith(%'ttype'%, 'string'))
      #SET(isStringSet, 1)
    #END
    // counter
    #IF(isFromRight = TRUE)
      #SET(idx, COUNT(inputSet))
    #ELSE
      #SET(idx, 1)
    #END
    #SET(size, COUNT(inputSet))
    // init final result
    #IF(isFromRight = TRUE)
      #SET(value, ']')
    #ELSE
      #SET(value, '[')
    #END
    // init current cumulative value
    #IF(%isStringSet% = 1)
      #SET(fval, '\'' + z + '\'')
    #ELSE
      #SET(fval, z)
    #END
    // begin main loop
    #LOOP
      // all items processed?
      #IF(isFromRight = TRUE)
        #IF(%idx% < 1)
          #BREAK
        #END
      #ELSE
        #IF(%idx% > %size%)
          #BREAK
        #END
      #END
      // evaluate the current cumulative value
      #IF(isFromRight = TRUE)
        #SET(fval, f(inputSet[%idx%], %fval%))
      #ELSE
        #SET(fval, f(%fval%, inputSet[%idx%]))
      #END
      // append/prepend to the final result
      #IF(isFromRight = TRUE)
        #IF(%'value'% != ']')
          #SET(value, ', ' + %'value'%)
        #END
        #IF(%isStringSet% = 1)
          #SET(value, '\'' + %'fval'% + '\'' + %'value'%)
        #ELSE
          #SET(value, %fval% + %'value'%)
        #END
      #ELSE
        #IF(%'value'% != '[')
          #APPEND(value, ', ')
        #END
        #IF(%isStringSet% = 1)
          #APPEND(value, '\'' + %'fval'% + '\'')
        #ELSE
          #APPEND(value, %fval%)
        #END
      #END
      // adjust the current cumulative value if target data type is string
      #IF(%isStringSet% = 1)
        #SET(fval, '\'' + %'fval'% + '\'')
      #END
      // move to the next item
      #IF(isFromRight = TRUE)
        #SET(idx, %idx% - 1)
      #ELSE
        #SET(idx, %idx% + 1)
      #END
    #END
    // end main loop
    #IF(isFromRight = TRUE)
      #SET(value, '[' + %'value'%)
    #ELSE
      #APPEND(value, ']')
    #END
    LOCAL #EXPAND('set of ' + %'ttype'%) outputSet := %value%;
    RETURN %value%;
  ENDMACRO;

  /*
    Produce a set containing cumulative results of applying the operator going left to right.
    Given: 
      f: (B, A) -> B
      z[B]
      set[A]
    Return:
      set[B]
  */
  EXPORT ScanLeftSet(f, z, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.ScanSet(f, z, inputSet, isFromRight := FALSE);
  ENDMACRO;

  /*
    Produce a set containing cumulative results of applying the operator going right to left.
    Given: 
      f: (A, B) -> B
      z[B]
      set[A]
    Return:
      set[B]
  */
  EXPORT ScanRightSet(f, z, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.ScanSet(f, z, inputSet, isFromRight := TRUE);
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going left to right.
    Given: 
      f: (B, A) -> B
      z[B]
      set[A]
    Return: 
      B
  */
  EXPORT FoldLeftSet(f, z, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputSet := %FunctionUtils%.ScanLeftSet(f, z, inputSet);
    LOCAL numberOfInputs := COUNT(inputSet);
    RETURN IF(COUNT(inputSet) > 0, outputSet[numberOfInputs], z);
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going right to left.
    Given: 
      f: (A, B) -> B
      z[B]
      set[A]
    Return: 
      B
  */
  EXPORT FoldRightSet(f, z, inputSet) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputSet := %FunctionUtils%.ScanRightSet(f, z, inputSet);
    RETURN IF(COUNT(inputSet) > 0, outputSet[1], z);
  ENDMACRO;

  /*
    Create a dataset by repeating a given row r n times.
    Given: 
      r: item (of type B) to repeat.
      n: number of times to repeat.
    Return:
      ds[B]
  */
  EXPORT Repeat(r, n) := FUNCTIONMACRO
    LOCAL Layout := RECORDOF(r);
    LOCAL outputDS := DATASET(
      n,
      TRANSFORM(
        Layout,
        SELF := r
      )
    );
    RETURN outputDS;
  ENDMACRO;

  /*
    Check if there exists any record in the input dataset satisfying a given predicate.
    Given: 
      p: A -> Boolean
      ds[A]
    Return: 
      - TRUE: if there exists a record such that p = True.
      - FALSE: otherwise.
  */
  EXPORT AnyItem(p, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputDS := %FunctionUtils%.Filter(p, inputDS);
    RETURN EXISTS(outputDS)
  ENDMACRO;

  /*
    Check if all records in the input dataset satisfying a given predicate.
    Given: 
      p: A -> Boolean
      ds[A]
    Return: 
      - TRUE: if all records satisfy predicate p.
      - FALSE: otherwise.
  */
  EXPORT AllItems(p, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL TYPEOF(p) notP(RECORDOF(inputDS) r) := NOT p(r);
    LOCAL outputDS := %FunctionUtils%.Filter(notP, inputDS);
    RETURN NOT EXISTS(outputDS)
  ENDMACRO;

  /*
    Filter dataset, return rows satisfying a given predicate.
    Given: 
      p: A -> Boolean
      ds[A]
    Return: 
      ds[A] such that p(A) = True
  */
  EXPORT Filter(p, inputDS) := FUNCTIONMACRO
    LOCAL outputDS := PROJECT(
      inputDS,
      TRANSFORM(
        RECORDOF(inputDS),
        SKIP(NOT p(LEFT)),
        SELF := LEFT
      ),
      LOCAL,
      UNORDERED,
      UNSTABLE,
      PARALLEL
    );
    RETURN outputDS;
  ENDMACRO;

  /*
    Map (transform) dataset of type A to type B.
    Given: 
      f: A -> B
        f is either function or inline transform function.
      ds[A]
    Return:
      ds[B]
  */
  EXPORT Map(f, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(hasTransformer)
    #SET(hasTransformer, FALSE)
    #IF(REGEXFIND('^\\s*transform\\s*\\(.+\\)\\s*$', #TEXT(f), NOCASE))
      #SET(hasTransformer, TRUE)
    #ELSE
      LOCAL TYPEOF(f) transformerFunc(RECORDOF(inputDS) input) := TRANSFORM
        SELF := f(input);
      END;
    #END
    LOCAL outputDS := PROJECT(
      inputDS,
      #IF(%hasTransformer%)
        f
      #ELSE
        transformerFunc(LEFT)
      #END
      ,
      LOCAL,
      UNORDERED,
      UNSTABLE,
      PARALLEL
    );
    RETURN outputDS;
  ENDMACRO;

  /*
    Reduce the dataset to an element using the specified associative binary operator.
    Given: 
      f: (A, A) -> A
        f is either function or inline transform function and must be associative: f(A, f(B, C)) <=> f(f(A, B), C).
      ds[A]
    Return:
      A
  */
  EXPORT Reduce(f, inputDS) := FUNCTIONMACRO
    LOCAL Layout := RECORDOF(inputDS);
    #UNIQUENAME(hasTransformer)
    #SET(hasTransformer, FALSE)
    #IF(REGEXFIND('^\\s*transform\\s*\\(.+\\)\\s*$', #TEXT(f), NOCASE))
      #SET(hasTransformer, TRUE)
    #ELSE
      LOCAL Layout transformerFunc(Layout l, Layout r) := TRANSFORM
        SELF := f(l, r);
      END;
    #END
    LOCAL outputDS := ROLLUP(
      inputDS,
      TRUE,
      #IF(%hasTransformer%)
        f
      #ELSE
        transformerFunc(LEFT, RIGHT)
      #END
      ,
      UNORDERED,
      UNSTABLE,
      PARALLEL
    );
    RETURN IF(EXISTS(inputDS), outputDS[1], ROW([], Layout));
  ENDMACRO;

  /*
    Aggregate the results of applying an operator to subsequent elements.

            ----- B -----
           /             \        reduce (f)
        - B -           - B -
       /     \         /     \    reduce (f)
      B       B       B       B
     / \     / \     / \     / \  map  (m)
    A   z   A   z   A   z   A   z

    Given: 
      f: (B, B) -> B
        f must be associative: f(A, f(B, C)) <=> f(f(A, B), C).
      m: (A, B) -> B
        m and f are either functions or inline transform functions.
      z[B]
      ds[A]
    Return: 
      B
  */
  EXPORT Aggregate(f, m, z, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    #UNIQUENAME(hasTransformer)
    #SET(hasTransformer, FALSE)
    #IF(REGEXFIND('^\\s*transform\\s*\\(.+\\)\\s*$', #TEXT(m), NOCASE))
      #SET(hasTransformer, TRUE)
    #ELSE
      #SET(hasTransformer, FALSE)
    #END
    LOCAL mappedDS := %FunctionUtils%.Map(
      #IF(%hasTransformer%)
        m
      #ELSE
        TRANSFORM(
          RECORDOF(z),
          SELF := m(LEFT, z)
        )
      #END
      ,
      inputDS
    );
    RETURN %FunctionUtils%.Reduce(f, mappedDS);
  ENDMACRO;
  EXPORT AggregateValue(f, m, zVal, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL mf(RECORDOF(inputDS) input, outputLayout z) := ROW({m(input, z.Value)}, outputLayout);
    LOCAL ff(outputLayout a, outputLayout b) := ROW({f(a.Value, b.Value)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.Aggregate(ff, mf, zrow, inputDS);
    RETURN outputResult.Value;
  ENDMACRO;

  EXPORT _PrefixScan_(f, z, inputDS, isFromRight) := FUNCTIONMACRO
    LOCAL inputLayout := RECORDOF(inputDS);
    LOCAL outputLayout := RECORDOF(z);
    #UNIQUENAME(g)
    #IF(isFromRight)
      LOCAL outputLayout %g%(inputLayout a, outputLayout b) := f(a, b);
    #ELSE
      LOCAL outputLayout %g%(inputLayout a, outputLayout b) := f(b, a);
    #END
    LOCAL dummyOutput := ROW([], outputLayout);
    LOCAL transformedLayout := {inputLayout current, outputLayout cumulative, UNSIGNED c};
    LOCAL tranformedInput := PROJECT(
      inputDS,
      TRANSFORM(
        transformedLayout,
        SELF.current := LEFT,
        SELF.cumulative := dummyOutput,
        SELF.c := COUNTER
      ),
      LOCAL,
      ORDERED,
      STABLE,
      PARALLEL
    );
    LOCAL processInput := IF(isFromRight, SORT(tranformedInput, -c), tranformedInput);
    LOCAL processOutput := PROCESS(
      processInput,
      z,
      TRANSFORM(
        transformedLayout,
        SELF.cumulative := %g%(LEFT.current, RIGHT),
        SELF := LEFT
      ),
      TRANSFORM(
        outputLayout,
        SELF := %g%(LEFT.current, RIGHT)
      ),
      ORDERED,
      STABLE
    );
    LOCAL outputDS := IF(isFromRight, SORT(processOutput, c), processOutput);
    RETURN outputDS;
  ENDMACRO;
  /*
    Produce a dataset containing cumulative results of applying the operator going left to right or right to left.
    Given:
      f: (B, A) -> B (from left to right) or (A, B) -> B (from right to left).
      z[B]
      ds[A]
      isFromRight: optional, scan from right -> left or left -> right, default left -> right.
    Return:
      ds[B]
  */
  EXPORT Scan(f, z, inputDS, isFromRight = FALSE) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(f, z, inputDS, isFromRight);
    LOCAL outputDS := PROJECT(
      processOutput,
      TRANSFORM(
        outputLayout,
        SELF := LEFT.cumulative
      ),
      LOCAL,
      ORDERED,
      STABLE,
      PARALLEL
    );
    RETURN outputDS;
  ENDMACRO;

  /*
    Produce a dataset containing cumulative results of applying the operator going left to right.
    Given: 
      f: (B, A) -> B
      z[B]
      ds[A]
    Return: 
      ds[B]
  */
  EXPORT ScanLeft(f, z, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.Scan(f, z, inputDS, isFromRight := FALSE);
  ENDMACRO;

  /*
    Produce a dataset containing cumulative results of applying the operator going right to left.
    Given:
      f: (A, B) -> B
      z[B]
      ds[A]
    Return:
      ds[B]
  */
  EXPORT ScanRight(f, z, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.Scan(f, z, inputDS, isFromRight := TRUE);
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going left to right.

      :           FoldLeft           f
     / \          ------->          / \
    1   :                          f   5
       / \                        / \
      2   :                      f   4
         / \                    / \
        3   :                  f   3
           / \                / \
          4   :              f   2
             / \            / \
            5  []          z   1

    Given: 
      f: (B, A) -> B
      z[B]
      ds[A]
    Return: 
      B
  */
  EXPORT FoldLeft(f, z, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(f, z, inputDS, isFromRight := FALSE);
    LOCAL numberOfInputs := COUNT(inputDS);
    RETURN IF(numberOfInputs > 0, processOutput[numberOfInputs].cumulative, z);
  ENDMACRO;
  EXPORT FoldLeftValue(f, zVal, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL ff(outputLayout z, RECORDOF(inputDS) input) := ROW({f(z.Value, input)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.FoldLeft(ff, zrow, inputDS);
    RETURN outputResult.Value;
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going right to left.

      :           FoldRight     f
     / \          -------->    / \
    1   :                     1   f
       / \                       / \
      2   :                     2   f
         / \                       / \
        3   :                     3   f
           / \                       / \
          4   :                     4   f
             / \                       / \
            5  []                     5   z

    Given: 
      f: (A, B) -> B
      z[B]
      ds[A]
    Return: 
      B
  */
  EXPORT FoldRight(f, z, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(f, z, inputDS, isFromRight := TRUE);
    RETURN IF(COUNT(inputDS) > 0, processOutput[1].cumulative, z);
  ENDMACRO;
  EXPORT FoldRightValue(f, zVal, inputDS) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL ff(RECORDOF(inputDS) input, outputLayout z) := ROW({f(input, z.Value)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.FoldRight(ff, zrow, inputDS);
    RETURN outputResult.Value;
  ENDMACRO;

END;
