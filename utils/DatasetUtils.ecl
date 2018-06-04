EXPORT DatasetUtils := MODULE

  /*
    Create slim layout with only given fields
  */
  EXPORT CreateSlimLayout(Layout, Fields2Keep) := FUNCTIONMACRO
    #UNIQUENAME(StringUtils)
    IMPORT utils.StringUtils AS %StringUtils%;
    LOCAL LayoutWithKeptFields2Keep := {
      #EXPAND(
        %StringUtils%.JoinTwoSetsOfStrings(
          Fields2Keep,
          Fields2Keep,
          'TYPEOF(' + #TEXT(Layout) + '.',
          '',
          ')',
          '',
          ' ',
          ', '
        )      
      )
    };
    RETURN LayoutWithKeptFields2Keep;
  ENDMACRO;

  /*
    Create a function that can convert record to string.
  */
  EXPORT CreateToStringHelper(Layout) := FUNCTIONMACRO
    LOADXML('<xml/>');
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;
    #UNIQUENAME(rowContent)
    #UNIQUENAME(skipNextField)
    #UNIQUENAME(nestingField)
    #UNIQUENAME(rowParamName)
    #UNIQUENAME(useHashFunction)
    #SET(rowParamName, 'intputRow')
    #SET(rowContent, '')
    #SET(skipNextField, 0)
    #SET(nestingField, '')
    #EXPORTXML(xmlOutput, Layout)
    #FOR(xmlOutput)
      #FOR(Field)
        #IF(%{@isEnd}% = 1)
          #SET(skipNextField, 0)
          #SET(nestingField, '')
        #ELSEIF(%skipNextField% = 0)
          #IF(%{@isRecord}% = 1)
            #SET(nestingField, %'{@name}'%)
          #END
          #IF(%{@isDataset}% = 1)
            #SET(skipNextField, 1)
          #END
          #IF(%{@isRecord}% != 1)
            #IF(%StdStr%.StartsWith(%'{@type}'%, 'set') OR %StdStr%.StartsWith(%'{@type}'%, 'table'))
              #SET(useHashFunction, 1)
            #ELSE
              #SET(useHashFunction, 0)
            #END
            #IF(%'rowContent'% != '')
              #APPEND(rowContent, ' + ')
            #END
            #IF(%'{@type}'% NOT IN ['string'])
              #APPEND(rowContent, '(STRING)')
            #END
            #IF(%useHashFunction% = 1)
              #APPEND(rowContent, 'HASH(')
            #END
            #IF(%'nestingField'% != '')
              #APPEND(rowContent, %'rowParamName'% + '.' + %'nestingField'% + '.' + %'{@name}'%)
            #ELSE
              #APPEND(rowContent, %'rowParamName'% + '.' + %'{@name}'%)
            #END
            #IF(%useHashFunction% = 1)
              #APPEND(rowContent, ')')
            #END
          #END
        #END
      #END
    #END
    LOCAL ModuleName := MODULE
      EXPORT STRING Expression := %'rowContent'%;
      EXPORT STRING ToString(Layout intputRow) := FUNCTION
        RETURN #EXPAND(%'rowContent'% + ';')
      END;
    END;
    RETURN ModuleName;
  ENDMACRO;

END;
