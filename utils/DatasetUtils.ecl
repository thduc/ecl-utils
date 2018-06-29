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
      )
    );
    RETURN outputDS;
  ENDMACRO;

  /*
    Transform a dataset to a given layout. Fill missing fields with default values.
  */
  EXPORT TransformDataset(inputDS, Layout) := FUNCTIONMACRO
    LOCAL outputDS := PROJECT(
      inputDS,
      TRANSFORM(
        Layout,
        SELF := LEFT,
        SELF := []
      )
    );
    RETURN outputDS;
  ENDMACRO;

END;
