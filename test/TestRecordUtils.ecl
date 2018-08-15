#Option('OutputLimit', 2000);
#Workunit('Name', 'TestRecordUtils');

IMPORT utils.RecordUtils;

rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};
m1 := RecordUtils.CreateHelperModuleForLayout(rec1);
row1 := ROW({1, 1, 'a'}, rec1);
row2 := ROW({1, 2, 'b'}, rec1);

ASSERT(m1.ToString(row1, ', ', '[', ']') = '[1, 1, a]', 'ToString should correctly convert record to string.');
ASSERT(HASH(m1.CopyRecord(row1, intVal2 := 2, stringVal := 'b')) = HASH(row2), 'CopyRecord should correctly copy record fields.');

rec2 := RecordUtils.SlimLayout(rec1, ['intVal1', 'stringVal']);
row3 := ROW({1, 'a'}, rec2);
row4 := ROW({1, 0, 'a'}, rec1);
ASSERT(HASH(RecordUtils.TransformRecord(row3, rec1)) = HASH(row4), 'TransformRecord should correctly set default values for un-specified fiels.');

RecordUtils.GetFieldStructure(rec1);
