EXPORT RecordUtils := MODULE

  /*
    Create a helper module with helper functions for a given layout.
  */
  EXPORT CreateHelperModuleForLayout(layout) := FUNCTIONMACRO
    LOADXML('<xml/>');
    #UNIQUENAME(StdStr)
    IMPORT STD.Str AS %StdStr%;

    #UNIQUENAME(rowParamName)
    #SET(rowParamName, 'intputRow')
    #UNIQUENAME(toStringFieldDelimiterParamName)
    #SET(toStringFieldDelimiterParamName, 'fieldDelimiter')
    #UNIQUENAME(toStringRecordOpeningParamName)
    #SET(toStringRecordOpeningParamName, 'recordOpening')
    #UNIQUENAME(toStringRecordClosingParamName)
    #SET(toStringRecordClosingParamName, 'recordClosing')

    #UNIQUENAME(isInNestedDataset)
    #SET(isInNestedDataset, 0)
    #UNIQUENAME(isInNestedRecord)
    #SET(isInNestedRecord, 0)
    #UNIQUENAME(isDatasetField)
    #SET(isDatasetField, 0)
    #UNIQUENAME(isRecordField)
    #SET(isRecordField, 0)
    #UNIQUENAME(isSetField)
    #SET(isSetField, 0)
    #UNIQUENAME(nestingField)
    #SET(nestingField, '')

    #UNIQUENAME(toStringExpr)
    #SET(toStringExpr, '')

    #UNIQUENAME(copyRecordParamExpr)
    #SET(copyRecordParamExpr, '')
    #UNIQUENAME(copyRecordAssignmentExpr)
    #SET(copyRecordAssignmentExpr, '')

    #EXPORTXML(xmlOutput, layout)
    #FOR(xmlOutput)
      #FOR(Field)
        #IF(%{@isEnd}% = 1) // last element of the embedded/nested dataset, record
          #IF(%isInNestedRecord% > 0)
            #APPEND(toStringExpr, ' + ' + %'toStringRecordClosingParamName'%)
          #END
          #SET(isInNestedDataset, 0)
          #SET(isInNestedRecord, 0)
          #SET(nestingField, '')
        #ELSE // not the last element of the embedded/nested dataset, record
          // Set field type begin
          #SET(isDatasetField, 0)
          #SET(isRecordField, 0)
          #SET(isSetField, 0)
          #IF(%StdStr%.StartsWith(%'{@type}'%, 'table')) // dataset field
            #SET(isDatasetField, 1)
          #ELSEIF(%{@isRecord}% = 1) // record field
            #SET(isRecordField, 1)
          #ELSEIF(%StdStr%.StartsWith(%'{@type}'%, 'set')) // set field
            #SET(isSetField, 1)
          #END
          // Set field type end

          // Process begin
          #IF((%isInNestedDataset% = 0) AND (%isInNestedRecord% = 0)) // not in embeded record or embeded dataset
            #IF(%'copyRecordParamExpr'% != '')
              #APPEND(copyRecordParamExpr, ', ')
            #END
            #IF((%isDatasetField% = 1) OR (%isRecordField% = 1))
              #APPEND(copyRecordParamExpr, 'RECORDOF')
            #ELSE
              #APPEND(copyRecordParamExpr, 'TYPEOF')
            #END
            #APPEND(copyRecordParamExpr, '(')
            #APPEND(copyRecordParamExpr, %'rowParamName'% + '.' + %'{@name}'%)
            #APPEND(copyRecordParamExpr, ')')
            #APPEND(copyRecordParamExpr, ' ' + %'{@name}'% + ' = ' + %'rowParamName'% + '.' + %'{@name}'%)
            #IF(%'copyRecordAssignmentExpr'% != '')
              #APPEND(copyRecordAssignmentExpr, ',\n')
            #END
            #APPEND(copyRecordAssignmentExpr, 'SELF.' + %'{@name}'% + ' := ' + %'{@name}'% + '')
          #END

          // not first row of embedded record or nested dataset fields
          #IF((%isRecordField% = 1) AND (%isInNestedRecord% = 0)) // first row of embedded record
          #ELSEIF((%isDatasetField% = 0) AND (%isInNestedDataset% = 1)) // nested dataset fields
          #ELSE
            // ToString begin
            #IF(%'toStringExpr'% != '')
              #APPEND(toStringExpr, ' + ' + %'toStringFieldDelimiterParamName'% + ' + ')
            #END
            #IF(%isInNestedRecord% = 1)
              #APPEND(toStringExpr, %'toStringRecordOpeningParamName'% + ' + ')
              #SET(isInNestedRecord, %isInNestedRecord% + 1)
            #END
            #IF(%'{@type}'% NOT IN ['string'])
              #APPEND(toStringExpr, '(STRING)')
            #END
            #IF((%isDatasetField% = 1) OR (%isSetField% = 1)) // nested dataset & set are replaced by their hash values
              #APPEND(toStringExpr, 'HASH' + '(')
            #END
            #IF(%isInNestedRecord% > 0)
              #APPEND(toStringExpr, %'rowParamName'% + '.' + %'nestingField'% + '.' + %'{@name}'%)
            #ELSE
              #APPEND(toStringExpr, %'rowParamName'% + '.' + %'{@name}'%)
            #END
            #IF((%isDatasetField% = 1) OR (%isSetField% = 1)) // nested dataset & set are replaced by their hash values
              #APPEND(toStringExpr, ')')
            #END
            // ToString end
          #END
          // Process end

          // Update states begin
          #IF(%isDatasetField% = 1)) // dataset field
            #SET(isInNestedDataset, 1)
            #SET(nestingField, %'{@name}'%)
          #ELSEIF(%isRecordField% = 1) // record field
            #SET(isInNestedRecord, 1)
            #SET(nestingField, %'{@name}'%)
          #END
          // Update states end
        #END // last field of the embedded/nested dataset, record
      #END // Field
    #END // xmlOutput
    #SET(toStringExpr, %'toStringRecordOpeningParamName'% + ' + ' + %'toStringExpr'% + ' + ' + %'toStringRecordClosingParamName'%)

    LOCAL ModuleName := MODULE
      /*
      EXPORT STRING ToStringExpression := %'toStringExpr'%;
      EXPORT STRING CopyRecordParamExpression := %'copyRecordParamExpr'%;
      EXPORT STRING CopyRecordAssignmentExpression := %'copyRecordAssignmentExpr'%;
      SHARED InternalLayout := layout;
      */
      /*
        Convert input row (record) to string.
      */
      EXPORT STRING ToString(layout intputRow, STRING fieldDelimiter = ', ', STRING recordOpening = '(', STRING recordClosing = ')') := FUNCTION
        RETURN #EXPAND(%'toStringExpr'% + ';')
      END;
      /*
        Create a copy of row (record) with optional input fields/attributes.
      */
      EXPORT layout CopyRecord(layout intputRow, #EXPAND(%'copyRecordParamExpr'%)) := FUNCTION
        RETURN ROW(
          intputRow,
          TRANSFORM(
            layout,
            #EXPAND(%'copyRecordAssignmentExpr'% + ',\n')
            SELF := LEFT
          )
        );
      END;
    END;
    RETURN ModuleName;
  ENDMACRO;

  /*
    Create slim layout with only given fields.
  */
  EXPORT SlimLayout(layout, fields2Keep) := FUNCTIONMACRO
    #UNIQUENAME(StringUtils)
    IMPORT utils.StringUtils AS %StringUtils%;
    LOCAL LayoutWithfields2Keep := {
      #EXPAND(
        %StringUtils%.JoinTwoSetsOfStrings(
          fields2Keep,
          fields2Keep,
          'TYPEOF(' + #TEXT(layout) + '.',
          '',
          ')',
          '',
          ' ',
          ', '
        )
      )
    };
    RETURN LayoutWithfields2Keep;
  ENDMACRO;

  /*
    Transform a record to a given layout, missing fields get default values.
  */
  EXPORT TransformRecord(inputRow, layout) := FUNCTIONMACRO
    RETURN ROW(
      inputRow,
      TRANSFORM(
        layout,
        SELF := inputRow,
        SELF := []
      )
    );
  ENDMACRO;

  /*
    Get the structure of the input.
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

    LOCAL FieldStructure := RECORD
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
    RETURN DATASET(#EXPAND('[' + %'rowsContent'% + ']'), FieldStructure);
  ENDMACRO;

END;
