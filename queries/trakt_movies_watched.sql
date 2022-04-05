SELECT SUBSTR(miv.guid, INSTR(miv.guid, 'imdb') + 7, 9) AS id, miv.viewed_at AS watched_at
FROM metadata_item_views miv
    JOIN metadata_items mi ON mi.guid = miv.guid
WHERE miv.id > 805
    AND miv.account_id = 1
    AND miv.library_section_id = 1
    AND miv.metadata_type = 1;
--     AND miv.title LIKE '%movie_title%';
