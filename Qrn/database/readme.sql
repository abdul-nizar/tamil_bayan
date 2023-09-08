/**
 Correct the Data in the DB
 */

-- select * from Articles;

SELECT * FROM Articles where name like '%&#%';
-- SELECT * FROM Articles where name like '%&#8230;%';
-- 
-- UPDATE Articles SET name = REPLACE(name, '&#8211;', '-');
-- UPDATE Articles SET name = REPLACE(name, '&#8230;', '…');
-- UPDATE Articles SET name = REPLACE(name, '&#8220;', '“');
-- UPDATE Articles SET name = REPLACE(name, '&#8221;', '”');

-- UPDATE Articles SET name = REPLACE(name, '&#8216;', '‘');
-- UPDATE Articles SET name = REPLACE(name, '&#8217;', '’');

-- UPDATE Articles SET name = REPLACE(name, '&#038;', '&');

-- Update block color text
-- UPDATE Articles SET description = REPLACE(description, 'color: #000000;', '');

-- commit;
