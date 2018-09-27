EXPORT StringUtils := MODULE

  /*
    Join set of strings into a string
  */
  EXPORT JoinSetOfStrings(stringSet, elementPrefix, elementPostfix, opCombine) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL m(STRING input) := (STRING)elementPrefix + input + elementPostfix;
    LOCAL f(STRING input1, STRING input2) := input1 + opCombine + input2;
    LOCAL stringSetMapped := %FunctionUtils%.MapSet(stringSet, m);
    RETURN %FunctionUtils%.ReduceSet(stringSetMapped, f); 
  ENDMACRO;

  /*
    Join two sets of strings into a string
  */
  EXPORT JoinTwoSetsOfStrings(leftSet, rightSet, prefixLeft, prefixRight, postfixLeft, postfixRight, opElement, opCombine) := FUNCTIONMACRO
    #UNIQUENAME(FunctionUtils)
    IMPORT utils.FunctionUtils AS %FunctionUtils%;
    LOCAL m(STRING l, STRING r, STRING z) := ((STRING)prefixLeft + l + postfixLeft) + opElement + ((STRING)prefixRight + r + postfixRight);
    LOCAL f(STRING input1, STRING input2) := input1 + opCombine + input2;
    RETURN %FunctionUtils%.Aggregate2Sets(leftSet, rightSet, (STRING)'', m, f); 
  ENDMACRO;

END;