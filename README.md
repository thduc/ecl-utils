Ecl-Utils
=======
Utility functions to work with HPCC ECL language.

- [Dataset utilities](#datasetutils)
- [Functional programming utilities](#functionutils)
- ["Random" data generation utilities](#randutils)
- [Record utilities](#recordutils)
- [String utilities](#stringutils)

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

* **SlimDatasetByFields(fields2Keep, inputDS)**: Slim input dataset (aka SELECT), keep only given fields.
  * **fields2Keep**: set of fields to keep.
  * **inputDS**: input dataset.<br/>
_Example_:
```
SlimDatasetByFields(['intVal1', 'stringVal'], ds1) =>

| intval1 | stringval |
|---------|-----------|
| 1       | ab        |
```
* **CreateDataset(layout, inlineDataFields, inlineData)**: Create dataset given the layout, list of fields for inline data, and inline data, fill missing fields with default values.
  * **layout**: layout for target dataset.
  * **inlineDataFields**: set of fields for the `inlineData`.
  * **inlineData**: inline data.<br/>
_Example_:
```
rec4 := {rec1, BOOLEAN boolVal, REAL realVal};
CreateDataset(rec4, ['intVal1', 'intVal2', 'stringVal'], [{1, 2, 'ab'}]) =>

| intval1 | intval2 | stringval | boolval | realval |
|---------|---------|-----------|---------|---------|
| 1       | 2       | ab        | false   | 0.0     |
```
* **TransformDataset(f, inputDS)**: Transform a dataset to a given layout or inline transform function. In case of layout fill missing fields with default values.
  * **f**: either target layout or inline transform function.
  * **inputDS**: input dataset.<br/>
_Example_:
```
rec2 := rec1 AND NOT [intVal2];
TransformDataset(rec2, ds1) =>

| intval1 | stringval |
|---------|-----------|
| 1       | ab        |

rec4 := {rec1, BOOLEAN boolVal, REAL realVal};
TransformDataset(rec4, ds1) =>

| intval1 | intval2 | stringval | boolval | realval |
|---------|---------|-----------|---------|---------|
| 1       | 2       | ab        | false   | 0.0     |

TransformDataset(TRANSFORM(rec4, SELF := LEFT, SELF := []), ds1) =>

| intval1 | intval2 | stringval | boolval | realval |
|---------|---------|-----------|---------|---------|
| 1       | 2       | ab        | false   | 0.0     |
```

---
## FunctionUtils
Functional programming utilities. There exists functions for dataset and set. The functions for set can be obtained from corresponding functions for dataset plus suffix `Set`.

_Example_: Function to filter dataset is `Filter`, function to filter set is `FilterSet`.

There exists some additional functions available for `Set` only (`Map2Sets`, `Map3Sets`, `Aggregate2Sets`, `Aggregate3Sets`).

Following are documentation for functions for dataset. 

```
IntRec1 := {INTEGER value};
intDS1 := DATASET([{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}], IntRec1);
IntStrRec1 := {INTEGER intVal1, INTEGER intVal2, STRING strVal};
```

* **Filter(p, inputDS)**: Filter dataset, return rows satisfying a given predicate.
  * **p**: `A -> Boolean` predicate to filter.
  * **inputDS**: input dataset of type A.<br/>
_Example_:
```
BOOLEAN predicate1(IntRec1 inputRow) := inputRow.value & 0x01 = 0;
FunctionUtils.Filter(predicate1, intDS1) =>

| value |
|-------|
|     2 |
|     4 |
|     6 |
|     8 |
```

* **Map(f, inputDS)**: Map (transform) dataset of type A to type B.
  * **f**: `A -> B` either function or inline transform function.
  * **inputDS**: input dataset of type A.<br/>
_Example_:
```
IntStrRec1 mapper1(IntRec1 x) := ROW({x.value, 10 * x.value, (STRING) x.value}, IntStrRec1);
FunctionUtils.Map(mapper1, intDS1) =>

| intval1 | intval2 | strval |
|---------|---------|--------|
| 1       | 10      | 1      |
| 2       | 20      | 2      |
| 3       | 30      | 3      |
| 4       | 40      | 4      |
| 5       | 50      | 5      |
| 6       | 60      | 6      |
| 7       | 70      | 7      |
| 8       | 80      | 8      |
| 9       | 90      | 9      |

mappedDS2 := FunctionUtils.Map(
  TRANSFORM(
    IntStrRec1,
    SELF := mapper1(LEFT)
  ),
  intDS1
) => same result as above.
```

* **Reduce(f, inputDS)**: Reduce the dataset to an element using the specified associative binary operator.
  * **f**: `(A, A) -> A` either function or inline transform function and must be associative: `f(A, f(B, C)) <=> f(f(A, B), C)`.
  * **inputDS**: input dataset of type A.<br/>
_Example_:
```
IntRec1 reducer11(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1); // add
FunctionUtils.Reduce(reducer11, intDS1) => ROW({45}, IntRec1)

FunctionUtils.Reduce(
  TRANSFORM(
    IntRec1,
    SELF := reducer11(LEFT, RIGHT)
  ),
  intDS1
) => ROW({45}, IntRec1)


IntRec1 reducer12(IntRec1 x, IntRec1 y) := ROW({x.value * y.value}, IntRec1); // multiply
FunctionUtils.Reduce(reducer12, intDS1) => ROW({362880}, IntRec1)
```

* **Aggregate(f, m, z, inputDS)**: Aggregate the results of applying an operator to subsequent elements.
  * **f**: `(B, B) -> B` either function or inline transform function and must be associative: `f(A, f(B, C)) <=> f(f(A, B), C)`.
  * **m**: `(A, B) -> B` either function or inline transform function.
  * **z**: element of type B, initial value for the accumulated result of the partition, this is typically the neutral element for the `m` operator.
  * **inputDS**: input dataset of type A.<br/>
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
neutralRowIntStr1 := ROW({0, 1, ''}, IntStrRec1);
IntStrRec1 mapper2(IntRec1 x, IntStrRec1 z) := ROW({x.value + z.intVal1, x.value * z.intVal2, z.strVal + x.value}, IntStrRec1);
IntStrRec1 reducer2(IntStrRec1 x, IntStrRec1 y) := ROW({x.intVal1 + y.intVal1, x.intVal2 * y.intVal2, x.strVal + '-' + y.strVal}, IntStrRec1);
FunctionUtils.Aggregate(reducer2, mapper2, neutralRowIntStr1, intDS1) => ROW({45, 362880, '1-2-3-4-5-6-7-8-9'}, IntStrRec1)

FunctionUtils.Aggregate(
  TRANSFORM(
    IntStrRec1,
    SELF := reducer2(LEFT, RIGHT)
  ),
  TRANSFORM(
    IntStrRec1,
    SELF := mapper2(LEFT, neutralRowIntStr1)
  ),
  neutralRowIntStr1,
  intDS1
) => same result as above.
```

* **AggregateValue(f, m, zVal, inputDS)**: Similar to the function `Aggregate` above except `zVal` is value (instead of record as before), `m` and `f` must be functions.<br/>
_Example_:
```
INTEGER mapper3(IntRec1 input, INTEGER i) := input.value + i;
INTEGER reducer3(INTEGER a, INTEGER b) := a + b;
FunctionUtils.AggregateValue(reducer3, mapper3, 0, intDS1) => 45
```

* **Scan(f, z, inputDS, isFromRight)**: Produce a dataset containing cumulative results of applying the operator going left to right or right to left.
  * **f**: `(B, A) -> B` (from left to right) or `(A, B) -> B` (from right to left).
  * **z**: element of type B, initial value for the binary operator.
  * **inputDS**: input dataset of type A.
  * **isFromRight**: optional, scan from right -> left or left -> right, default left -> right.<br/>
_Example_:
```
cumSumNeutralRowIntStr1 := ROW({0, 0, '0'}, IntStrRec1);
IntStrRec1 lscanfunc1(IntStrRec1 x, IntRec1 y) := ROW({y.value, x.intVal2 + y.value, x.strVal + ' + ' + (STRING)y.value}, IntStrRec1);
FunctionUtils.Scan(lscanfunc1, cumSumNeutralRowIntStr1, intDS1) => // scan from left -> right.

| intval1 | intval2 | strval                                |
|---------|---------|---------------------------------------|
| 1       | 1       | 0 + 1                                 |
| 2       | 3       | 0 + 1 + 2                             |
| 3       | 6       | 0 + 1 + 2 + 3                         |
| 4       | 10      | 0 + 1 + 2 + 3 + 4                     |
| 5       | 15      | 0 + 1 + 2 + 3 + 4 + 5                 |
| 6       | 21      | 0 + 1 + 2 + 3 + 4 + 5 + 6             |
| 7       | 28      | 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7         |
| 8       | 36      | 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8     |
| 9       | 45      | 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 |


cumProdNeutralRowIntStr1 := ROW({0, 1, '1'}, IntStrRec1);
IntStrRec1 rscanfunc1(IntRec1 x, IntStrRec1 y) := ROW({x.value, x.value * y.intVal2, (STRING)x.value + ' * ' + y.strVal}, IntStrRec1);
FunctionUtils.Scan(rscanfunc1, cumProdNeutralRowIntStr1, intDS1, isFromRight := TRUE) => // scan from right -> left.

| intval1 | intval2 | strval                                |
|---------|---------|---------------------------------------|
| 1       | 362880  | 1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9 * 1 |
| 2       | 362880  | 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9 * 1     |
| 3       | 181440  | 3 * 4 * 5 * 6 * 7 * 8 * 9 * 1         |
| 4       | 60480   | 4 * 5 * 6 * 7 * 8 * 9 * 1             |
| 5       | 15120   | 5 * 6 * 7 * 8 * 9 * 1                 |
| 6       | 3024    | 6 * 7 * 8 * 9 * 1                     |
| 7       | 504     | 7 * 8 * 9 * 1                         |
| 8       | 72      | 8 * 9 * 1                             |
| 9       | 9       | 9 * 1                                 |
```

* **ScanLeft(f, z, inputDS)**: Produce a dataset containing cumulative results of applying the operator going left to right.
  * **f**: `(B, A) -> B` (from left to right).<br/>
_Example_:
```
FunctionUtils.ScanLeft(lscanfunc1, cumSumNeutralRowIntStr1, intDS1) => same as above.
```

* **ScanRight(f, z, inputDS)**: Produce a dataset containing cumulative results of applying the operator going right to left.
  * **f**: `(A, B) -> B` (from right to left).<br/>
_Example_:
```
FunctionUtils.ScanRight(rscanfunc1, cumProdNeutralRowIntStr1, intDS1) => same as above.
```

* **FoldLeft(f, z, inputDS)**: Apply a binary operator to a start value and all elements going left to right.
  * **f**: `(B, A) -> B` the binary operator.
  * **z**: element of type B, initial value for the binary operator.
  * **inputDS**: input dataset of type A.
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
FunctionUtils.FoldLeft(lscanfunc1, cumSumNeutralRowIntStr1, intDS1) => ROW({9, 45, '0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9'}, IntStrRec1)

neutralRowInt1 := ROW({0}, IntRec1);
IntRec1 folder1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
FunctionUtils.FoldLeft(folder1, neutralRowInt1, intDS1) => ROW({45}, IntRec1)
```

* **FoldLeftValue(f, zVal, inputDS)**: Similar to the function `FoldLeft` above except `zVal` is value (instead of record as before).<br/>
_Example_:
```
INTEGER folder2(INTEGER i, IntRec1 r) := i + r.value;
FunctionUtils.FoldLeftValue(folder2, 0, intDS1) => 45


TokenMapRec := {STRING token, STRING value};
tokenMap := DATASET(
  [
    {'[Root]', 'proagrica'},
    {'[Branch]', 'develop'},
    {'[Entities]', 'entities'},
    {'[SourceSystemGroup]', 'uk'},
    {'[SourceSystem]', 'gk'},
    {'[EntityName]', 'crop'},
    {'[Suffix]', 'super'}
  ],
  TokenMapRec
);
STRING replaceToken(STRING inputStr, TokenMapRec r) := Str.FindReplace(inputStr, r.token, r.value);
STRING fileNameTemplate := '~[Root]::[Branch]::[Entities]::[SourceSystemGroup]::[SourceSystem]::[EntityName]::[Suffix]';
FunctionUtils.FoldLeftValue(replaceToken, fileNameTemplate, tokenMap) => '~proagrica::develop::entities::uk::gk::crop::super'
```

* **FoldRight(f, z, inputDS)**: Apply a binary operator to a start value and all elements going right to left.
  * **f**: `(A, B) -> B` the binary operator.
  * **z**: element of type B, initial value for the binary operator.
  * **inputDS**: input dataset of type A.
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
FunctionUtils.FoldRight(rscanfunc1, cumProdNeutralRowIntStr1, intDS1) => ROW({1, 362880, '1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9 * 1'}, IntStrRec1)

FunctionUtils.FoldRight(folder1, neutralRowInt1, intDS1) => ROW({45}, IntRec1)
```

* **FoldRightValue(f, zVal, inputDS)**: Similar to the function `FoldRight` above except `zVal` is value (instead of record as before).<br/>
_Example_:
```
folder3(IntRec1 r, INTEGER i) := r.value + i;
FunctionUtils.FoldRightValue(folder3, 0, intDS1) => 45
```

---
## RandUtils
Utility functions for "random" data generation.

* **NextUnsigned()**: Generate random unsigned integer between `0` and `4294967295`.<br/>
_Example_:
```
NextUnsigned() => 3372947314
```

* **NextDouble()**: Generate random float value between `0` and `1`.<br/>
_Example_:
```
NextDouble() => 0.7770327194074711
```

* **NextBoolean()**: Generate random boolean value (`true` or `false`).<br/>
_Example_:
```
NextBoolean() => true
```

* **NextString(len, charsets)**: Generate random string of the given length from given characters set.
  * **len**: length of the string.
  * **charsets**: set of characters, default is alphanumeric characters.<br/>
_Example_:
```
NextString(5) => 'B4ek0'
```

* **NextUUID()**: Generate random string in [UUID format](https://en.wikipedia.org/wiki/Universally_unique_identifier).
_Example_:
```
NextUUID() => 'ef75b0e5-874d-4f59-d574-1a079e4e79e8'
```

* **CreateHelperModuleForRandomNumericalValue(end1, end2)**: create a helper (utility) module to generate random integer or float between `end1` and `end2`. Module created has the following functions:
  * **NextInt()**: generate random integer between `end1` and `end2`.
  * **NextDouble()**: generate random double between `end1` and `end2`. <br/>
_Example_:
```
mod1 := RandUtils.CreateHelperModuleForRandomNumericalValue(-9, 9);
mod1.NextInt() => -5
mod1.NextInt() => 3
mod1.NextDouble() => -6.673056039417409
mod1.NextDouble() =>  1.943924376960826
```

* **CreateHelperModuleForRandomString(stringLength, characterSets)**: Generate random string of the given length from given characters set.
  * **stringLength**: length of the string.
  * **characterSets**: set of characters, default is alphanumeric characters.

Module created has the following functions:
* **NextString(len, charsets)**: Generate random string of the given length from given characters set.
  * **len**: length of the string, default is `stringLength`.
  * **charsets**: set of characters, default is `characterSets`.<br/>
_Example_:
```
mod3 := RandUtils.CreateHelperModuleForRandomString(5);
mod3.NextString() => 'Vzbey'
mod3.NextString() => 'tHgaS'
```
Following is an example generates dataset
```
m1 := RandUtils.CreateHelperModuleForRandomNumericalValue(-10, 10);
m2 := RandUtils.CreateHelperModuleForRandomNumericalValue(1, 10);
m3 := RandUtils.CreateHelperModuleForRandomString(5);

Rec := {INTEGER intVal, BOOLEAN boolVal, STRING stringVal};
ds := DATASET(
  5,
  TRANSFORM(
    Rec,
    SELF.intVal := m1.NextInt(), // random int between -10 and 10
    SELF.boolVal := DataGenUtils.NextBoolean(), // random boolean
    SELF.stringVal := m3.NextString(m2.NextInt()) // random length (1 to 10) string
  )
)
OUTPUT(ds) =>

| intval | boolval | stringval |
|--------|---------|-----------|
| 5      | TRUE    | FvXK      |
| 1      | TRUE    | qWCbz5    |
| -6     | FALSE   | JlFOGAW   |
| 2      | FALSE   | KvKXkix   |
| 0      | TRUE    | 6diUesh   |
```

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
* **SlimLayout(fields2Keep, layout)**: create a slim layout with only interested fields/attributes.
  * **fields2Keep**: set of fields to keep.
  * **layout**: layout to slim.<br/>
_Example_: `SlimLayout(['intVal1', 'stringVal'], rec1) => {INTEGER intVal1, STRING stringVal}`
* **TransformRecord(layout, inputRow)**: transform a record to a given layout. Fill missing fields (if any) with default values.
  * **layout**: layout Layout.
  * **intputRow**: input row/record.<br/>
_Example_: `TransformRecord(rec1, row3) => row4`

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
