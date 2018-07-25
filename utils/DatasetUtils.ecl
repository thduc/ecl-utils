EXPORT DatasetUtils := MODULE

  /*
    Slim the dataset keep only given fields.
  */
  EXPORT SlimDatasetByFields(inputDS, fields2Keep) := FUNCTIONMACRO
    #UNIQUENAME(RecordUtils)
    IMPORT utils.RecordUtils AS %RecordUtils%;
    LOCAL Layout := %RecordUtils%.SlimLayout(inputDS, fields2Keep);
    LOCAL outputDS := PROJECT(
      inputDS,
      TRANSFORM(
        Layout,
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
    Create dataset given the layout, list of fields for inline data, and inline data, fill missing fields with default values.
  */
  EXPORT CreateDataset(layout, inlineDataFields, inlineData) := FUNCTIONMACRO
    #UNIQUENAME(RecordUtils)
    #UNIQUENAME(DatasetUtils)
    IMPORT utils.RecordUtils AS %RecordUtils%;
    IMPORT utils.DatasetUtils AS %DatasetUtils%;
    LOCAL slimLayout := %RecordUtils%.SlimLayout(layout, inlineDataFields);
    LOCAL inputDS := DATASET(inlineData, slimLayout);
    LOCAL outputDS := %DatasetUtils%.TransformDataset(inputDS, layout);
    RETURN outputDS;
  ENDMACRO;

  /*
    Transform a dataset to a given layout or inline transform function. In case of layout fill missing fields with default values.
  */
  EXPORT TransformDataset(inputDS, f) := FUNCTIONMACRO
    #UNIQUENAME(hasTransformer)
    #SET(hasTransformer, FALSE)
    #IF(REGEXFIND('^\\s*transform\\s*\\(.+\\)\\s*$', #TEXT(f), NOCASE))
      #SET(hasTransformer, TRUE)
    #ELSE
      LOCAL f transformerFunc(RECORDOF(inputDS) input) := TRANSFORM
        SELF := input;
        SELF := [];
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

END;
