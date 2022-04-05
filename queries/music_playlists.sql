SELECT mi.title, mi.rating album, mis.rating track
FROM metadata_item_settings mis
        JOIN metadata_items mi on mis.guid = mi.guid
WHERE mi.parent_id = (SELECT id FROM metadata_items WHERE title LIKE '%partial_album_title%');
