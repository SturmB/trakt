SELECT substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', miv.viewed_at), -3) || ' ' || strftime('%d, %Y, %H:%M', miv.viewed_at) AS vdatetime, substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', mi.added_at), -3) || ' ' || strftime('%d, %Y, %H:%M', mi.added_at) AS adatetime, miv.title, mi.year, miv.parent_title, miv.grandparent_title
FROM metadata_item_views miv
JOIN metadata_items mi ON mi.guid = miv.guid
WHERE miv.id > 805 AND miv.account_id = 1 AND miv.library_section_id = 1
-- AND miv.title LIKE '%48%';
