SELECT
    ms.media_item_id AS id,
    mdi.title,
    SUBSTR(mdi.guid, INSTR(mdi.guid, 'imdb') + 7, 9) AS imdb,
    STRFTIME('%Y-%m-%dT%H:%M:%SZ', mdi.added_at) AS 'collected_at',
    'digital' AS 'media_type',
    SUBSTR(ms.extra_data, INSTR(ms.extra_data, 'width=') + 6, 3) AS rawwidth,
    CASE SUBSTR(ms.extra_data, INSTR(ms.extra_data, 'width=') + 6, 3)
        WHEN '384' THEN 'uhd_4k'
        WHEN '192' THEN 'hd_1080p'
        WHEN '142' THEN 'hd_1080p'
        WHEN '128' THEN 'hd_720p'
        WHEN '640' THEN 'sd_480p'
        WHEN '576' THEN 'sd_480p'
        ELSE ''
    END AS 'resolution',
    CASE SUBSTR(ms.extra_data, INSTR(ms.extra_data, 'bitDepth=') + 9, 1)
        WHEN '1' THEN 'hdr10'
        ELSE ''
    END AS 'hdr',
    CASE ms2.codec
        WHEN 'ac3' THEN 'dolby_digital'
        WHEN 'eac3' THEN 'dolby_digital_plus'
        WHEN 'truehd' THEN
            CASE SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'title=') + 6, 25)
                WHEN 'TrueHD%20Atmos%207%2E1' THEN 'dolby_atmos'
                ELSE 'dolby_truehd'
            END
        WHEN 'dca' THEN
            CASE SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'title=') + 6, 25)
                WHEN 'DTS%206%2E1' THEN 'dts'
                WHEN 'DTS-HD%20MA%205%2E1' THEN 'dts_ma'
                ELSE
                    CASE
                        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'profile=') + 8, 25)
                            LIKE 'dts%' THEN 'dts'
                        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'profile=') + 8, 25)
                            LIKE 'ma%' THEN 'dts_ma'
                    END
            END
        WHEN 'mp3' THEN 'mp3'
        WHEN 'aac' THEN 'aac'
        WHEN 'flac' THEN 'flac'
        ELSE ''
    END AS 'audio',
    CASE
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%7\%2E1%' ESCAPE '\' THEN '7.1'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%6\%2E1%' ESCAPE '\' THEN '6.1'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 15) LIKE '%5\%2E1(side)%' ESCAPE '\' THEN '4.1'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%5\%2E1%' ESCAPE '\' THEN '5.1'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 15) LIKE '%5\%2E0%' ESCAPE '\' THEN '5.0'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%4\%2E0%' ESCAPE '\' THEN '4.0'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%stereo%' THEN '2.0'
        WHEN SUBSTR(ms2.extra_data, INSTR(ms2.extra_data, 'audioChannelLayout=') + 19, 6) LIKE '%mono%' THEN '1.0'
        ELSE '2.0'
    END AS 'audio_channels',
    'false' AS '3d'
FROM metadata_items mdi
JOIN media_items mi on mdi.id = mi.metadata_item_id
-- JOIN media_parts mp on mi.id = mp.media_item_id
JOIN media_streams ms on mi.id = ms.media_item_id
JOIN media_streams ms2 on mi.id = ms2.media_item_id
WHERE mdi.library_section_id = 1
  AND mdi.metadata_type = 1
  AND ms.stream_type_id = 1
  AND ms2.stream_type_id = 2
--   AND mdi.title LIKE '%nature%'
--     AND mdi.guid LIKE '%tt0111282%';

--Arrival - audio - 7.1
--ma%3AaudioChannelLayout=7%2E1&ma%3AbitDepth=16&ma%3Aprofile=ma&ma%3ArequiredBandwidths=2671%2C2671%2C2671%2C2671%2C2671%2C2671%2C2671%2C2671&ma%3AsamplingRate=48000&ma%3Atitle=DTS-HD%20Master%20Audio%20%2F%207%2E1%20%2F%2048%20kHz%20%2F%202525%20kbps%20%2F%2016-bit

--When Nature Calls - audio - 5.0
--ma%3AaudioChannelLayout=5%2E0%28side%29&ma%3AbitDepth=24&ma%3Aprofile=dts&ma%3ArequiredBandwidths=1508%2C1508%2C1508%2C1508%2C1508%2C1508%2C1508%2C1508&ma%3AsamplingRate=48000&ma%3Atitle=Ace%2EVentura%2EWhen%2ENature%2ECalls%2E1995%2E1080p%2EDTS%2Ex264-CHD

--Last Starfighter - audio - 4.1
--ma%3AaudioChannelLayout=5%2E1(side)&ma%3AbitDepth=24&ma%3Aprofile=dts&ma%3ArequiredBandwidths=1509%2C1509%2C1509%2C1509%2C1509%2C1509%2C1509%2C1509&ma%3AsamplingRate=48000&ma%3Atitle=DTS%20Core%205%2E1%20@%201%2E5%20Mbps

--Enemy Mine - audio - 4.0
--ma%3AaudioChannelLayout=4%2E0&ma%3ArequiredBandwidths=640%2C640%2C640%2C640%2C640%2C640%2C640%2C640&ma%3AsamplingRate=48000&ma%3Atitle=English%20DD4%2E0%20@%20640%20Kbps

--Droid Gunner - audio - MP3
--ma%3AaudioChannelLayout=stereo&ma%3ArequiredBandwidths=124%2C124%2C124%2C124%2C124%2C124%2C124%2C124&ma%3AsamplingRate=48000&ma%3AstreamIdentifier=1

--Droid Gunner - SD
--ma%3AbitDepth=8&ma%3AchromaLocation=left&ma%3AchromaSubsampling=4%3A2%3A0&ma%3AframeRate=25%2E000&ma%3Aheight=432&ma%3Alevel=5&ma%3Aprofile=advanced%20simple&ma%3ArefFrames=1&ma%3ArequiredBandwidths=1926%2C1926%2C1926%2C1926%2C1926%2C1926%2C1926%2C1926&ma%3Awidth=576

--Bride of Re-Animator - audio - AAC
--ma%3Aprofile=lc&ma%3ArequiredBandwidths=223%2C223%2C223%2C223%2C223%2C223%2C223%2C223&ma%3AsamplingRate=48000

--Citizen Kane - audio - Flac
--ma%3AaudioChannelLayout=mono&ma%3AbitDepth=16&ma%3ArequiredBandwidths=209%2C209%2C209%2C209%2C209%2C209%2C209%2C209&ma%3AsamplingRate=48000&ma%3Atitle=FLAC%201%2E0

--1979 - audio - codec = truehd
--ma%3AaudioChannelLayout=7%2E1&ma%3AbitDepth=24&ma%3ArequiredBandwidths=5476%2C5117%2C4283%2C4027%2C3868%2C3839%2C3839%2C3839&ma%3AsamplingRate=48000

--Revenge of the Sith - audio
--ma%3AaudioChannelLayout=6%2E1&ma%3AbitDepth=24&ma%3Aprofile=es&ma%3ArequiredBandwidths=1509%2C1509%2C1509%2C1509%2C1509%2C1509%2C1509%2C1509&ma%3AsamplingRate=48000&ma%3Atitle=DTS%206%2E1

--Social Dilemma - audio
--ma%3AaudioChannelLayout=5%2E1%28side%29&ma%3ArequiredBandwidths=640%2C640%2C640%2C640%2C640%2C640%2C640%2C640&ma%3AsamplingRate=48000

--Rudolph - audio
--ma%3AaudioChannelLayout=stereo&ma%3ArequiredBandwidths=256%2C256%2C256%2C256%2C256%2C256%2C256%2C256&ma%3AsamplingRate=48000

--Rudolph - 1080p
--ma%3AbitDepth=8&ma%3AchromaLocation=left&ma%3AchromaSubsampling=4%3A2%3A0&ma%3AcodedHeight=1072&ma%3AcodedWidth=1424&ma%3AframeRate=23%2E976&ma%3AhasScalingMatrix=0&ma%3Aheight=1060&ma%3Alevel=41&ma%3Aprofile=high&ma%3ArefFrames=4&ma%3ArequiredBandwidths=24658%2C21322%2C19582%2C17859%2C17859%2C17859%2C17859%2C17859&ma%3AscanType=progressive&ma%3Atitle=Rudolph%2EThe%2ERed%2ENosed%2EReindeer%2E1964%2E1080p%2EBluRay%2EDD%2E2%2E0%2Ex264-HDMaNiAcS&ma%3Awidth=1424

--Runaway - audio
--ma%3AaudioChannelLayout=stereo&ma%3AbitDepth=16&ma%3Aprofile=dts&ma%3ArequiredBandwidths=768%2C768%2C768%2C768%2C768%2C768%2C768%2C768&ma%3AsamplingRate=48000

--Runaway - 1080p
--ma%3AbitDepth=8&ma%3AchromaLocation=left&ma%3AchromaSubsampling=4%3A2%3A0&ma%3AcodedHeight=816&ma%3AcodedWidth=1920&ma%3AframeRate=23%2E976&ma%3AhasScalingMatrix=0&ma%3Aheight=816&ma%3Alevel=41&ma%3Aprofile=high&ma%3ArefFrames=5&ma%3ArequiredBandwidths=16406%2C14693%2C13242%2C11502%2C10043%2C10043%2C10043%2C10043&ma%3AscanType=progressive&ma%3Awidth=1920

--SD audio
--ma%3AaudioChannelLayout=stereo&ma%3ArequiredBandwidths=224%2C224%2C224%2C224%2C224%2C224%2C224%2C224&ma%3AsamplingRate=48000

--SD
--ma%3AbitDepth=8&ma%3AchromaLocation=left&ma%3AchromaSubsampling=4%3A2%3A0&ma%3AcolorPrimaries=bt709&ma%3AcolorRange=tv&ma%3AcolorSpace=bt709&ma%3AcolorTrc=bt709&ma%3AframeRate=29%2E970&ma%3AhasScalingMatrix=0&ma%3Aheight=480&ma%3Alevel=30&ma%3Aprofile=main&ma%3ArefFrames=5&ma%3ArequiredBandwidths=1290%2C1290%2C1290%2C1290%2C1290%2C1290%2C1290%2C1290&ma%3AscanType=progressive&ma%3Awidth=640

--Hereditary - 4K audio
--ma%3AaudioChannelLayout=5%2E1%28side%29&ma%3AbitDepth=24&ma%3Aprofile=ma&ma%3ArequiredBandwidths=4814%2C4519%2C3791%2C3663%2C3569%2C3534%2C3534%2C3534&ma%3AsamplingRate=48000&ma%3Atitle=DTS-HD%20MA%205%2E1

--Hereditary - 4K HDR
--ma%3AbitDepth=10&ma%3AchromaSubsampling=4%3A2%3A0&ma%3AcodedHeight=1920&ma%3AcodedWidth=3840&ma%3AcolorPrimaries=bt2020&ma%3AcolorRange=tv&ma%3AcolorSpace=bt2020nc&ma%3AcolorTrc=smpte2084&ma%3AframeRate=23%2E976&ma%3Aheight=1920&ma%3Alevel=153&ma%3Aprofile=main%2010&ma%3ArefFrames=1&ma%3ArequiredBandwidths=35153%2C34170%2C31288%2C27774%2C25351%2C23801%2C20757%2C19151&ma%3Awidth=3840

--Incredibles - 4K audio
--ma%3AaudioChannelLayout=7%2E1&ma%3AbitDepth=24&ma%3ArequiredBandwidths=9186%2C8947%2C8546%2C8043%2C7883%2C7785%2C7359%2C7359&ma%3AsamplingRate=48000&ma%3Atitle=TrueHD%20Atmos%207%2E1
