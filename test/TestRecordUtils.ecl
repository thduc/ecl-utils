#Option('OutputLimit', 2000);
#Workunit('Name', 'TestRecordUtils');

IMPORT utils.RecordUtils;

ChildRec := {INTEGER intVal, STRING stringVal};
ParentRec := {BOOLEAN boolVal, ChildRec child, SET OF STRING strings};

childRow := ROW({10, 'abc'}, ChildRec);
parentRow := ROW({TRUE, childRow, ['a', 'b', 'c']}, ParentRec);

modRecordHelper := RecordUtils.CreateHelperModuleForLayout(ParentRec);

modRecordHelper.ToStringExpression;
modRecordHelper.CopyRecordParamExpression;
modRecordHelper.CopyRecordAssignmentExpression;

modRecordHelper.ToString(parentRow);
modRecordHelper.CopyRecord(parentRow, boolVal := FALSE, strings := ['a', 'b']);

s1 := (STRING)parentRow.boolVal + (STRING)parentRow.child.intVal + parentRow.child.stringVal + (STRING)HASH(parentRow.strings);
ASSERT(s1 = modRecordHelper.ToString(parentRow, fieldDelimiter := '', recordOpening := '', recordClosing := ''), 'CreateToStringHelper should work with nested field');

r3 := ROW(
  parentRow,
  TRANSFORM(
    ParentRec,
    SELF.boolVal := FALSE,
    SELF.strings := ['a', 'b'],
    SELF := LEFT
  )
);
ASSERT(HASH(r3) = HASH(modRecordHelper.CopyRecord(parentRow, boolVal := FALSE, strings := ['a', 'b'])), 'CopyRecord should work');

r1 := ROW(parentRow, TRANSFORM({LEFT.boolVal, ChildRec child}, SELF := LEFT));
r2 := ROW(parentRow, TRANSFORM(RecordUtils.CreateSlimLayout(ParentRec, ['boolVal', 'child']), SELF := LEFT));
ASSERT(HASH(r1) = HASH(r2), 'CreateSlimLayout should work with nested field');

RecordUtils.GetFieldStructure(ParentRec);
