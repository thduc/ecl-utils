﻿#Option('OutputLimit', 2000);
#Workunit('Name', 'TestDatasetUtils');

IMPORT utils.DatasetUtils;

rec1 := {INTEGER intVal1, INTEGER intVal2, STRING stringVal};

ds1 := DATASET([{1, 2, 'ab'}], rec1);
ds1;

rec2 := rec1 AND NOT [intVal2];

ds2 := DatasetUtils.TransformDataset(rec2, ds1);
ds2;

ds3 := DatasetUtils.SlimDatasetByFields(['intVal1', 'stringVal'], ds1);
ds3;

ASSERT(HASH(ds2[1]) = HASH(ds3[1]), 'TransformDataset & SlimDatasetByFields should give the same result.');

rec4 := {rec1, BOOLEAN boolVal, REAL realVal};
ds4 := DatasetUtils.TransformDataset(rec4, ds1);
ds4;
ds5 := DatasetUtils.TransformDataset(TRANSFORM(rec4, SELF := LEFT, SELF := []), ds1);
ds5;

ASSERT(HASH(ds1[1]) = HASH(DatasetUtils.TransformDataset(rec1, ds4)[1]), 'Usage of TransformDataset & SlimDatasetByLayout should produce predictable result.');
ASSERT(HASH(ds4[1]) = HASH(ds5[1]), 'Usage of TransformDataset with Layout or with Transform function should produce the same result.');

ds6 := DatasetUtils.CreateDataset(rec4, ['intVal1', 'intVal2', 'stringVal'], [{1, 2, 'ab'}]);
ds6;
