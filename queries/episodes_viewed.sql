SELECT substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', miv.viewed_at, 'localtime'), -3) || ' ' || strftime('%d, %Y, %H:%M', miv.viewed_at, 'localtime') AS vdatetime,
        substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', mi.added_at, 'localtime'), -3) || ' ' || strftime('%d, %Y, %H:%M', mi.added_at, 'localtime') AS adatetime,
        mi.title,
        miv.grandparent_title,
        mi.year
--         miv.parent_title,
FROM metadata_items mi
LEFT OUTER JOIN metadata_item_views miv
    ON miv.guid = mi.guid
    AND miv.id > 805
    AND miv.account_id = 1
WHERE mi.library_section_id = 2
--   AND miv.grandparent_title LIKE '%partial_show_title%';
