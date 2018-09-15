EXPORT FunctionUtils := MODULE

  /*
    Filter set, return set of items satisfying a given predicate.
    Given: set[A]
           p: A -> Boolean
    Return: set[A] such that p(A) = True
  */
  EXPORT FilterSet(inputSet, p) := FUNCTIONMACRO
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
    Given: set[A]
           f: A -> B
           f is function.
    Return: set[B]
  */
  EXPORT MapSet(inputSet, f) := FUNCTIONMACRO
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
    Reduce the set (from left to right) to an element using the specified associative binary operator.
    Given: set[A]
           f: (A, A) -> A
    Return: A
  */
  EXPORT ReduceSet(inputSet, f) := FUNCTIONMACRO
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
    Given: set[A]
           z[B]
           m: (A, B) -> B
           f: (B, B) -> B
           m and f are functions
    Return: B
  */
  EXPORT AggregateSet(inputSet, z, m, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;

    #UNIQUENAME(stype)
    #UNIQUENAME(dtype)
    #UNIQUENAME(ttype)

    #SET(stype, #GETDATATYPE(inputSet))
    #SET(dtype, %'stype'%[8..])
    #SET(ttype, #GETDATATYPE(z))

    LOCAL g(%dtype% input) := m(input, z);
    LOCAL mappedSet := %FunctionUtils%.MapSet(inputSet, g);
    LOCAL %ttype% reducedResult := %FunctionUtils%.ReduceSet(mappedSet, f);
    RETURN reducedResult;
  ENDMACRO;

  /*
    Produce a set containing cumulative results of applying the operator going left to right or right to left.
    Given: set[A]
           z[B]
           f: (B, A) -> B (from left to right) or (A, B) -> B (from right to left).
           isFromRight: optional, scan from right -> left or left -> right, default left -> right.
    Return: set[B]
  */
  EXPORT ScanSet(inputSet, z, f, isFromRight = FALSE) := FUNCTIONMACRO
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
    Given: set[A]
           z[B]
           f: (B, A) -> B
    Return: set[B]
  */
  EXPORT ScanLeftSet(inputSet, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.ScanSet(inputSet, z, f, isFromRight := FALSE);
  ENDMACRO;

  /*
    Produce a set containing cumulative results of applying the operator going right to left.
    Given: set[A]
           z[B]
           f: (A, B) -> B
    Return: set[B]
  */
  EXPORT ScanRightSet(inputSet, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.ScanSet(inputSet, z, f, isFromRight := TRUE);
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going left to right.
    Given: set[A]
           z[B]
           f: (B, A) -> B
    Return: B
  */
  EXPORT FoldLeftSet(inputSet, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputSet := %FunctionUtils%.ScanLeftSet(inputSet, z, f);
    LOCAL numberOfInputs := COUNT(inputSet);
    RETURN IF(COUNT(inputSet) > 0, outputSet[numberOfInputs], z);
  ENDMACRO;

  /*
    Apply a binary operator to a start value and all elements going right to left.
    Given: set[A]
           z[B]
           f: (A, B) -> B
    Return: B
  */
  EXPORT FoldRightSet(inputSet, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputSet := %FunctionUtils%.ScanRightSet(inputSet, z, f);
    RETURN IF(COUNT(inputSet) > 0, outputSet[1], z);
  ENDMACRO;

  /*
    Filter dataset, return rows satisfying a given predicate.
    Given: ds[A]
           p: A -> Boolean
    Return: ds[A] such that p(A) = True
  */
  EXPORT Filter(inputDS, p) := FUNCTIONMACRO
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
    Given: ds[A]
           f: A -> B
           f is either function or inline transform function.
    Return: ds[B]
  */
  EXPORT Map(inputDS, f) := FUNCTIONMACRO
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
    Given: ds[A]
           f: (A, A) -> A
           f is either function or inline transform function and must be associative: f(A, f(B, C)) <=> f(f(A, B), C).
    Return: A
  */
  EXPORT Reduce(inputDS, f) := FUNCTIONMACRO
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

    Given: ds[A]
           z[B]
           m: (A, B) -> B
           f: (B, B) -> B
           f must be associative: f(A, f(B, C)) <=> f(f(A, B), C).
           m and f are either functions or inline transform functions.
    Return: B
  */
  EXPORT Aggregate(inputDS, z, m, f) := FUNCTIONMACRO
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
      inputDS,
      #IF(%hasTransformer%)
        m
      #ELSE
        TRANSFORM(
          RECORDOF(z),
          SELF := m(LEFT, z)
        )
      #END
    );
    RETURN %FunctionUtils%.Reduce(mappedDS, f);
  ENDMACRO;
  EXPORT AggregateValue(inputDS, zVal, m, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL mf(RECORDOF(inputDS) input, outputLayout z) := ROW({m(input, z.Value)}, outputLayout);
    LOCAL ff(outputLayout a, outputLayout b) := ROW({f(a.Value, b.Value)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.Aggregate(inputDS, zrow, mf, ff);
    RETURN outputResult.Value;
  ENDMACRO;

  EXPORT _PrefixScan_(inputDS, z, f, isFromRight) := FUNCTIONMACRO
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
    Given: ds[A]
           z[B]
           f: (B, A) -> B (from left to right) or (A, B) -> B (from right to left).
           isFromRight: optional, scan from right -> left or left -> right, default left -> right.
    Return: ds[B]
  */
  EXPORT Scan(inputDS, z, f, isFromRight = FALSE) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(inputDS, z, f, isFromRight);
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
    Given: ds[A]
           z[B]
           f: (B, A) -> B
    Return: ds[B]
  */
  EXPORT ScanLeft(inputDS, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.Scan(inputDS, z, f, isFromRight := FALSE);
  ENDMACRO;

  /*
    Produce a dataset containing cumulative results of applying the operator going right to left.
    Given: ds[A]
           z[B]
           f: (A, B) -> B
    Return: ds[B]
  */
  EXPORT ScanRight(inputDS, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    RETURN %FunctionUtils%.Scan(inputDS, z, f, isFromRight := TRUE);
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

    Given: ds[A]
           z[B]
           f: (B, A) -> B
    Return: B
  */
  EXPORT FoldLeft(inputDS, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(inputDS, z, f, isFromRight := FALSE);
    LOCAL numberOfInputs := COUNT(inputDS);
    RETURN IF(numberOfInputs > 0, processOutput[numberOfInputs].cumulative, z);
  ENDMACRO;
  EXPORT FoldLeftValue(inputDS, zVal, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL ff(outputLayout z, RECORDOF(inputDS) input) := ROW({f(z.Value, input)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.FoldLeft(inputDS, zrow, ff);
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

    Given: ds[A]
           z[B]
           f: (A, B) -> B
    Return: B
  */
  EXPORT FoldRight(inputDS, z, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := RECORDOF(z);
    LOCAL processOutput := %FunctionUtils%._PrefixScan_(inputDS, z, f, isFromRight := TRUE);
    RETURN IF(COUNT(inputDS) > 0, processOutput[1].cumulative, z);
  ENDMACRO;
  EXPORT FoldRightValue(inputDS, zVal, f) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL outputLayout := {TYPEOF(zVal) Value};
    LOCAL zrow := ROW({zVal}, outputLayout);
    LOCAL ff(RECORDOF(inputDS) input, outputLayout z) := ROW({f(input, z.Value)}, outputLayout);
    LOCAL outputResult := %FunctionUtils%.FoldRight(inputDS, zrow, ff);
    RETURN outputResult.Value;
  ENDMACRO;

END;
