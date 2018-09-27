#Option('OutputLimit', 2000);
#Workunit('Name', 'TestStringUtils');

IMPORT utils.StringUtils;

SET OF STRING emptySet := [];

ASSERT('' = StringUtils.JoinSetOfStrings(emptySet, '(', ')', '-'), 'JoinSetOfStrings should work with empty set');
ASSERT('()' = StringUtils.JoinSetOfStrings([''], '(', ')', '-'), 'JoinSetOfStrings should work with set contains single empty item');
ASSERT('(a)' = StringUtils.JoinSetOfStrings(['a'], '(', ')', '-'), 'JoinSetOfStrings should work with set contains single non-empty item');
ASSERT('(a)-()' = StringUtils.JoinSetOfStrings(['a', ''], '(', ')', '-'), 'JoinSetOfStrings should work with set contains empty and non-empty items');
ASSERT('(a)-(b)' = StringUtils.JoinSetOfStrings(['a', 'b'], '(', ')', '-'), 'JoinSetOfStrings should work with set contains non-empty items');

ASSERT('' = StringUtils.JoinTwoSetsOfStrings(emptySet, ['1', '2', '3'], '[', '(', ']', ')', '.', '-'), 'JoinTwoSetsOfStrings should work when left set is emtpy');
ASSERT('' = StringUtils.JoinTwoSetsOfStrings(['a', 'b', 'c'], emptySet, '[', '(', ']', ')', '.', '-'), 'JoinTwoSetsOfStrings should work when right set is emtpy');
ASSERT('[a].(1)-[b].(2)' = StringUtils.JoinTwoSetsOfStrings(['a', 'b'], ['1', '2', '3'], '[', '(', ']', ')', '.', '-'), 'JoinTwoSetsOfStrings should work when left set has less items');
ASSERT('[a].(1)-[b].(2)' = StringUtils.JoinTwoSetsOfStrings(['a', 'b', 'c'], ['1', '2'], '[', '(', ']', ')', '.', '-'), 'JoinTwoSetsOfStrings should work when left set has more items');
