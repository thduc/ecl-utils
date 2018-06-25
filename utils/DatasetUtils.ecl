EXPORT DatasetUtils := MODULE

  /*
    Slim input dataset by a given layout.
  */
  EXPORT SlimDatasetByLayout(inputDS, Layout) := FUNCTIONMACRO
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
    Slim the dataset keep only given fields.
  */
  EXPORT SlimDatasetByFields(inputDS, Fields2Keep) := FUNCTIONMACRO
    #UNIQUENAME(RecordUtils)
    IMPORT utils.RecordUtils AS %RecordUtils%;
    LOCAL Layout := %RecordUtils%.CreateSlimLayout(inputDS, Fields2Keep);
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
    Enlarge dataset (make it wider) to a given layout. Fill missing fields with default values.
  */
  EXPORT ExpandDataset(inputDS, Layout) := FUNCTIONMACRO
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
