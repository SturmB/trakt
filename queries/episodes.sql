SELECT substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', mi.added_at, 'localtime'), -3) || ' ' || strftime('%d, %Y, %H:%M', mi.added_at, 'localtime') AS adatetime, mi.title show_title, mip.title season_title, mig.title series_title, mi.year, m.width || 'x' || m.height AS res
FROM metadata_items mi
JOIN metadata_items mip ON mip.id = mi.parent_id
JOIN metadata_items mig ON mig.id = mip.parent_id
JOIN media_items m on mi.id = m.metadata_item_id
WHERE mi.library_section_id = 2
-- AND mi.title LIKE '%partial_episode_title%';
