Ecl-Utils
=======
Utility functions to work with HPCC ECL language.

---
## StringUtils
Utility functions (function macros) to work with string.

* **JoinSetOfStrings(StringSet, ElementPrefix, ElementPostfix, OpCombine)**: combines set of strings into one single string.
  * **StringSet**: set of input strings.
  * **ElementPrefix**: text to preprend to every item of the set.
  * **ElementPostfix**: text to append to every item of the set.
  * **OpCombine**: text that connects two consecutive items.<br/>
_Example_: `JoinSetOfStrings(['a', 'b'], '(', ')', '-') => (a)-(b)`
* **JoinTwoSetsOfStrings(LeftSet, RightSet, PrefixLeft, PrefixRight, PostfixLeft, PostfixRight, OpElement, OpCombine)**: create a single string from two set of strings.<br/>
  * **LeftSet**: first set of input strings.
  * **RightSet**: second set of input strings.
  * **PrefixLeft**: text to preprend to every item of the first set.
  * **PrefixRight**: text to preprend to every item of the second set.
  * **PostfixLeft**: text to append to every item of the first set.
  * **PostfixRight**: text to append to every item of the second set.
  * **OpElement**: text that connects two items from first & second sets.
  * **OpCombine**: text that connects two consecutive pair of items.<br/>
_Example_: `JoinTwoSetsOfStrings(['a', 'b'], ['1', '2'], '[', '(', ']', ')', '.', '-') => [a].(1)-[b].(2)`

---
## RecordUtils
Utility functions (function macros) to work with record.

```
rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};
m1 := RecordUtils.CreateHelperModuleForLayout(rec1);
row1 := ROW({1, 1, 'a'}, rec1);
row2 := ROW({1, 2, 'b'}, rec1);
rec2 := RecordUtils.SlimLayout(rec1, ['intVal1', 'stringVal']);
row3 := ROW({1, 'a'}, rec2);
row4 := ROW({1, 0, 'a'}, rec1);
```

* **CreateHelperModuleForLayout(Layout)**: create a helper (utility) module to work with a given record layout. Module created has the following functions:
  * **ToString(Layout intputRow, STRING fieldDelimiter = ', ', STRING recordOpening = '(', STRING recordClosing = ')')**: convert input row/record to string.
    * **intputRow**: input row/record.
    * **fieldDelimiter**: seperator.
    * **recordOpening**: text to prepend.
    * **recordClosing**: text to append.<br/>
  _Example_: `m1.ToString(row1, ', ', '[', ']') => '[1, 1, a]'`
  * **CopyRecord(Layout intputRow[, fieldName = value])**: create a copy of a record/row with optional input fields/attributes.
    * **intputRow**: input row/record.
    * **fieldName**: comma-delimited list of fields to update value.<br/>
  _Example_: `m1.CopyRecord(row1, intVal2 := 2, stringVal := 'b') => row2`
* **SlimLayout(Layout, Fields2Keep)**: create a slim layout with only interested fields/attributes.
  * **Layout**: Layout to slim.
  * **Fields2Keep**: set of fields to keep.<br/>
_Example_: `SlimLayout(rec1, ['intVal1', 'stringVal']) => {INTEGER intVal1, STRING stringVal}`
* **TransformRecord(inputRow, Layout)**: transform a record to a given layout. Fill missing fields (if any) with default values.
  * **intputRow**: input row/record.
  * **Layout**: target Layout.<br/>
_Example_: `TransformRecord(row3, rec1) => row4`

* **GetFieldStructure(input)**: return dataset containing information about data type of a record type or dataset.
  * **input**: dataset or layout.<br/>
_Example_:
```
GetFieldStructure(rec1) =>

| ecltype  | isrecord | isdataset | label     | name      | parentfieldname | position | rawtype | size | type    | 
|----------|----------|-----------|-----------|-----------|-----------------|----------|---------|------|---------| 
| integer8 | FALSE    | FALSE     | intval1   | intval1   |                 | 0        | 524289  | 8    | integer | 
| integer8 | FALSE    | FALSE     | intval2   | intval2   |                 | 1        | 524289  | 8    | integer | 
| string   | FALSE    | FALSE     | stringval | stringval |                 | 2        | -983036 | -15  | string  | 
```

---
## DatasetUtils
Utility functions (function macros) to work with dataset.

```
rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};
ds1 := DATASET([{1, 2, 'ab'}], rec1);

OUTPUT(ds1) =>

| intval1 | intval2 | stringval | 
|---------|---------|-----------| 
| 1       | 2       | ab        | 
```

* **SlimDatasetByFields(inputDS, Fields2Keep)**: Slim input dataset (aka SELECT), keep only given fields.
  * **inputDS**: input dataset.
  * **Fields2Keep**: set of fields to keep.<br/>
_Example_:
```
SlimDatasetByFields(ds1, ['intVal1', 'stringVal']) =>

| intval1 | stringval | 
|---------|-----------| 
| 1       | ab        | 
```
* **TransformDataset(inputDS, TransLayout)**: Transform a dataset to a given layout or inline transform function. In case of Layout fill missing fields with default values.
  * **inputDS**: input dataset.
  * **TransLayout**: either target layout or inline transform function.<br/>
_Example_:
```
rec2 := rec1 AND NOT [intVal2];
TransformDataset(ds1, rec2) =>

| intval1 | stringval | 
|---------|-----------| 
| 1       | ab        | 

rec4 := {rec1, BOOLEAN boolVal, REAL realVal};
TransformDataset(ds1, rec4) =>

| intval1 | intval2 | stringval | boolval | realval | 
|---------|---------|-----------|---------|---------| 
| 1       | 2       | ab        | false   | 0.0     | 

TransformDataset(ds1, TRANSFORM(rec4, SELF := LEFT, SELF := [])) =>
| intval1 | intval2 | stringval | boolval | realval | 
|---------|---------|-----------|---------|---------| 
| 1       | 2       | ab        | false   | 0.0     | 
```
