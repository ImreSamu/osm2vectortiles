CREATE OR REPLACE VIEW road_label_z8toz10 AS
    SELECT *
    FROM osm_road_geometry
    WHERE type IN ('motorway')
      AND ref <> '';

CREATE OR REPLACE VIEW road_label_z11 AS
    SELECT *
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link')
      AND (name <> '' OR ref <> '');

CREATE OR REPLACE VIEW road_label_z12toz13 AS
    SELECT *
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link',
        'tertiary', 'tertiary_link', 'residential', 'unclassified', 'living_street', 'pedestrian', 'construction', 'rail', 'monorail', 'narrow_gauge', 'subway', 'tram')
      AND name <> '';

CREATE OR REPLACE VIEW road_label_z14 AS
    SELECT *
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link',
        'tertiary', 'tertiary_link', 'residential', 'unclassified', 'living_street', 'pedestrian', 'construction', 'rail', 'monorail',
        'narrow_gauge', 'subway', 'tram', 'service', 'track', 'driveway', 'path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway', 'funicular', 'light_rail', 'preserved')
      AND name <> '';

CREATE OR REPLACE VIEW layer_road_label AS (
    SELECT osm_id, timestamp, geometry FROM road_label_z8toz10
    UNION
    SELECT osm_id, timestamp, geometry FROM road_label_z11
    UNION
    SELECT osm_id, timestamp, geometry FROM road_label_z12toz13
    UNION
    SELECT osm_id, timestamp, geometry FROM road_label_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_road_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_road_label AS c
            INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM road_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
		UNION

		SELECT c.x, c.y, c.z FROM road_label_z12toz13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 12 AND 13
		UNION

		SELECT c.x, c.y, c.z FROM road_label_z11 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 11
		UNION

		SELECT c.x, c.y, c.z FROM road_label_z8toz10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 8 AND 10
	);
END;
$$ LANGUAGE plpgsql;

