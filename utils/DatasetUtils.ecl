EXPORT DatasetUtils := MODULE

  /*
    Slim the dataset keep only given fields.
  */
  EXPORT SlimDatasetByFields(inputDS, Fields2Keep) := FUNCTIONMACRO
    #UNIQUENAME(RecordUtils)
    IMPORT utils.RecordUtils AS %RecordUtils%;
    LOCAL Layout := %RecordUtils%.SlimLayout(inputDS, Fields2Keep);
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
    Transform a dataset to a given layout or inline transform function. In case of Layout fill missing fields with default values.
  */
  EXPORT TransformDataset(inputDS, TransLayout) := FUNCTIONMACRO
    #UNIQUENAME(hasTransformer)
    #SET(hasTransformer, FALSE)
    #IF(REGEXFIND('^\\s*transform\\s*\\(.+\\)\\s*$', #TEXT(TransLayout), NOCASE))
      #SET(hasTransformer, TRUE)
    #ELSE
      LOCAL TransLayout transformerFunc(RECORDOF(inputDS) input) := TRANSFORM
        SELF := input;
        SELF := [];
      END;
    #END
    LOCAL outputDS := PROJECT(
      inputDS,
      #IF(%hasTransformer%)
        TransLayout
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
