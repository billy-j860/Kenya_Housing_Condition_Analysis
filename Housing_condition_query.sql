use Kenya_housing_DB
GO
SELECT*FROM housing_conditions
SELECT
COUNT(*) FROM housing_conditions
--cleaning data
ALTER TABLE housing_conditions DROP COLUMN hh_circ_problems
--standardizing categorical data
--1. wall material
UPDATE housing_conditions
SET hh_inf_wall_material = CASE
WHEN hh_inf_wall_material LIKE '%Stone%' THEN 'Stone'
WHEN hh_inf_wall_material LIKE '%Brick%' THEN 'Brick/Block'
WHEN hh_inf_wall_material LIKE '%Corrugated%' THEN 'Iron sheet'
WHEN hh_inf_wall_material LIKE '%Mud%' THEN 'Mud_based'
WHEN hh_inf_wall_material IS NULL  THEN 'Uknown'
ELSE hh_inf_wall_material
END;
--2. housing_type
UPDATE housing_conditions
SET hh_inf_housing_type = CASE
WHEN hh_inf_housing_type LIKE '%temporary%' THEN 'Temporary Structure'
WHEN hh_inf_housing_type LIKE '%Flat%' THEN 'Flat'
WHEN hh_inf_housing_type LIKE '%House%' THEN 'House'
WHEN hh_inf_housing_type IS NULL THEN 'UNKNOWN'
ELSE hh_inf_housing_type
END;
--3. roof_material
UPDATE housing_conditions
SET hh_inf_roof_material = CASE
WHEN hh_inf_roof_material LIKE '%iron%' THEN 'Corrugated Iron'
WHEN hh_inf_roof_material LIKE '%Concrete%' THEN 'Concrete'
WHEN hh_inf_roof_material LIKE '%Tiles%' THEN 'Tiles'
WHEN hh_inf_roof_material LIKE '%Grass%' THEN 'Thatch'
WHEN hh_inf_roof_material IS NULL THEN 'Unknown'
ELSE hh_inf_roof_material
END;
--4. floor_material
UPDATE housing_conditions
SET hh_inf_floor_material = CASE
WHEN hh_inf_floor_material LIKE '%Concrete%' then 'Cement'
WHEN hh_inf_floor_material LIKE '%Wood%' then 'Wood'
WHEN hh_inf_floor_material LIKE '%Earth%' then 'Dung Finish'
WHEN hh_inf_floor_material LIKE '%Concrete%' then 'Cement'
WHEN hh_inf_floor_material IS NULL THEN 'Unknown'
ELSE hh_inf_floor_material
END;
--5. Fuel source
UPDATE housing_conditions 
SET hh_inf_cookfuel_source = CASE
WHEN hh_inf_cookfuel_source LIKE '%firewood%' THEN 'firewood'
WHEN hh_inf_cookfuel_source LIKE '%Charcoal%' THEN 'Charcoal'
WHEN hh_inf_cookfuel_source LIKE '%paraffin%' THEN 'paraffin'
WHEN hh_inf_cookfuel_source LIKE '%Biogas%' THEN 'Biogas'
WHEN hh_inf_cookfuel_source LIKE '%Gas%' THEN 'LPG'
WHEN hh_inf_cookfuel_source LIKE '%Eats%' THEN 'Unknown'
WHEN hh_inf_cookfuel_source IS NULL THEN 'Unknown'
ELSE hh_inf_cookfuel_source
END;
--6. Water Source
UPDATE housing_conditions
SET hh_inf_water_source = CASE
WHEN hh_inf_water_source LIKE '%vendor%' THEN 'Vendor_supplied'
WHEN hh_inf_water_source LIKE '%piped%' THEN 'External_piped'
WHEN hh_inf_water_source LIKE '%well%' THEN 'well'
WHEN hh_inf_water_source LIKE '%spring%' THEN 'spring'
WHEN hh_inf_water_source LIKE '%rain%' THEN 'rain_harvested'
WHEN hh_inf_water_source LIKE '%dam%' THEN 'dam'
WHEN hh_inf_water_source LIKE '%borehole%' THEN 'borehole'
WHEN hh_inf_water_source IS NULL THEN 'Unknown'
ELSE hh_inf_water_source
END;
--7. Sanitation
UPDATE housing_conditions
SET hh_inf_toilet_type = CASE
WHEN hh_inf_toilet_type LIKE '%sewer%' THEN 'sewer'
WHEN hh_inf_toilet_type LIKE '%pit%' THEN 'latrine'
WHEN hh_inf_toilet_type LIKE '%cess%' THEN 'pool'
WHEN hh_inf_toilet_type LIKE '%bush%' THEN 'bush'
WHEN hh_inf_toilet_type LIKE '%tank%' THEN 'septic'
WHEN hh_inf_toilet_type IS NULL THEN 'Uknown'
ELSE hh_inf_toilet_type
END;
--8. electricity access

--Derive variables
ALTER TABLE housing_conditions
ADD quality_score INT;

UPDATE housing_conditions
SET quality_score = 
    CASE
        WHEN hh_inf_interiorcond = 'No major problems' THEN 3 
        WHEN hh_inf_interiorcond LIKE '%Some peeling%' THEN 2
        WHEN hh_inf_interiorcond = 'Dilapidated' THEN 1
        ELSE 0
    END +
    CASE 
        WHEN hh_inf_exteriorcond = 'No major problems' THEN 3 
        WHEN hh_inf_exteriorcond LIKE '%Some peeling%' THEN 2
        WHEN hh_inf_exteriorcond = 'Dilapidated' THEN 1
        ELSE 0
    END;
--Utility Access Score
ALTER TABLE housing_conditions
ADD utility_score INT;

UPDATE housing_conditions
SET utility_score = 
CASE 
	WHEN hh_inf_electricity_access LIKE '%Yes%' THEN 1 ELSE 0 END +
CASE 
	WHEN hh_inf_water_source LIKE '%Piped into%' THEN 2 
	WHEN hh_inf_water_source LIKE '%Protected%' THEN 1 
	ELSE 0 
	END +
CASE 
	WHEN hh_inf_toilet_type LIKE '%sewer%' THEN 2
	WHEN hh_inf_toilet_type LIKE '%covered%' THEN 1 
	ELSE 0 
END;

--Handling inconsistent 
--1. YES/NO Values
UPDATE housing_conditions
SET hh_inf_electricity_access = CASE 
    WHEN hh_inf_electricity_access LIKE '%Yes%' THEN 'Yes'
    WHEN hh_inf_electricity_access LIKE '%No%' THEN 'No'
    ELSE 'Unknown'
END;
--2. Environmental descriptions
UPDATE housing_conditions
SET hh_env_desc = CASE 
    WHEN hh_env_desc LIKE '%mud%' THEN 'Muddy terrain'
    WHEN hh_env_desc LIKE '%bush%' THEN 'Bushy area'
    WHEN hh_env_desc IS NULL THEN 'Not specified'
    ELSE hh_env_desc
END;
--Binary Flags for basic amenities
ALTER TABLE housing_conditions
ADD has_electricity BIT,
    has_proper_toilet BIT,
    has_piped_water BIT,
    has_modern_cooking BIT,
    has_internet BIT;
--electricity Flag
UPDATE housing_conditions
SET has_electricity = CASE
	WHEN hh_inf_electricity_access LIKE '%Yes%' OR hh_inf_lighting_source = 'Electricity' THEN 1 
    ELSE 0 
END;
--Toilet Flag
UPDATE housing_conditions
SET has_proper_toilet = CASE 
    WHEN hh_inf_toilet_type IN ('Main sewer', 'Septic tank', 'Pit latrine, VIP', 'Pit latrine, covered') THEN 1
    ELSE 0 
END;
---- Set Piped Water Flag
UPDATE housing_conditions
SET has_piped_water = CASE 
    WHEN hh_inf_water_source LIKE '%Piped%' THEN 1 
    ELSE 0 
END;
--Modern cooking flag
UPDATE housing_conditions
SET has_modern_cooking = CASE 
    WHEN hh_inf_cookfuel_source IN ('Gas/LPG', 'Electricity', 'Biogas') THEN 1 
    ELSE 0 
END;

ALTER TABLE housing_conditions
DROP COLUMN IF EXISTS has_modern_cooking; 

--Internet Access
UPDATE housing_conditions
SET has_internet = CASE 
    WHEN hh_asset_internet_access NOT IN ('Does not access internet', 'NULL', '') 
    AND hh_asset_internet_access IS NOT NULL THEN 1 
    ELSE 0 
END;

ALTER TABLE  housing_conditions
ADD with_modern_cooking BIT;
UPDATE housing_conditions
SET with_modern_cooking = CASE 
    WHEN hh_inf_cookfuel_source IN ('LPG', 'Electricity', 'Biogas') THEN 1 
    ELSE 0 
END;

--Quality Flags
ALTER TABLE housing_conditions
ADD good_wall_material BIT,
	good_roof_material BIT,
	good_floor_material BIT;

--Wall material quality flag
UPDATE housing_conditions
SET good_wall_material = CASE
WHEN hh_inf_wall_material in ('Stone','Brick/Block') THEN 1
ELSE 0
END;
--roof material quality flag
UPDATE housing_conditions
SET good_roof_material = CASE
WHEN hh_inf_roof_material in ('Concrete','Tiles' ,'Corrugated Iron') THEN 1
ELSE 0
END;

--floor material quality flag
UPDATE housing_conditions
SET good_floor_material = CASE
WHEN hh_inf_floor_material in ('Cement','Wood') THEN 1
ELSE 0
END;

--location categories
ALTER TABLE housing_conditions 
ADD location_type VARCHAR (50);

UPDATE housing_conditions
SET location_type = CASE
	WHEN hh_env_settingdesc LIKE '%Urban%' THEN 'Urban'
	WHEN hh_env_settingdesc LIKE '%Rural%' THEN 'Rural'
	ELSE 'Unspecified'
END
--Sorrounding conditions
ALTER TABLE housing_conditions
ADD environmental_score INT;

UPDATE housing_conditions
SET environmental_score = CASE 
	WHEN hh_env_streets LIKE '%Open sewage%' THEN 0
	WHEN hh_env_streets LIKE '%Crowded%' THEN 1
	WHEN hh_env_streets LIKE '%None%' THEN 3
	ELSE 2
END +
CASE 
	WHEN hh_env_trash LIKE '%Major%' THEN 0
	WHEN hh_env_trash LIKE '%Minor%' THEN 1
	WHEN hh_env_trash = '98=None' THEN 2
    ELSE 3
END;


--ANALYSIS
--1. Binary Flags

--CONVERTING derived column data types from BIT to INT to allow SUM function to work with columns
ALTER TABLE housing_conditions ALTER COLUMN has_electricity INT

ALTER TABLE housing_conditions ALTER COLUMN has_proper_toilet INT
ALTER TABLE housing_conditions ALTER COLUMN has_piped_water INT
ALTER TABLE housing_conditions ALTER COLUMN has_internet INT
ALTER TABLE housing_conditions ALTER COLUMN good_roof_material INT
ALTER TABLE housing_conditions ALTER COLUMN good_floor_material INT;


SELECT
	SUM(has_electricity) AS total_with_electricity,
	SUM(has_proper_toilet) AS total_with_proper_toilet,
	SUM(has_piped_water) AS total_with_piped_water,
    SUM(with_modern_cooking) AS total_with_modern_cooking,
    SUM(has_internet) AS total_with_internet,
    SUM(good_wall_material) AS total_with_good_walls,
    SUM(good_roof_material) AS total_with_good_roof,
    SUM(good_floor_material) AS total_with_good_floor,
	COUNT(*) AS total_households,
	CAST(SUM(has_electricity) AS FLOAT) / COUNT(*) * 100 AS electricity_percentage,
    CAST(SUM(has_proper_toilet) AS FLOAT) / COUNT(*) * 100 AS proper_toilet_percentage,
    CAST(SUM(has_piped_water) AS FLOAT) / COUNT(*) * 100 AS piped_water_percentage
FROM housing_conditions;

--Data Validation
SELECT*FROM housing_conditions
WHERE
	(hh_inf_electricity_access = 'Yes' AND hh_inf_lighting_source = 'Candles')
    OR (hh_inf_water_source = 'Piped into dwelling' AND hh_env_settingdesc = 'Rural')
    OR (hh_inf_toilet_type = 'Main sewer' AND hh_env_settingdesc = 'Rural');

SELECT * FROM housing_conditions;

--drop remaining columns not related to housing conditions
ALTER TABLE housing_conditions
DROP COLUMN hh_ownership_plotacquisition, hh_ownership_houseacquisition, hh_ownership_docu, hh_otherprop_N;

--Housing quality categories
ALTER TABLE housing_conditions
ADD quality_category VARCHAR(50);

ALTER TABLE housing_conditions
DROP COLUMN quality_Category;






















