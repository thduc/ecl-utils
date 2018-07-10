EXPORT StringUtils := MODULE

  /*
    Join set of strings into a string
  */
  EXPORT JoinSetOfStrings(stringSet, elementPrefix, elementPostfix, opCombine) := FUNCTIONMACRO
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #SET(idx, 1)
    #SET(size, COUNT(stringSet))
    #SET(value, '')

    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #ELSE
        #IF(%idx% > 1)
          #APPEND(value, opCombine)
        #END
        #APPEND(value, elementPrefix + stringSet[%idx%] + elementPostfix)
      #END
      #SET(idx, %idx% + 1)
    #END
    RETURN %'value'%;
  ENDMACRO;

  /*
    Join two sets of strings into a string
  */
  EXPORT JoinTwoSetsOfStrings(leftSet, rightSet, prefixLeft, prefixRight, postfixLeft, postfixRight, opElement, opCombine) := FUNCTIONMACRO
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #SET(idx, 1)
    #SET(size, COUNT(leftSet))
    #IF(%size% > COUNT(rightSet))
      #SET(size, COUNT(rightSet))
    #END
    #SET(value, '')

    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #ELSE
        #IF(%idx% > 1)
          #APPEND(value, opCombine)
        #END
        #APPEND(value, prefixLeft + leftSet[%idx%] + postfixLeft + opElement + prefixRight + rightSet[%idx%] + postfixRight)
      #END
      #SET(idx, %idx% + 1)
    #END
    RETURN %'value'%;
  ENDMACRO;

END;