EXPORT StringUtils := MODULE

  /*
    Join set of strings into a string
  */
  EXPORT JoinSetOfStrings(StringSet, ElementPrefix, ElementPostfix, OpCombine) := FUNCTIONMACRO
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #SET(idx, 1)
    #SET(size, COUNT(StringSet))
    #SET(value, '')

    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #ELSE
        #IF(%idx% > 1)
          #APPEND(value, OpCombine)
        #END
        #APPEND(value, ElementPrefix + StringSet[%idx%] + ElementPostfix)
      #END
      #SET(idx, %idx% + 1)
    #END
    RETURN %'value'%;
  ENDMACRO;

  /*
    Join two sets of strings into a string
  */
  EXPORT JoinTwoSetsOfStrings(LeftSet, RightSet, PrefixLeft, PrefixRight, PostfixLeft, PostfixRight, OpElement, OpCombine) := FUNCTIONMACRO
    #UNIQUENAME(idx)
    #UNIQUENAME(size)
    #UNIQUENAME(value)
    #SET(idx, 1)
    #SET(size, COUNT(LeftSet))
    #IF(%size% > COUNT(RightSet))
      #SET(size, COUNT(RightSet))
    #END
    #SET(value, '')

    #LOOP
      #IF(%idx% > %size%)
        #BREAK
      #ELSE
        #IF(%idx% > 1)
          #APPEND(value, OpCombine)
        #END
        #APPEND(value, PrefixLeft + LeftSet[%idx%] + PostfixLeft + OpElement + PrefixRight + RightSet[%idx%] + PostfixRight)
      #END
      #SET(idx, %idx% + 1)
    #END
    RETURN %'value'%;
  ENDMACRO;

END;