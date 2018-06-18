Ecl-Utils
=======
Utility functions to work with HPCC ECL language.

---
## StringUtils
Utility functions (function macros) to work with string.

* **JoinSetOfStrings**: combine set of string into one single string.
_Example_: `JoinSetOfStrings(['a', 'b'], '(', ')', '-') => (a)-(b)`
* **JoinTwoSetsOfStrings**: create a single string from two set of strings.
_Example_: `JoinTwoSetsOfStrings(['a', 'b'], ['1', '2'], '[', '(', ']', ')', '.', '-') => [a].(1)-[b].(2)`

---
## RecordUtils
Utility functions (function macros) to work with record.

```
rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};
m1 := RecordUtils.CreateHelperModuleForLayout(rec1);
row1 := ROW({1, 1, 'a'}, rec1);
```

* **CreateHelperModuleForLayout**: create a helper (utility) module to work with a given record layout.
  * **ToString**: convert input row/record to string.
  _Example_: `m1.ToString(row1, ', ', '[', ']') => '[1, 1, a]'`
  * **CopyRecord**: create a copy of a record/row with optional input fields/attributes.
  _Example_: `m1.CopyRecord(row1, intVal2 := 2, stringVal := 'b') => ROW({1, 2, 'b'}, rec1)`
* **CreateSlimLayout**: create a slim layout with only interested fields/attributes.
_Example_: `CreateSlimLayout(rec1, ['intVal1', 'stringVal']) => {INTEGER intVal1, STRING stringVal}`
* **GetFieldStructure**: return dataset containing information about data type of a record type or dataset.
_Example_:
```
GetFieldStructure(rec1) =>

| ecltype  | isrecord | isdataset | label     | name      | parentfieldname | position | rawtype | size | type    | 
|----------|----------|-----------|-----------|-----------|-----------------|----------|---------|------|---------| 
| integer8 | FALSE    | FALSE     | intval1   | intval1   |                 | 0        | 524289  | 8    | integer | 
| integer8 | FALSE    | FALSE     | intval2   | intval2   |                 | 1        | 524289  | 8    | integer | 
| string   | FALSE    | FALSE     | stringval | stringval |                 | 2        | -983036 | -15  | string  | 
```