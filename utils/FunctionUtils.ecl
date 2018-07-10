EXPORT FunctionUtils := MODULE

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
    LOCAL inputLayout := RECORDOF(inputDS);
    LOCAL dummyInput := ROW([], inputLayout);
    LOCAL outputLayout := RECORDOF(z);
    LOCAL dummyOutput := ROW([], outputLayout);
    LOCAL transformedLayout := {inputLayout current, outputLayout cumulative};
    LOCAL tranformedInput := PROJECT(
      inputDS,
      TRANSFORM(
        transformedLayout,
        SELF.current := LEFT,
        SELF.cumulative := dummyOutput
      ),
      LOCAL,
      ORDERED,
      STABLE,
      PARALLEL
    );
    LOCAL outputDS := ITERATE(
      ROW({dummyInput, z}, transformedLayout) + tranformedInput,
      TRANSFORM(
        RECORDOF(RIGHT),
        SELF.cumulative := IF(COUNTER = 1, z, f(LEFT.cumulative, RIGHT.current)),
        SELF := RIGHT
      ),
      ORDERED,
      STABLE
    );
    RETURN outputDS[COUNT(outputDS)].cumulative;
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
    LOCAL inputLayout := RECORDOF(inputDS);
    LOCAL dummyInput := ROW([], inputLayout);
    LOCAL outputLayout := RECORDOF(z);
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
    LOCAL invInput := SORT(tranformedInput, -c);
    LOCAL outputDS := PROCESS(
      invInput,
      z,
      TRANSFORM(
        transformedLayout,
        SELF.cumulative := f(LEFT.current, RIGHT),
        SELF := LEFT
      ),
      TRANSFORM(
        outputLayout,
        SELF := f(LEFT.current, RIGHT)
      ),
      ORDERED,
      STABLE
    );
    RETURN IF(EXISTS(inputDS), outputDS[COUNT(outputDS)].cumulative, z);
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
