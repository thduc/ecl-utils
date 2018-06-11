EXPORT DatasetUtils := MODULE

  EXPORT FieldStructure := RECORD
    STRING ECLType;
    BOOLEAN IsRecord;
    BOOLEAN IsDataset;
    STRING Label;
    STRING Name;
    STRING ParentFieldName;
    UNSIGNED4 Position;
    INTEGER4 RawType;
    INTEGER4 Size;
    STRING Type;
  END;

  /*
    Get the structure of the input
  */
  EXPORT GetFieldStructure(input) := FUNCTIONMACRO
    LOADXML('<xml/>');
    #UNIQUENAME(rowContent)
    #SET(rowContent, '')
    #UNIQUENAME(rowsContent)
    #SET(rowsContent, '')
    #UNIQUENAME(nestingField)
    #SET(nestingField, '')

    #EXPORTXML(xmlOutput, input)
    #FOR(xmlOutput)
      #FOR(Field)
        #IF(%{@isEnd}% = 1)
          #SET(nestingField, '')
        #ELSE
          #IF(%{@isRecord}% = 1 OR %{@isDataset}% = 1)
            #SET(nestingField, '\'' + %'{@name}'% + '\'')
          #END
          #SET(rowContent, '{')
          #APPEND(rowContent, '\'' + %'{@ecltype}'% + '\'')
          #APPEND(rowContent, ', ' + %{@isRecord}%)
          #APPEND(rowContent, ', ' + %{@isDataset}%)
          #APPEND(rowContent, ', \'' + %'{@label}'% + '\'')
          #APPEND(rowContent, ', \'' + %'{@name}'% + '\'')
          #IF(%'nestingField'% = '' OR %{@isRecord}% = 1 OR %{@isDataset}% = 1)
            #APPEND(rowContent, ', \'\'')
          #ELSE
            #APPEND(rowContent, ', \'' + %nestingField% + '\'')
          #END
          #APPEND(rowContent, ', ' + %'{@position}'%)
          #APPEND(rowContent, ', ' + %'{@rawtype}'%)
          #APPEND(rowContent, ', ' + %'{@size}'%)
          #APPEND(rowContent, ', \'' + %'{@type}'% + '\'')
          #APPEND(rowContent, '}')
          #IF(%'rowsContent'% != '')
            #APPEND(rowsContent, ', ')
          #END
          #APPEND(rowsContent, %'rowContent'%)
        #END
      #END
    #END
    RETURN DATASET(#EXPAND('[' + %'rowsContent'% + ']'), DatasetUtils.FieldStructure);
  ENDMACRO;

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

END;
