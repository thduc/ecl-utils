#Option('OutputLimit', 2000);
#Workunit('Name', 'TestRandUtils');

IMPORT utils.RandUtils;

RandUtils.NextUnsigned();
RandUtils.NextUnsigned();

RandUtils.NextDouble();
RandUtils.NextDouble();

RandUtils.NextBoolean();
RandUtils.NextBoolean();

RandUtils.NextString(5, RandUtils.DIGITS);
RandUtils.NextString(5, RandUtils.DIGITS);

RandUtils.NextUUID();
RandUtils.NextUUID();

mod1 := RandUtils.CreateHelperModuleForRandomNumericalValue(-9, 9);
mod1.NextInt();
mod1.NextInt();
mod1.NextDouble();
mod1.NextDouble();

mod3 := RandUtils.CreateHelperModuleForRandomString(5);
mod3.NextString();
mod3.NextString();

m1 := RandUtils.CreateHelperModuleForRandomNumericalValue(-10, 10);
m2 := RandUtils.CreateHelperModuleForRandomNumericalValue(1, 10);
m3 := RandUtils.CreateHelperModuleForRandomString(5);

Rec := {INTEGER intVal, BOOLEAN boolVal, STRING stringVal};
ds := DATASET(
  5,
  TRANSFORM(
    Rec,
    SELF.intVal := m1.NextInt(), // random int between -10 and 10
    SELF.boolVal := RandUtils.NextBoolean(), // random boolean
    SELF.stringVal := m3.NextString(m2.NextInt()) // random length (1 to 10) string
  )
);
OUTPUT(ds, NAMED('GeneratedDataset'));
