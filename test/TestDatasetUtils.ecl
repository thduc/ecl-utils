#Option('OutputLimit', 2000);
#Workunit('Name', 'TestDatasetUtils');

IMPORT utils.DatasetUtils;

rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};

ds1 := DATASET([{1, 2, 'ab'}], rec1);
ds1;

rec2 := rec1 AND NOT [intVal2];

ds2 := DatasetUtils.TransformDataset(ds1, rec2);
ds2;

ds3 := DatasetUtils.SlimDatasetByFields(ds1, ['intVal1', 'stringVal']);
ds3;

ASSERT(HASH(ds2[1]) = HASH(ds3[1]), 'TransformDataset & SlimDatasetByFields should give the same result.');

rec4 := {rec1, BOOLEAN boolVal, REAL realVal};
ds4 := DatasetUtils.TransformDataset(ds1, rec4);
ds4;

ASSERT(HASH(ds1[1]) = HASH(DatasetUtils.TransformDataset(ds4, rec1)[1]), 'Usage of TransformDataset & SlimDatasetByLayout should produce predictable result.');
