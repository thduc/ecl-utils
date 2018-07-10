#Option('OutputLimit', 2000);
#Workunit('Name', 'TestFunctionUtils');

IMPORT Std.Str;
IMPORT utils.FunctionUtils;

IntRec1 := {INTEGER value};
intDS1 := DATASET([{0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}], IntRec1);
IntStrRec1 := {INTEGER intVal, STRING strVal};

BOOLEAN predicate1(IntRec1 inputRow) := inputRow.value & 0x01 = 0;
filteredDS1 := FunctionUtils.Filter(intDS1, predicate1);
OUTPUT(filteredDS1, NAMED('FilteredDS1'));

IntStrRec1 mapper1(IntRec1 inputRow) := ROW({inputRow.value, (STRING) inputRow.value}, IntStrRec1);
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

IntRec1 reducer1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
reduceRow1 := FunctionUtils.Reduce(intDS1, reducer1);
reduceRow2 := FunctionUtils.Reduce(
  intDS1,
  TRANSFORM(
    IntRec1,
    SELF := reducer1(LEFT, RIGHT)
  )
);
ASSERT(reduceRow1.value = 45, 'Reduce must produce correct results.');
ASSERT(HASH(reduceRow1) = HASH(reduceRow2), 'Reduce inline and external must produce the same results.');

neutralRowIntStr1 := ROW({0, ''}, IntStrRec1);
IntStrRec1 mapper2(IntRec1 input, IntStrRec1 z) := ROW({input.value + z.intVal, z.strVal + input.value}, IntStrRec1);
IntStrRec1 reducer2(IntStrRec1 a, IntStrRec1 b) := ROW({a.intVal + b.intVal, a.strVal + b.strVal}, IntStrRec1);
aggregateRow1 := FunctionUtils.Aggregate(intDS1, neutralRowIntStr1, mapper2, reducer2);
aggregateRow2 := FunctionUtils.Aggregate(
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
ASSERT((aggregateRow1.intVal = 45) AND (aggregateRow1.strVal = '0123456789'), 'Aggregate must produce correct results.');
ASSERT(HASH(aggregateRow1) = HASH(aggregateRow2), 'Aggregate inline and external must produce the same results.');

INTEGER mapper3(IntRec1 input, INTEGER i) := input.value + i;
INTEGER reducer3(INTEGER a, INTEGER b) := a + b;
aggregateValue3 := FunctionUtils.AggregateValue(intDS1, 0, mapper3, reducer3);
ASSERT(aggregateValue3 = 45, 'AggregateValue must produce correct results.');

neutralRowInt1 := ROW({0}, IntRec1);
IntRec1 folder1(IntRec1 x, IntRec1 y) := ROW({x.value + y.value}, IntRec1);
flRow1 := FunctionUtils.FoldLeft(intDS1, neutralRowInt1, folder1);
ASSERT(flRow1.value = 45, 'FoldLeft must produce correct results.');
INTEGER folder2(INTEGER i, IntRec1 r) := i + r.value;
fl1 := FunctionUtils.FoldLeftValue(intDS1, 0, folder2);

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
cropSupeFileName := FunctionUtils.FoldLeftValue(tokenMap, fileNameTemplate, replaceToken);
ASSERT(cropSupeFileName = '~proagrica::develop::entities::uk::gk::crop::super', 'FoldLeftValue must produce correct results.');

ASSERT(fl1 = 45, 'FoldLeftValue must produce correct results.');
frRow1 := FunctionUtils.FoldRight(intDS1, neutralRowInt1, folder1);
ASSERT(HASH(flRow1) = HASH(frRow1), 'FoldLeft & FoldRight should produce the same results.');
folder3(IntRec1 r, INTEGER i) := i + r.value;
fr1 := FunctionUtils.FoldRightValue(intDS1, 0, folder3);
ASSERT(fl1 = fr1, 'FoldLeftValue & FoldRightValue should produce the same results.');
