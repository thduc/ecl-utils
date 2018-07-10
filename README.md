Ecl-Utils
=======
Utility functions to work with HPCC ECL language.

- [String utilities](#stringutils)
- [Record utilities](#recordutils)
- [Dataset utilities](#datasetutils)
- [Functional programming utilities](#functionutils)

---
## StringUtils
Utility functions (function macros) to work with string.

* **JoinSetOfStrings(stringSet, elementPrefix, elementPostfix, opCombine)**: combines set of strings into one single string.
  * **stringSet**: set of input strings.
  * **elementPrefix**: text to preprend to every item of the set.
  * **elementPostfix**: text to append to every item of the set.
  * **opCombine**: text that connects two consecutive items.<br/>
_Example_: `JoinSetOfStrings(['a', 'b'], '(', ')', '-') => (a)-(b)`
* **JoinTwoSetsOfStrings(leftSet, rightSet, prefixLeft, prefixRight, postfixLeft, postfixRight, opElement, opCombine)**: create a single string from two set of strings.
  * **leftSet**: first set of input strings.
  * **rightSet**: second set of input strings.
  * **prefixLeft**: text to preprend to every item of the first set.
  * **prefixRight**: text to preprend to every item of the second set.
  * **postfixLeft**: text to append to every item of the first set.
  * **postfixRight**: text to append to every item of the second set.
  * **opElement**: text that connects two items from first & second sets.
  * **opCombine**: text that connects two consecutive pair of items.<br/>
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

* **CreateHelperModuleForLayout(layout)**: create a helper (utility) module to work with a given record layout. Module created has the following functions:
  * **ToString(layout intputRow, STRING fieldDelimiter = ', ', STRING recordOpening = '(', STRING recordClosing = ')')**: convert input row/record to string.
    * **intputRow**: input row/record.
    * **fieldDelimiter**: seperator.
    * **recordOpening**: text to prepend.
    * **recordClosing**: text to append.<br/>
  _Example_: `m1.ToString(row1, ', ', '[', ']') => '[1, 1, a]'`
  * **CopyRecord(layout intputRow[, fieldName = value])**: create a copy of a record/row with optional input fields/attributes.
    * **intputRow**: input row/record.
    * **fieldName**: comma-delimited list of fields to update value.<br/>
  _Example_: `m1.CopyRecord(row1, intVal2 := 2, stringVal := 'b') => row2`
* **SlimLayout(layout, fields2Keep)**: create a slim layout with only interested fields/attributes.
  * **layout**: layout to slim.
  * **fields2Keep**: set of fields to keep.<br/>
_Example_: `SlimLayout(rec1, ['intVal1', 'stringVal']) => {INTEGER intVal1, STRING stringVal}`
* **TransformRecord(inputRow, layout)**: transform a record to a given layout. Fill missing fields (if any) with default values.
  * **intputRow**: input row/record.
  * **layout**: layout Layout.<br/>
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

* **SlimDatasetByFields(inputDS, fields2Keep)**: Slim input dataset (aka SELECT), keep only given fields.
  * **inputDS**: input dataset.
  * **fields2Keep**: set of fields to keep.<br/>
_Example_:
```
SlimDatasetByFields(ds1, ['intVal1', 'stringVal']) =>

| intval1 | stringval |
|---------|-----------|
| 1       | ab        |
```
* **TransformDataset(inputDS, f)**: Transform a dataset to a given layout or inline transform function. In case of Layout fill missing fields with default values.
  * **inputDS**: input dataset.
  * **f**: either target layout or inline transform function.<br/>
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

---
## FunctionUtils
Functional programming utilities.

```
IntRec1 := {INTEGER value};
intDS1 := DATASET([{0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}], IntRec1);
IntStrRec1 := {INTEGER intVal, STRING strVal};
```

* **Filter(inputDS, p)**: Filter dataset, return rows satisfying a given predicate.
  * **inputDS**: input dataset of type A.
  * **p**: `A -> Boolean` predicate to filter.<br/>
_Example_:
```
BOOLEAN predicate1(IntRec1 inputRow) := inputRow.value & 0x01 = 0;
Filter(intDS1, predicate1) =>

| value |
|-------|
|     0 |
|     2 |
|     4 |
|     6 |
|     8 |
```

* **Map(inputDS, f)**: Map (transform) dataset of type A to type B.
  * **inputDS**: input dataset of type A.
  * **f**: `A -> B` either function or inline transform function.<br/>
_Example_:
```
IntStrRec1 mapper1(IntRec1 inputRow) := ROW({inputRow.value, (STRING) inputRow.value}, IntStrRec1);
Map(intDS1, mapper1) =>

| intval | strval |
|--------|--------|
|      0 |      0 |
|      1 |      1 |
|      2 |      2 |
|      3 |      3 |
|      4 |      4 |
|      5 |      5 |
|      6 |      6 |
|      7 |      7 |
|      8 |      8 |
|      9 |      9 |

Map(
  intDS1,
  TRANSFORM(
    IntStrRec1,
    SELF := mapper1(LEFT)
  )
) => the same result as above.
```

* **Reduce(inputDS, f)**: Reduce the dataset to an element using the specified associative binary operator.
  * **inputDS**: input dataset of type A.
  * **f**: `(A, A) -> A` either function or inline transform function and must be associative: `f(A, f(B, C)) <=> f(f(A, B), C)`.<br/>
_Example_:
```
IntRec1 reducer1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
Reduce(intDS1, reducer1) => ROW({45}, IntRec1)

Reduce(
  intDS1,
  TRANSFORM(
    IntRec1,
    SELF := reducer1(LEFT, RIGHT)
  )
) => ROW({45}, IntRec1)
```

* **Aggregate(inputDS, z, m, f)**: Aggregate the results of applying an operator to subsequent elements.
  * **inputDS**: input dataset of type A.
  * **z**: element of type B, initial value for the accumulated result of the partition, this is typically the neutral element for the `m` operator.
  * **m**: `(A, B) -> B` either function or inline transform function.<br/>
  * **f**: `(B, B) -> B` either function or inline transform function and must be associative: `f(A, f(B, C)) <=> f(f(A, B), C)`.
```
        ----- B -----
       /             \        reduce (f)
    - B -           - B -
   /     \         /     \    reduce (f)
  B       B       B       B
 / \     / \     / \     / \  map (m)
A   z   A   z   A   z   A   z
```
_Example_:
```
neutralRowIntStr1 := ROW({0, ''}, IntStrRec1);
IntStrRec1 mapper2(IntRec1 input, IntStrRec1 z) := ROW({input.value + z.intVal, z.strVal + input.value}, IntStrRec1);
IntStrRec1 reducer2(IntStrRec1 a, IntStrRec1 b) := ROW({a.intVal + b.intVal, a.strVal + b.strVal}, IntStrRec1);
Aggregate(intDS1, neutralRowIntStr1, mapper2, reducer2) => ROW({45, '0123456789'}, IntStrRec1)

Aggregate(
  intDS1,
  neutralRowIntStr1,
  TRANSFORM(
    IntStrRec1,
    SELF := mapper2(LEFT, neutralRowIntStr1)
  ),
  TRANSFORM(
    IntStrRec1,
    SELF := reducer2(LEFT, RIGHT)
  )
) => ROW({45, '0123456789'}, IntStrRec1)
```

* **AggregateValue(inputDS, zVal, m, f)**: Similar to the function `Aggregate` above except `zVal` is value (instead of record as before), `m` and `f` must be functions.<br/>
_Example_:
```
INTEGER mapper3(IntRec1 input, INTEGER i) := input.value + i;
INTEGER reducer3(INTEGER a, INTEGER b) := a + b;
AggregateValue(intDS1, 0, mapper3, reducer3) => 45
```

* **FoldLeft(inputDS, z, f)**: Apply a binary operator to a start value and all elements going left to right.
  * **inputDS**: input dataset of type A.
  * **z**: element of type B, initial value for the binary operator.
  * **f**: `(B, A) -> B` the binary operator.
```
  :           FoldLeft           f
 / \          ------->          / \
1   :                          f   5
   / \                        / \
  2   :                      f   4
     / \                    / \
    3   :                  f   3
       / \                / \
      4   :              f   2
         / \            / \
        5  []          z   1
```
_Example_:
```
neutralRowInt1 := ROW({0}, IntRec1);
IntRec1 folder1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
FoldLeft(intDS1, neutralRowInt1, folder1) => ROW({45}, IntRec1)
```

* **FoldLeftValue(inputDS, zVal, f)**: Similar to the function `FoldLeft` above except `zVal` is value (instead of record as before).<br/>
_Example_:
```
INTEGER folder2(INTEGER i, IntRec1 r) := i + r.value;
FoldLeftValue(intDS1, 0, folder2) => 45


TokenMapRec := {STRING token, STRING value};
tokenMap := DATASET(
  [
    {'[SourceSystemGroup]', 'uk'},
    {'[SourceSystem]', 'gk'},
    {'[Root]', 'proagrica'},
    {'[Branch]', 'develop'},
    {'[Entities]', 'entities'},
    {'[EntityName]', 'crop'},
    {'[Suffix]', 'super'}
  ],
  TokenMapRec
);
STRING replaceToken(STRING inputStr, TokenMapRec r) := Str.FindReplace(inputStr, r.token, r.value);
fileNameTemplate := '~[Root]::[Branch]::[Entities]::[SourceSystemGroup]::[SourceSystem]::[EntityName]::[Suffix]';
FoldLeftValue(tokenMap, fileNameTemplate, replaceToken) => '~proagrica::develop::entities::uk::gk::crop::super'
```

* **FoldRight(inputDS, z, f)**: Apply a binary operator to a start value and all elements going right to left.
  * **inputDS**: input dataset of type A.
  * **z**: element of type B, initial value for the binary operator.
  * **f**: `(A, B) -> B` the binary operator.
```
  :           FoldRight     f
 / \          -------->    / \
1   :                     1   f
   / \                       / \
  2   :                     2   f
     / \                       / \
    3   :                     3   f
       / \                       / \
      4   :                     4   f
         / \                       / \
        5  []                     5   z
```
_Example_:
```
FoldRight(intDS1, neutralRowInt1, folder1) => ROW({45}, IntRec1)
```

* **FoldRightValue(inputDS, zVal, f)**: Similar to the function `FoldRight` above except `zVal` is value (instead of record as before).<br/>
_Example_:
```
folder3(IntRec1 r, INTEGER i) := r.value + i;
FoldRightValue(intDS1, 0, folder3) => 45
```
