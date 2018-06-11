#Option('OutputLimit', 2000);
#Workunit('Name', 'TestDatasetUtils');

IMPORT utils.DatasetUtils;
IMPORT utils.RecordUtils;

ChildRec := {INTEGER intVal, STRING stringVal};
ParentRec := {BOOLEAN boolVal, ChildRec child, SET OF STRING strings};

childRow := ROW({1, 'abc'}, ChildRec);
parentRow := ROW({TRUE, childRow, ['a', 'b', 'c']}, ParentRec);

r1 := ROW(parentRow, TRANSFORM({LEFT.boolVal, ChildRec child}, SELF := LEFT));
r2 := ROW(parentRow, TRANSFORM(DatasetUtils.CreateSlimLayout(ParentRec, ['boolVal', 'child']), SELF := LEFT));
ASSERT(HASH(r1) = HASH(r2), 'CreateSlimLayout should work with nested field');

modRecordHelper := RecordUtils.CreateHelperModuleForLayout(ParentRec);
s1 := (STRING)parentRow.boolVal + (STRING)parentRow.child.intVal + parentRow.child.stringVal + (STRING)HASH(parentRow.strings);
ASSERT(s1 = modRecordHelper.ToString(parentRow), 'CreateToStringHelper should work with nested field');

DatasetUtils.GetFieldStructure(ParentRec);
