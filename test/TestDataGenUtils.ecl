#Option('OutputLimit', 2000);
#Workunit('Name', 'TestDataGenUtils');

IMPORT utils.DataGenUtils;

DataGenUtils.NextUnsigned();
DataGenUtils.NextUnsigned();

DataGenUtils.NextDouble();
DataGenUtils.NextDouble();

DataGenUtils.NextBoolean();
DataGenUtils.NextBoolean();

DataGenUtils.NextString(5, DataGenUtils.DIGITS);
DataGenUtils.NextString(5, DataGenUtils.DIGITS);

mod1 := DataGenUtils.CreateHelperModuleForRandomNumericalValue(-9, 9);
mod1.NextInt();
mod1.NextInt();
mod1.NextDouble();
mod1.NextDouble();

mod3 := DataGenUtils.CreateHelperModuleForRandomString(5);
mod3.NextString();
mod3.NextString();

m1 := DataGenUtils.CreateHelperModuleForRandomNumericalValue(-10, 10);
m2 := DataGenUtils.CreateHelperModuleForRandomNumericalValue(1, 10);
m3 := DataGenUtils.CreateHelperModuleForRandomString(5);

Rec := {INTEGER intVal, BOOLEAN boolVal, STRING stringVal};
ds := DATASET(
  5,
  TRANSFORM(
    Rec,
    SELF.intVal := m1.NextInt(), // random int between -10 and 10
    SELF.boolVal := DataGenUtils.NextBoolean(), // random boolean
    SELF.stringVal := m3.NextString(m2.NextInt()) // random length (1 to 10) string
  )
);
OUTPUT(ds, NAMED('GeneratedDataset'));
