format MS COFF
public EXPORTS
section '.flat' code readable align 16

include '../../../../macros.inc'
include '../../../../proc32.inc'



;---------
offs_m_or_i    equ 8 ;ᬥ饭�� ��ࠬ��� 'MM' ��� 'II' (Motorola, Intel)
offs_tag_0     equ 2 ;ᬥ饭�� 0-�� ⥣�
tag_size       equ 12 ;ࠧ��� �������� ⥣�
;�ଠ�� ������
tag_format_ui1b  equ  1 ;unsigned integer 1 byte
tag_format_text  equ  2 ;ascii string
tag_format_ui2b  equ  3 ;unsigned integer 2 byte
tag_format_ui4b  equ  4 ;unsigned integer 4 byte
tag_format_urb   equ  5 ;unsigned integer 4/4 byte
tag_format_si1b  equ  6 ;signed integer 1 byte
tag_format_undef equ  7 ;undefined
tag_format_si2b  equ  8 ;signed integer 2 byte
tag_format_si4b  equ  9 ;signed integer 4 byte
tag_format_srb   equ 10 ;signed integer 4/4 byte
tag_format_f4b	 equ 11 ;float 4 byte
tag_format_f8b	 equ 12 ;float 8 byte

align 4
txt_dp db ': ',0
txt_div db '/',0

;
align 4
exif_tag_numbers:

db 0x00,0x01,'Interop index',0
db 0x00,0x02,'Interop version',0
db 0x00,0x0b,'Processing software',0
db 0x00,0xfe,'Subfile type',0
db 0x00,0xff,'OldSubfile type',0
db 0x01,0x00,'Image width',0
db 0x01,0x01,'Image height',0
db 0x01,0x02,'Bits per sample',0
db 0x01,0x03,'Compression',0
db 0x01,0x06,'Photometric interpretation',0
db 0x01,0x07,'Thresholding',0
db 0x01,0x08,'Cell width',0
db 0x01,0x09,'Cell length',0
db 0x01,0x0a,'Fill order',0
db 0x01,0x0d,'Document name',0
db 0x01,0x0e,'Image description',0
db 0x01,0x0f,'Manufacturer of digicam',0
db 0x01,0x10,'Model',0
db 0x01,0x11,'Strip offsets',0
db 0x01,0x12,'Orientation',0
db 0x01,0x15,'Samples per pixel',0
db 0x01,0x16,'Rows per strip',0
db 0x01,0x17,'Strip byte counts',0
db 0x01,0x18,'Min sample value',0
db 0x01,0x19,'Max sample value',0
db 0x01,0x1a,'X resolution',0
db 0x01,0x1b,'Y resolution',0
db 0x01,0x1c,'Planar configuration',0
db 0x01,0x1d,'Page name',0
db 0x01,0x1e,'X position',0
db 0x01,0x1f,'Y position',0
db 0x01,0x20,'Free offsets',0
db 0x01,0x21,'Free byte counts',0
db 0x01,0x22,'Gray response unit',0
db 0x01,0x23,'Gray response curve',0
db 0x01,0x24,'T4 options',0
db 0x01,0x25,'T6 options',0
db 0x01,0x28,'Resolution unit',0
db 0x01,0x29,'Page number',0
db 0x01,0x2c,'Color response unit',0
db 0x01,0x2d,'Transfer function',0
db 0x01,0x31,'Software',0
db 0x01,0x32,'Modify date',0
db 0x01,0x3b,'Artist',0
db 0x01,0x3c,'Host computer',0
db 0x01,0x3d,'Predictor',0
db 0x01,0x3e,'White point',0
db 0x01,0x3f,'Primary chromaticities',0
db 0x01,0x40,'Color map',0
db 0x01,0x41,'Halftone hints',0
db 0x01,0x42,'Tile width',0
db 0x01,0x43,'Tile length',0
db 0x01,0x44,'Tile offsets',0
db 0x01,0x45,'Tile byte counts',0
db 0x01,0x46,'Bad fax lines',0
db 0x01,0x47,'Clean fax data',0
db 0x01,0x48,'Consecutive bad fax lines',0
db 0x01,0x4a,'Sub IFDs',0
db 0x01,0x4c,'Ink set',0
db 0x01,0x4d,'Ink names',0
db 0x01,0x4e,'Numberof inks',0
db 0x01,0x50,'Dot range',0
db 0x01,0x51,'Target printer',0
db 0x01,0x52,'Extra samples',0
db 0x01,0x53,'Sample format',0
db 0x01,0x54,'SMin sample value',0
db 0x01,0x55,'SMax sample value',0
db 0x01,0x56,'Transfer range',0
db 0x01,0x57,'Clip path',0
db 0x01,0x58,'X clip path units',0
db 0x01,0x59,'Y clip path units',0
db 0x01,0x5a,'Indexed',0
db 0x01,0x5b,'JPEG tables',0
db 0x01,0x5f,'OPIProxy',0
db 0x01,0x90,'Global parameters IFD',0
db 0x01,0x91,'Profile type',0
db 0x01,0x92,'Fax profile',0
db 0x01,0x93,'Coding methods',0
db 0x01,0x94,'Version year',0
db 0x01,0x95,'Mode number',0
db 0x01,0xb1,'Decode',0
db 0x01,0xb2,'Default image color',0
db 0x01,0xb3,'T82 options',0
db 0x01,0xb5,'JPEG tables',0 ;㦥 �뫮 ?
db 0x02,0x00,'JPEG proc',0
db 0x02,0x01,'Thumbnail offset',0
db 0x02,0x02,'Thumbnail length',0
db 0x02,0x03,'JPEG restart interval',0
db 0x02,0x05,'JPEG lossless predictors',0
db 0x02,0x06,'JPEG point transforms',0
db 0x02,0x07,'JPEG QTables',0
db 0x02,0x08,'JPEG DCTables',0
db 0x02,0x09,'JPEG ACTables',0
db 0x02,0x11,'YCbCrCoefficients',0
db 0x02,0x12,'YCbCrSubSampling',0
db 0x02,0x13,'YCbCrPositioning',0
db 0x02,0x14,'Reference black white',0
db 0x02,0x2f,'Strip row counts',0
db 0x02,0xbc,'Application notes',0
db 0x03,0xe7,'USPTO Miscellaneous',0
db 0x10,0x00,'Related image file format',0
db 0x10,0x01,'Related image width',0
db 0x10,0x02,'Related image height',0
db 0x47,0x46,'Rating',0
db 0x47,0x47,'XP_DIP_XML',0
db 0x47,0x48,'Stitch info',0
db 0x47,0x49,'Rating percent',0
db 0x80,0x0d,'Image ID',0
db 0x80,0xa3,'Wang tag 1',0
db 0x80,0xa4,'Wang annotation',0
db 0x80,0xa5,'Wang tag 3',0
db 0x80,0xa6,'Wang tag 4',0
db 0x80,0xe3,'Matteing',0
db 0x80,0xe4,'Data type',0
db 0x80,0xe5,'Image depth',0
db 0x80,0xe6,'Tile depth',0
db 0x82,0x7d,'Model 2',0
db 0x82,0x8d,'CFA repeat pattern dim',0
db 0x82,0x8e,'CFA pattern 2',0
db 0x82,0x8f,'Battery level',0
db 0x82,0x90,'Kodak IFD',0
db 0x82,0x98,'Copyright',0
db 0x82,0x9a,'Exposure time',0
db 0x82,0x9d,'F number',0
db 0x82,0xa5,'MD file tag',0
db 0x82,0xa6,'MD scale pixel',0
db 0x82,0xa7,'MD color table',0
db 0x82,0xa8,'MD lab name',0
db 0x82,0xa9,'MD sample info',0
db 0x82,0xaa,'MD prep date',0
db 0x82,0xab,'MD prep time',0
db 0x82,0xac,'MD file units',0
db 0x83,0x0e,'Pixel scale',0
db 0x83,0x35,'Advent scale',0
db 0x83,0x36,'Advent revision',0
db 0x83,0x5c,'UIC1 tag',0
db 0x83,0x5d,'UIC2 tag',0
db 0x83,0x5e,'UIC3 tag',0
db 0x83,0x5f,'UIC4 tag',0
db 0x83,0xbb,'IPTC-NAA',0
db 0x84,0x7e,'Intergraph packet data',0
db 0x84,0x7f,'Intergraph flag registers',0
db 0x84,0x80,'Intergraph matrix',0
db 0x84,0x81,'INGR reserved',0
db 0x84,0x82,'Model tie point',0
db 0x84,0xe0,'Site',0
db 0x84,0xe1,'Color sequence',0
db 0x84,0xe2,'IT8 header',0
db 0x84,0xe3,'Raster padding',0
db 0x84,0xe4,'Bits per run length',0
db 0x84,0xe5,'Bits per extended run length',0
db 0x84,0xe6,'Color table',0
db 0x84,0xe7,'Image color indicator',0
db 0x84,0xe8,'Background color indicator',0
db 0x84,0xe9,'Image color value',0
db 0x84,0xea,'Background color value',0
db 0x84,0xeb,'Pixel intensity range',0
db 0x84,0xec,'Transparency indicator',0
db 0x84,0xed,'Color characterization',0
db 0x84,0xee,'HCUsage',0
db 0x84,0xef,'Trap indicator',0
db 0x84,0xf0,'CMYK equivalent',0
db 0x85,0x46,'SEM info',0
db 0x85,0x68,'AFCP_IPTC',0
db 0x85,0xb8,'Pixel magic JBIG options',0
db 0x85,0xd8,'Model transform',0
db 0x86,0x02,'WB_GRGB levels',0
db 0x86,0x06,'Leaf data',0
db 0x86,0x49,'Photoshop settings',0
db 0x87,0x69,'Exif offset',0
db 0x87,0x73,'ICC_Profile',0
db 0x87,0x7f,'TIFF_FX extensions',0
db 0x87,0x80,'Multi profiles',0
db 0x87,0x81,'Shared data',0
db 0x87,0x82,'T88 options',0
db 0x87,0xac,'Image layer',0
db 0x87,0xaf,'Geo tiff directory',0
db 0x87,0xb0,'Geo tiff double params',0
db 0x87,0xb1,'Geo tiff ascii params',0
db 0x88,0x22,'Exposure program',0
db 0x88,0x24,'Spectral sensitivity',0
db 0x88,0x25,'GPS Info',0
db 0x88,0x27,'ISO',0
db 0x88,0x28,'Opto-Electric conv factor',0
db 0x88,0x29,'Interlace',0
db 0x88,0x2a,'Time zone offset',0
db 0x88,0x2b,'Self timer mode',0
db 0x88,0x30,'Sensitivity type',0
db 0x88,0x31,'Standard output sensitivity',0
db 0x88,0x32,'Recommended exposure index',0
db 0x88,0x33,'ISO speed',0
db 0x88,0x34,'ISO speed latitude yyy',0
db 0x88,0x35,'ISO speed latitude zzz',0
db 0x88,0x5c,'Fax recv params',0
db 0x88,0x5d,'Fax sub address',0
db 0x88,0x5e,'Fax recv time',0
db 0x88,0x8a,'Leaf sub IFD',0
db 0x90,0x00,'Exif version',0
db 0x90,0x03,'Date time original',0
db 0x90,0x04,'Create date',0
db 0x91,0x01,'Components configuration',0
db 0x91,0x02,'Compressed bits per pixel',0
db 0x92,0x01,'Shutter speed value',0
db 0x92,0x02,'Aperture value',0
db 0x92,0x03,'Brightness value',0
db 0x92,0x04,'Exposure compensation',0
db 0x92,0x05,'Max aperture value',0
db 0x92,0x06,'Subject distance',0
db 0x92,0x07,'Metering mode',0
db 0x92,0x08,'Light source',0
db 0x92,0x09,'Flash',0
db 0x92,0x0a,'Focal length',0
db 0x92,0x0b,'Flash energy',0
db 0x92,0x0c,'Spatial frequency response',0
db 0x92,0x0d,'Noise',0
db 0x92,0x0e,'Focal plane X resolution',0
db 0x92,0x0f,'Focal plane Y resolution',0
db 0x92,0x10,'Focal plane resolution unit',0
db 0x92,0x11,'Image number',0
db 0x92,0x12,'Security classification',0
db 0x92,0x13,'Image history',0
db 0x92,0x14,'Subject area',0
db 0x92,0x15,'Exposure index',0
db 0x92,0x16,'TIFF-EP standard ID',0
db 0x92,0x17,'Sensing method',0
db 0x92,0x3a,'CIP3 data file',0
db 0x92,0x3b,'CIP3 sheet',0
db 0x92,0x3c,'CIP3 side',0
db 0x92,0x3f,'Sto nits',0
db 0x92,0x7c,'Maker note',0
db 0x92,0x86,'User comment',0
db 0x92,0x90,'Sub sec time',0
db 0x92,0x91,'Sub sec time original',0
db 0x92,0x92,'Sub sec time digitized',0
db 0x93,0x2f,'MS document text',0
db 0x93,0x30,'MS property set storage',0
db 0x93,0x31,'MS document text position',0
db 0x93,0x5c,'Image source data',0
db 0x9c,0x9b,'XP title',0
db 0x9c,0x9c,'XP comment',0
db 0x9c,0x9d,'XP author',0
db 0x9c,0x9e,'XP keywords',0
db 0x9c,0x9f,'XP subject',0
db 0xa0,0x00,'Flashpix version',0
db 0xa0,0x01,'Color space',0
db 0xa0,0x02,'Exif image width',0
db 0xa0,0x03,'Exif image height',0
db 0xa0,0x04,'Related sound file',0
db 0xa0,0x05,'Interop offset',0
db 0xa2,0x0b,'Flash energy',0
db 0xa2,0x0c,'Spatial frequency fesponse',0
db 0xa2,0x0d,'Noise',0
db 0xa2,0x0e,'Focal plane X resolution',0
db 0xa2,0x0f,'Focal plane Y resolution',0
db 0xa2,0x10,'Focal plane resolution unit',0
db 0xa2,0x11,'Image number',0
db 0xa2,0x12,'Security classification',0
db 0xa2,0x13,'Image history',0
db 0xa2,0x14,'Subject location',0
db 0xa2,0x15,'Exposure index',0
db 0xa2,0x16,'TIFF-EP standard ID',0
db 0xa2,0x17,'Sensing method',0
db 0xa3,0x00,'File source',0
db 0xa3,0x01,'Scene type',0
db 0xa3,0x02,'CFA pattern',0
db 0xa4,0x01,'Custom rendered',0
db 0xa4,0x02,'Exposure mode',0
db 0xa4,0x03,'White balance',0
db 0xa4,0x04,'Digital zoom ratio',0
db 0xa4,0x05,'Focal length in 35mm format',0
db 0xa4,0x06,'Scene capture type',0
db 0xa4,0x07,'Gain control',0
db 0xa4,0x08,'Contrast',0
db 0xa4,0x09,'Saturation',0
db 0xa4,0x0a,'Sharpness',0
db 0xa4,0x0b,'Device setting description',0
db 0xa4,0x0c,'Subject distance range',0
db 0xa4,0x20,'Image unique ID',0
db 0xa4,0x30,'Owner name',0
db 0xa4,0x31,'Serial number',0
db 0xa4,0x32,'Lens info',0
db 0xa4,0x33,'Lens make',0
db 0xa4,0x34,'Lens model',0
db 0xa4,0x35,'Lens serial number',0
db 0xa4,0x80,'GDAL metadata',0
db 0xa4,0x81,'GDAL no data',0
db 0xa5,0x00,'Gamma',0
db 0xaf,0xc0,'Expand software',0
db 0xaf,0xc1,'Expand lens',0
db 0xaf,0xc2,'Expand film',0
db 0xaf,0xc3,'Expand filterLens',0
db 0xaf,0xc4,'Expand scanner',0
db 0xaf,0xc5,'Expand flash lamp',0
db 0xbc,0x01,'Pixel format',0
db 0xbc,0x02,'Transformation',0
db 0xbc,0x03,'Uncompressed',0
db 0xbc,0x04,'Image type',0
db 0xbc,0x80,'Image width',0
db 0xbc,0x81,'Image height',0
db 0xbc,0x82,'Width resolution',0
db 0xbc,0x83,'Height resolution',0
db 0xbc,0xc0,'Image offset',0
db 0xbc,0xc1,'Image byte count',0
db 0xbc,0xc2,'Alpha offset',0
db 0xbc,0xc3,'Alpha byte count',0
db 0xbc,0xc4,'Image data discard',0
db 0xbc,0xc5,'Alpha data discard',0
db 0xc4,0x27,'Oce scanjob desc',0
db 0xc4,0x28,'Oce application selector',0
db 0xc4,0x29,'Oce ID number',0
db 0xc4,0x2a,'Oce image logic',0
db 0xc4,0x4f,'Annotations',0
db 0xc4,0xa5,'Print IM',0
db 0xc5,0x73,'Original file name',0
db 0xc5,0x80,'USPTO original content type',0
db 0xc6,0x12,'DNG version',0
db 0xc6,0x13,'DNG backward version',0
db 0xc6,0x14,'Unique camera model',0
db 0xc6,0x15,'Localized camera model',0
db 0xc6,0x16,'CFA plane color',0
db 0xc6,0x17,'CFA layout',0
db 0xc6,0x18,'Linearization table',0
db 0xc6,0x19,'Black level repeat dim',0
db 0xc6,0x1a,'Black level',0
db 0xc6,0x1b,'Black level delta H',0
db 0xc6,0x1c,'Black level delta V',0
db 0xc6,0x1d,'White level',0
db 0xc6,0x1e,'Default scale',0
db 0xc6,0x1f,'Default crop origin',0
db 0xc6,0x20,'Default crop size',0
db 0xc6,0x21,'Color matrix 1',0
db 0xc6,0x22,'Color matrix 2',0
db 0xc6,0x23,'Camera calibration 1',0
db 0xc6,0x24,'Camera calibration 2',0
db 0xc6,0x25,'Reduction matrix 1',0
db 0xc6,0x26,'Reduction matrix 2',0
db 0xc6,0x27,'Analog balance',0
db 0xc6,0x28,'As shot neutral',0
db 0xc6,0x29,'As shot white XY',0
db 0xc6,0x2a,'BaselineExposure',0
db 0xc6,0x2b,'BaselineNoise',0
db 0xc6,0x2c,'BaselineSharpness',0
db 0xc6,0x2d,'BayerGreenSplit',0
db 0xc6,0x2e,'Linear response limit',0
db 0xc6,0x2f,'Camera serial number',0
db 0xc6,0x30,'DNG lens info',0
db 0xc6,0x31,'Chroma blur radius',0
db 0xc6,0x32,'Anti alias strength',0
db 0xc6,0x33,'Shadow scale',0
db 0xc6,0x34,'SR2 private',0
db 0xc6,0x35,'Maker note safety',0
db 0xc6,0x40,'Raw image segmentation',0
db 0xc6,0x5a,'Calibration illuminant 1',0
db 0xc6,0x5b,'Calibration illuminant 2',0
db 0xc6,0x5c,'Best quality scale',0
db 0xc6,0x5d,'Raw data unique ID',0
db 0xc6,0x60,'Alias layer metadata',0
db 0xc6,0x8b,'Original raw file name',0
db 0xc6,0x8c,'Original raw file data',0
db 0xc6,0x8d,'Active area',0
db 0xc6,0x8e,'Masked areas',0
db 0xc6,0x8f,'AsShot ICC profile',0
db 0xc6,0x90,'AsShot pre profile matrix',0
db 0xc6,0x91,'Current ICC profile',0
db 0xc6,0x92,'Current pre profile matrix',0
db 0xc6,0xbf,'Colorimetric reference',0
db 0xc6,0xd2,'Panasonic title',0
db 0xc6,0xd3,'Panasonic title 2',0
db 0xc6,0xf3,'Camera calibration sig',0
db 0xc6,0xf4,'Profile calibration sig',0
db 0xc6,0xf5,'Profile IFD',0
db 0xc6,0xf6,'AsShot profile name',0
db 0xc6,0xf7,'Noise reduction applied',0
db 0xc6,0xf8,'Profile name',0
db 0xc6,0xf9,'Profile hue sat map dims',0
db 0xc6,0xfa,'Profile hue sat map data 1',0
db 0xc6,0xfb,'Profile hue sat map data 2',0
db 0xc6,0xfc,'Profile tone curve',0
db 0xc6,0xfd,'Profile embed policy',0
db 0xc6,0xfe,'Profile copyright',0
db 0xc7,0x14,'Forward matrix 1',0
db 0xc7,0x15,'Forward matrix 2',0
db 0xc7,0x16,'Preview application name',0
db 0xc7,0x17,'Preview application version',0
db 0xc7,0x18,'Preview settings name',0
db 0xc7,0x19,'Preview settings digest',0
db 0xc7,0x1a,'Preview color space',0
db 0xc7,0x1b,'Preview date time',0
db 0xc7,0x1c,'Raw image digest',0
db 0xc7,0x1d,'Original raw file digest',0
db 0xc7,0x1e,'Sub tile block size',0
db 0xc7,0x1f,'Row interleave factor',0
db 0xc7,0x25,'Profile look table dims',0
db 0xc7,0x26,'Profile look table data',0
db 0xc7,0x40,'Opcode list 1',0
db 0xc7,0x41,'Opcode list 2',0
db 0xc7,0x4e,'Opcode list 3',0
db 0xc7,0x61,'Noise profile',0
db 0xc7,0x63,'Time codes',0
db 0xc7,0x64,'Frame rate',0
db 0xc7,0x72,'TStop',0
db 0xc7,0x89,'Reel name',0
db 0xc7,0x91,'Original default final size',0
db 0xc7,0x92,'Original best quality size',0
db 0xc7,0x93,'Original default crop size',0
db 0xc7,0xa1,'Camera label',0
db 0xc7,0xa3,'Profile hue sat map encoding',0
db 0xc7,0xa4,'Profile look table encoding',0
db 0xc7,0xa5,'Baseline exposure offset',0
db 0xc7,0xa6,'Default black render',0
db 0xc7,0xa7,'New raw image digest',0
db 0xc7,0xa8,'Raw to preview gain',0
db 0xc7,0xb5,'Default user crop',0
db 0xea,0x1c,'Padding',0
db 0xea,0x1d,'Offset schema',0
db 0xfd,0xe8,'Owner name',0
db 0xfd,0xe9,'Serial number',0
db 0xfd,0xea,'Lens',0
db 0xfe,0x00,'KDC_IFD',0
db 0xfe,0x4c,'Raw file',0
db 0xfe,0x4d,'Converter',0
db 0xfe,0x4e,'White balance',0
db 0xfe,0x51,'Exposure',0
db 0xfe,0x52,'Shadows',0
db 0xfe,0x53,'Brightness',0
db 0xfe,0x54,'Contrast',0
db 0xfe,0x55,'Saturation',0
db 0xfe,0x56,'Sharpness',0
db 0xfe,0x57,'Smoothness',0
db 0xfe,0x58,'Moire filter',0

db 0x00,0x00,'GPS version ID',0

dd 0

;input:
; bof - 㪠��⥫� �� ��砫� 䠩��
; app1 - 㪠��⥫� ��� ���������� exif.app1
;output:
; app1 - 㪠��⥫� �� ��砫� exif.app1 (��� 0 �᫨ �� ������� ��� �ଠ� 䠩�� �� �����ন������)
align 4
proc exif_get_app1 uses eax ebx edi, bof:dword, app1:dword
	mov eax,[bof]
	mov edi,[app1]

	;䠩� � �ଠ� jpg?
	cmp word[eax],0xd8ff
	jne .no_exif
	add eax,2

	;䠩� ᮤ�ন� exif.app0?
	cmp word[eax],0xe0ff
	jne @f
		add eax,2
		movzx ebx,word[eax]
		ror bx,8 ;�ᥣ�� �� ⠪ ����?
		add eax,ebx
	@@:

	;䠩� ᮤ�ন� exif.app1?
	cmp word[eax],0xe1ff
	jne .no_exif

	xor ebx,ebx
	cmp word[eax+10],'II'
	je @f
		inc ebx ;if 'MM' edx=1
	@@:
	mov [edi+offs_m_or_i],ebx
	add eax,18
	mov [edi],eax
	sub eax,8
	mov [edi+4],eax

	jmp @f
	.no_exif:
		mov dword[edi],0
	@@:
	ret
endp

;input:
; app1 - 㪠��⥫� �� ��砫� exif.app1
; num - ���浪��� ����� ⥣� (��稭����� � 1)
; txt - 㪠��⥫� �� ⥪��, �㤠 �㤥� ����ᠭ� ���祭��
; t_max - ���ᨬ���� ࠧ��� ⥪��
align 4
proc exif_get_app1_tag, app1:dword, num:dword, txt:dword, t_max:dword
pushad
	mov eax,[app1]
	mov edi,[txt]
	mov ecx,[num]

	xor edx,edx
	mov byte[edi],dl
	cmp [eax],edx
	je .end_f ;�᫨ �� ������ 㪠��⥫� �� ��砫� exif.app1
	cmp ecx,edx
	jle .end_f ;�᫨ ���浪��� ����� ⥣� <= 0

	movzx edx,word[eax+offs_m_or_i] ;if 'MM' edx=1

	;�஢��塞 �᫮ ⥣��
	mov eax,[eax]
	movzx ebx,word[eax]
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp ecx,ebx
	jg .end_f ;�᫨ ����� ⥣� ����� 祬 �� ���� � 䠩��

	;���室�� �� ������� ⥣
	dec ecx
	imul ecx,tag_size
	add eax,offs_tag_0
	add eax,ecx

	stdcall read_tag_value,[app1],[t_max]

	.end_f:
popad
	ret
endp

;input:
; app1 - 㪠��⥫� �� exif.app1 ��� �� exif.app1.child
; child - 㪠��⥫� ��� ���������� ��砫� ���୨� ⥣�� exif.app1.child
; c_tag - ⥣ ��� ���ண� �������� ���� ���୨�
;output:
; child - 㪠��⥫� �� ��砫� ���୨� ⥣��
align 4
proc exif_get_app1_child, app1:dword, child:dword , c_tag:dword
pushad
	mov eax,[app1]
	mov edi,[child]

	xor edx,edx
	cmp [eax],edx
	je .no_found ;�᫨ �� ������ 㪠��⥫� �� ��砫� exif.app1

	movzx edx,word[eax+offs_m_or_i] ;if 'MM' edx=1

	;��砫� ���᪠
	mov ebx,[c_tag]
	bt edx,0
	jnc @f
		ror bx,8
	@@:

	;�஢��塞 �᫮ ⥣��
	mov eax,[eax]
	movzx ecx,word[eax]
	bt edx,0
	jnc @f
		ror cx,8
	@@:
	cmp ecx,1
	jl .no_found ;�᫨ �᫮ ⥣�� <1

	;���室�� �� 1-� ⥣
	add eax,offs_tag_0
	@@:
		cmp word[eax],bx
		je @f
		add eax,tag_size
		loop @b
	jmp .no_found ;�᫨ �� �������
	@@: ;�᫨ �������
		mov ebx,dword[eax+8]
		bt edx,0
		jnc @f
			ror bx,8
			ror ebx,16
			ror bx,8
		@@:
		mov eax,[app1]
		add ebx,[eax+4]
		mov dword[edi],ebx
		m2m dword[edi+4],dword[eax+4]
		mov dword[edi+offs_m_or_i],edx

	jmp .end_f
	.no_found:
		mov dword[edi],0
	.end_f:
popad
	ret
endp

;description:
; �ᯮ����⥫쭠� �㭪�� ��� �⥭�� �����祭�� ⥣��
;input:
; eax - 㪠��⥫� ��砫� ⥣�
; edi - 㪠��⥫� �� ������ ��� ����� ⥪�⮢�� ��ப�
align 4
proc read_tag_value, app1:dword, t_max:dword
	push exif_tag_numbers
	pop esi
	.next_tag:
	mov bx,word[esi]
	cmp bx,0
	jne @f
		cmp dword[esi],0
		jne @f
		jmp .tag_unknown ;⥣ �� �������
	@@:
	bt edx,0
	jc @f
		ror bx,8
	@@:
	cmp word[eax],bx
	je .found
	inc esi
	@@:
		inc esi
		cmp byte[esi],0
		jne @b
	inc esi
	jmp .next_tag
	.found:

	;�����㥬 ��ப�
	add esi,2
	stdcall str_n_cat,edi,esi,[t_max]

	jmp @f
	.tag_unknown:
		mov dword[edi],'???'
		mov byte[edi+3],0
	@@:

	;�⠥� ���ଠ�� � ⥣�
	mov bx,tag_format_text
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_02
		stdcall str_n_cat,edi,txt_dp,[t_max]
		call get_tag_data_size ;�஢��塞 ������ ��ப�
		cmp ebx,4
		jg @f
			;�᫨ ��ப� ����頥��� � 4 ᨬ����
			mov esi,eax
			add esi,8
			stdcall str_n_cat,edi,esi,[t_max]
			jmp .end_f
		;�᫨ ��ப� �� ����頥��� � 4 ᨬ����
		@@:
		mov esi,dword[eax+8]
		bt edx,0
		jnc @f
			ror si,8
			ror esi,16
			ror si,8
		@@:
		mov eax,[app1]
		mov eax,[eax+4]
		add esi,eax
		stdcall str_n_cat,edi,esi,[t_max]
		jmp .end_f
	.tag_02:

	mov bx,tag_format_ui2b
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_03
		stdcall str_n_cat,edi,txt_dp,[t_max]
		call get_tag_data_size
		cmp ebx,1
		jg .over4b_03
			;�᫨ ���� 2 ���⮢�� �᫮
			movzx ebx,word[eax+8]
			bt edx,0
			jnc @f
				ror bx,8
			@@:
			stdcall str_len,edi
			add edi,eax
			mov eax,ebx
			call convert_int_to_str ;[t_max]
		.over4b_03:
			;...
		jmp .end_f
	.tag_03:

	mov bx,tag_format_ui4b
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_04
		stdcall str_n_cat,edi,txt_dp,[t_max]
		call get_tag_data_size
		cmp ebx,1
		jg .over4b_04
			;�᫨ ���� 4 ���⮢�� �᫮
			mov ebx,dword[eax+8]
			bt edx,0
			jnc @f
				ror bx,8
				ror ebx,16
				ror bx,8
			@@:
			stdcall str_len,edi
			add edi,eax
			mov eax,ebx
			call convert_int_to_str ;[t_max]
		.over4b_04:
			;...
		jmp .end_f
	.tag_04:

	mov bx,tag_format_urb
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_05
		stdcall str_n_cat,edi,txt_dp,[t_max]
		;call get_tag_data_size
		;cmp ebx,1
		;jg .over4b_05
			mov ebx,dword[eax+8]
			bt edx,0
			jnc @f
				ror bx,8
				ror ebx,16
				ror bx,8
			@@:
			stdcall str_len,edi
			add edi,eax
			mov eax,[app1]
			mov eax,[eax+4]
			add ebx,eax
			mov eax,[ebx]
			bt edx,0
			jnc @f
				ror ax,8
				ror eax,16
				ror ax,8
			@@:
			call convert_int_to_str ;�⠢�� 1-� �᫮
			stdcall str_n_cat,edi,txt_div,[t_max] ;�⠢�� ���� �������
			stdcall str_len,edi
			add edi,eax
			mov eax,[ebx+4]
			bt edx,0
			jnc @f
				ror ax,8
				ror eax,16
				ror ax,8
			@@:
			call convert_int_to_str ;�⠢�� 2-� �᫮
		;.over4b_05:
			;...
		jmp .end_f
	.tag_05:

	mov bx,tag_format_si2b
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_08
		stdcall str_n_cat,edi,txt_dp,[t_max]
		call get_tag_data_size
		cmp ebx,1
		jg .over4b_08
			;�᫨ ���� 2 ���⮢�� �᫮
			movzx ebx,word[eax+8]
			bt edx,0
			jnc @f
				ror bx,8
			@@:
			stdcall str_len,edi
			add edi,eax
			bt bx,15
			jnc @f
				mov byte[edi],'-'
				inc edi
				neg bx
				inc bx
			@@:
			mov eax,ebx
			call convert_int_to_str ;[t_max]
		.over4b_08:
			;...
		jmp .end_f
	.tag_08:

	mov bx,tag_format_si4b
	bt edx,0
	jnc @f
		ror bx,8
	@@:
	cmp word[eax+2],bx
	jne .tag_09
		stdcall str_n_cat,edi,txt_dp,[t_max]
		call get_tag_data_size
		cmp ebx,1
		jg .over4b_09
			;�᫨ ���� 4 ���⮢�� �᫮
			mov ebx,dword[eax+8]
			bt edx,0
			jnc @f
				ror bx,8
				ror ebx,16
				ror bx,8
			@@:
			stdcall str_len,edi
			add edi,eax
			bt ebx,31
			jnc @f
				mov byte[edi],'-'
				inc edi
				neg ebx
				inc ebx
			@@:
			mov eax,ebx
			call convert_int_to_str ;[t_max]
		.over4b_09:
			;...
		jmp .end_f
	.tag_09:

	.end_f:
	ret
endp

;input:
; eax - tag pointer
; edx - 1 if 'MM', 0 if 'II'
;output:
; ebx - data size
align 4
get_tag_data_size:
	mov ebx,dword[eax+4]
	bt edx,0
	jnc @f
		ror bx,8
		ror ebx,16
		ror bx,8
	@@:
	ret

align 4
proc str_n_cat uses eax ecx edi esi, str1:dword, str2:dword, n:dword
	mov esi,dword[str2]
	mov ecx,dword[n]
	mov edi,dword[str1]
	stdcall str_len,edi
	add edi,eax
	cld
	repne movsb
	mov byte[edi],0
	ret
endp

;output:
; eax = strlen
align 4
proc str_len, str1:dword
	mov eax,[str1]
	@@:
		cmp byte[eax],0
		je @f
		inc eax
		jmp @b
	@@:
	sub eax,[str1]
	ret
endp

;input:
; eax = value
; edi = string buffer
;output:
align 4
convert_int_to_str:
	pushad
		mov dword[edi+1],0
		mov dword[edi+5],0
		call .str
	popad
	ret

align 4
.str:
	mov ecx,0x0a ;�������� ��⥬� ��᫥��� ���������� ॣ����� ebx,eax,ecx,edx �室�� ��ࠬ���� eax - �᫮
    ;��ॢ�� �᫠ � ASCII ��ப� ������ ����� ecx=��⥬� ��᫥�� edi ���� �㤠 �����뢠��, �㤥� ��ப�, ��祬 ����� ��६����� 
	cmp eax,ecx  ;�ࠢ���� �᫨ � eax ����� 祬 � ecx � ��३� �� @@-1 �.�. �� pop eax
	jb @f
		xor edx,edx  ;������ edx
		div ecx      ;ࠧ������ - ���⮪ � edx
		push edx     ;�������� � �⥪
		;dec edi             ;ᬥ饭�� ����室���� ��� ����� � ���� ��ப�
		call .str ;��३� �� ᠬ� ᥡ� �.�. �맢��� ᠬ� ᥡ� � ⠪ �� ⮣� ������ ���� � eax �� �⠭�� ����� 祬 � ecx
		pop eax
	@@: ;cmp al,10 ;�஢���� �� ����� �� ���祭�� � al 祬 10 (��� ��⥬� ��᫥�� 10 ������ ������� - ��譠�))
	or al,0x30  ;������ ������� ����  祬 ��� ���
	stosb	    ;������� ������� �� ॣ���� al � �祪� ����� es:edi
	ret	      ;�������� 祭� ������ 室 �.�. ���� � �⥪� �࠭����� ���-�� �맮��� � �⮫쪮 ࠧ �� � �㤥� ��뢠����



align 16
EXPORTS:
	dd sz_exif_get_app1, exif_get_app1
	dd sz_exif_get_app1_tag, exif_get_app1_tag
	dd sz_exif_get_app1_child, exif_get_app1_child
	dd 0,0
	sz_exif_get_app1 db 'exif_get_app1',0
	sz_exif_get_app1_tag db 'exif_get_app1_tag',0
	sz_exif_get_app1_child db 'exif_get_app1_child',0