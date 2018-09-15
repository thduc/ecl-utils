#Option('OutputLimit', 2000);
#Workunit('Name', 'TestFunctionUtils');

IMPORT Std.Str;
IMPORT utils.FunctionUtils;

// Sets
SET OF STRING setOfStrings1 := ['a', '1', 'b', '2', 'c', '3', 'd', '4', 'e', '5'];
isDigit(STRING s) := ('0' <= s) AND (s <= '9');
combineIntAndString(INTEGER i, STRING s) := (STRING)i + s;
combineStringAndInt2Int(STRING s, INTEGER i) := (INTEGER)s + i;
combineStringAndInt2String(STRING s, INTEGER i) := s + (STRING)i;
string2Int(STRING s) := (INTEGER)s;
int2String(INTEGER i) := (STRING)i;
sumInts(INTEGER x, INTEGER y) :=  x + y;
stringConcats(STRING s1, STRING s2) := s1 + s2;

SET OF STRING setOfDigits1 := FunctionUtils.FilterSet(setOfStrings1, isDigit);
SET OF INTEGER setOfInts1 := FunctionUtils.MapSet(setOfDigits1, string2Int);
SET OF STRING setOfDigits2 := FunctionUtils.MapSet(setOfInts1, int2String);
STRING stringConcats1 := FunctionUtils.ReduceSet(setOfStrings1, stringConcats);
INTEGER sumInts1 := FunctionUtils.ReduceSet(setOfInts1, sumInts);
STRING aggregateInts1 := FunctionUtils.AggregateSet(setOfInts1, (STRING)'Digit', combineIntAndString, stringConcats);
INTEGER aggregateStrings1 := FunctionUtils.AggregateSet(setOfDigits1, 10, combineStringAndInt2Int, sumInts);
SET OF STRING scanLeftInts1 := FunctionUtils.ScanLeftSet(setOfInts1, (STRING)'Number', combineStringAndInt2String);
SET OF STRING scanRightInts1 := FunctionUtils.ScanRightSet(setOfInts1, (STRING)'Number', combineIntAndString);
STRING foldLeftDigits1 := FunctionUtils.FoldLeftSet(setOfDigits1, (STRING)'Digits', stringConcats);
STRING foldRightDigits1 := FunctionUtils.FoldRightSet(setOfDigits1, (STRING)'Digits', stringConcats);
OUTPUT(setOfStrings1, NAMED('SetOfStrings1'));
OUTPUT(setOfDigits1, NAMED('SetOfDigitsOnly'));
OUTPUT(setOfInts1, NAMED('SetOfInts'));
OUTPUT(setOfDigits2, NAMED('SetOfDigitsMappedFromSetOfInts'));
OUTPUT(stringConcats1, NAMED('ConcatsSetOfStrings'));
OUTPUT(sumInts1, NAMED('SumOfSetOfInts'));
OUTPUT(aggregateInts1, NAMED('AggregateSetOfInts2String'));
OUTPUT(aggregateStrings1, NAMED('AggregateSetOfStrings2Int'));
OUTPUT(scanLeftInts1, NAMED('ScanLeftSetOfInts2String'));
OUTPUT(scanRightInts1, NAMED('ScanRightSetOfInts2String'));
OUTPUT(foldLeftDigits1, NAMED('FoldLeftSetOfDigits2String'));
OUTPUT(foldRightDigits1, NAMED('FoldRightSetOfDigits2String'));


// Datasets
IntRec1 := {INTEGER value};
intDS1 := DATASET([{1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}], IntRec1);
IntStrRec1 := {INTEGER intVal1, INTEGER intVal2, STRING strVal};

BOOLEAN predicate1(IntRec1 x) := x.value & 0x01 = 0;
filteredDS1 := FunctionUtils.Filter(intDS1, predicate1);
OUTPUT(filteredDS1, NAMED('FilteredDS1'));

IntStrRec1 mapper1(IntRec1 x) := ROW({x.value, 10 * x.value, (STRING) x.value}, IntStrRec1);
mappedDS1 := FunctionUtils.Map(intDS1, mapper1);
OUTPUT(mappedDS1, NAMED('MappedDS1'));
mappedDS2 := FunctionUtils.Map(
  intDS1,
  TRANSFORM(
    IntStrRec1,
    SELF := mapper1(LEFT)
  )
);
OUTPUT(mappedDS2, NAMED('MappedDS2'));

IntRec1 reducer11(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
IntRec1 reducer12(IntRec1 x, IntRec1 y) := ROW({x.value * y.value}, IntRec1);
rr1 := FunctionUtils.Reduce(intDS1, reducer11);
rr2 := FunctionUtils.Reduce(
  intDS1,
  TRANSFORM(
    IntRec1,
    SELF := reducer11(LEFT, RIGHT)
  )
);
rr3 := FunctionUtils.Reduce(intDS1, reducer12);
ASSERT(rr1.value = 45, 'Reduce (add) must produce correct results.');
ASSERT(HASH(rr1) = HASH(rr2), 'Reduce inline and external must produce the same results.');
ASSERT(rr3.value = 362880, 'Reduce (multiply) must produce correct results.');

neutralRowIntStr1 := ROW({0, 1, ''}, IntStrRec1);
IntStrRec1 mapper2(IntRec1 x, IntStrRec1 z) := ROW({x.value + z.intVal1, x.value * z.intVal2, z.strVal + x.value}, IntStrRec1);
IntStrRec1 reducer2(IntStrRec1 x, IntStrRec1 y) := ROW({x.intVal1 + y.intVal1, x.intVal2 * y.intVal2, x.strVal + '-' + y.strVal}, IntStrRec1);
ar1 := FunctionUtils.Aggregate(intDS1, neutralRowIntStr1, mapper2, reducer2);
ar2 := FunctionUtils.Aggregate(
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
);
OUTPUT(ar1, NAMED('AggregateRow1'));
ASSERT((ar1.intVal1 = 45) AND (ar1.intVal2 = 362880) AND (ar1.strVal = '1-2-3-4-5-6-7-8-9'), 'Aggregate must produce correct results.');
ASSERT(HASH(ar1) = HASH(ar2), 'Aggregate inline and external must produce the same results.');

INTEGER mapper3(IntRec1 x, INTEGER i) := x.value + i;
INTEGER reducer3(INTEGER x, INTEGER y) := x + y;
ar3 := FunctionUtils.AggregateValue(intDS1, 0, mapper3, reducer3);
ASSERT(ar3 = 45, 'AggregateValue must produce correct results.');

cumSumNeutralRowIntStr1 := ROW({0, 0, '0'}, IntStrRec1);
IntStrRec1 lscanfunc1(IntStrRec1 x, IntRec1 y) := ROW({y.value, x.intVal2 + y.value, x.strVal + ' + ' + (STRING)y.value}, IntStrRec1);
scanDS1 := FunctionUtils.Scan(intDS1, cumSumNeutralRowIntStr1, lscanfunc1);
OUTPUT(scanDS1, NAMED('ScanDS1'));
scanLeftDS1 := FunctionUtils.ScanLeft(intDS1, cumSumNeutralRowIntStr1, lscanfunc1);
OUTPUT(scanLeftDS1, NAMED('ScanLeftDS1'));

cumProdNeutralRowIntStr1 := ROW({0, 1, '1'}, IntStrRec1);
IntStrRec1 rscanfunc1(IntRec1 x, IntStrRec1 y) := ROW({x.value, x.value * y.intVal2, (STRING)x.value + ' * ' + y.strVal}, IntStrRec1);
scanDS2 := FunctionUtils.Scan(intDS1, cumProdNeutralRowIntStr1, rscanfunc1, isFromRight := TRUE);
OUTPUT(scanDS2, NAMED('ScanDS2'));
scanRightDS1 := FunctionUtils.ScanRight(intDS1, cumProdNeutralRowIntStr1, rscanfunc1);
OUTPUT(scanRightDS1, NAMED('ScanRightDS1'));

foldLeftRow1 := FunctionUtils.FoldLeft(intDS1, cumSumNeutralRowIntStr1, lscanfunc1);
OUTPUT(foldLeftRow1, NAMED('FoldLeftRow1'));

sumNeutralRowInt1 := ROW({0}, IntRec1);
IntRec1 folder1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
foldLeftRow2 := FunctionUtils.FoldLeft(intDS1, sumNeutralRowInt1, folder1);
ASSERT(foldLeftRow2.value = 45, 'FoldLeft must produce correct results.');
INTEGER folder2(INTEGER i, IntRec1 r) := i + r.value;
foldLeftVal1 := FunctionUtils.FoldLeftValue(intDS1, 0, folder2);
ASSERT(foldLeftVal1 = 45, 'FoldLeftValue must produce correct results.');

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
STRING replaceToken(STRING xStr, TokenMapRec r) := Str.FindReplace(xStr, r.token, r.value);
STRING fileNameTemplate := '~[Root]::[Branch]::[Entities]::[SourceSystemGroup]::[SourceSystem]::[EntityName]::[Suffix]';
cropSupeFileName := FunctionUtils.FoldLeftValue(tokenMap, fileNameTemplate, replaceToken);
ASSERT(cropSupeFileName = '~proagrica::develop::entities::uk::gk::crop::super', 'FoldLeftValue must produce correct results.');

foldRightRow1 := FunctionUtils.FoldRight(intDS1, cumProdNeutralRowIntStr1, rscanfunc1);
OUTPUT(foldRightRow1, NAMED('FoldRightRow1'));

foldRightRow2 := FunctionUtils.FoldRight(intDS1, sumNeutralRowInt1, folder1);
ASSERT(HASH(foldLeftRow2) = HASH(foldRightRow2), 'FoldLeft & FoldRight should produce the same results.');
folder3(IntRec1 r, INTEGER i) := i + r.value;
foldRightVal1 := FunctionUtils.FoldRightValue(intDS1, 0, folder3);
ASSERT(foldLeftVal1 = foldRightVal1, 'FoldLeftValue & FoldRightValue should produce the same results.');
