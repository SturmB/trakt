SELECT substr('JanFebMarAprMayJunJulAugSepOctNovDec', 1 + 3*strftime('%m', mdi.added_at, 'localtime'), -3) || ' ' || strftime('%d, %Y, %H:%M', mdi.added_at, 'localtime') AS adatetime, mdi.title, mdi.year, mi.width || 'x' || mi.height AS res, mi.audio_channels AS ch, mi.audio_codec AS audio, mi.color_trc
FROM metadata_items mdi
JOIN media_items mi on mdi.id = mi.metadata_item_id
WHERE mdi.library_section_id = 1;
--     AND mdi.title LIKE '%movie_title%';
