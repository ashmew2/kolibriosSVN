
typedef void *pointer;


typedef unsigned int memType;

typedef struct { float hi, lo; } range;


#define R300_PIO     1

#define PCI_CMD_STAT_REG        0x04

typedef enum
{
    CHIP_FAMILY_UNKNOW,
    CHIP_FAMILY_LEGACY,
    CHIP_FAMILY_RADEON,
    CHIP_FAMILY_RV100,
    CHIP_FAMILY_RS100,    /* U1 (IGP320M) or A3 (IGP320)*/
    CHIP_FAMILY_RV200,
    CHIP_FAMILY_RS200,    /* U2 (IGP330M/340M/350M) or A4 (IGP330/340/345/350), RS250 (IGP 7000) */
    CHIP_FAMILY_R200,
    CHIP_FAMILY_RV250,
    CHIP_FAMILY_RS300,    /* RS300/RS350 */
    CHIP_FAMILY_RV280,
    CHIP_FAMILY_R300,
    CHIP_FAMILY_R350,
    CHIP_FAMILY_RV350,
    CHIP_FAMILY_RV380,    /* RV370/RV380/M22/M24 */
    CHIP_FAMILY_R420,     /* R420/R423/M18 */
    CHIP_FAMILY_RV410,    /* RV410, M26 */
    CHIP_FAMILY_RS400,    /* xpress 200, 200m (RS400) Intel */
    CHIP_FAMILY_RS480,    /* xpress 200, 200m (RS410/480/482/485) AMD */
    CHIP_FAMILY_RV515,    /* rv515 */
    CHIP_FAMILY_R520,     /* r520 */
    CHIP_FAMILY_RV530,    /* rv530 */
    CHIP_FAMILY_R580,     /* r580 */
    CHIP_FAMILY_RV560,    /* rv560 */
    CHIP_FAMILY_RV570,    /* rv570 */
    CHIP_FAMILY_RS600,
    CHIP_FAMILY_RS690,
    CHIP_FAMILY_RS740,
    CHIP_FAMILY_R600,     /* r600 */
    CHIP_FAMILY_R630,
    CHIP_FAMILY_RV610,
    CHIP_FAMILY_RV630,
    CHIP_FAMILY_RV670,
    CHIP_FAMILY_RV620,
    CHIP_FAMILY_RV635,
    CHIP_FAMILY_RS780,
    CHIP_FAMILY_RV770,
    CHIP_FAMILY_LAST
} RADEONChipFamily;

#define IS_RV100_VARIANT ((rhdPtr->ChipFamily == CHIP_FAMILY_RV100)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RV200)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RS100)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RS200)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RV250)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RV280)  ||  \
        (rhdPtr->ChipFamily == CHIP_FAMILY_RS300))


#define IS_R300_VARIANT ((info->ChipFamily == CHIP_FAMILY_R300)  ||  \
        (info->ChipFamily == CHIP_FAMILY_RV350) ||  \
        (info->ChipFamily == CHIP_FAMILY_R350)  ||  \
        (info->ChipFamily == CHIP_FAMILY_RV380) ||  \
        (info->ChipFamily == CHIP_FAMILY_R420)  ||  \
        (info->ChipFamily == CHIP_FAMILY_RV410) ||  \
        (info->ChipFamily == CHIP_FAMILY_RS400) ||  \
        (info->ChipFamily == CHIP_FAMILY_RS480))

#define IS_AVIVO_VARIANT ((info->ChipFamily >= CHIP_FAMILY_RV515))

#define IS_DCE3_VARIANT ((info->ChipFamily >= CHIP_FAMILY_RV620))

#define IS_R500_3D ((info->ChipFamily == CHIP_FAMILY_RV515)  ||  \
	(info->ChipFamily == CHIP_FAMILY_R520)   ||  \
	(info->ChipFamily == CHIP_FAMILY_RV530)  ||  \
	(info->ChipFamily == CHIP_FAMILY_R580)   ||  \
	(info->ChipFamily == CHIP_FAMILY_RV560)  ||  \
	(info->ChipFamily == CHIP_FAMILY_RV570))

#define IS_R300_3D ((info->ChipFamily == CHIP_FAMILY_R300)  ||  \
	(info->ChipFamily == CHIP_FAMILY_RV350) ||  \
	(info->ChipFamily == CHIP_FAMILY_R350)  ||  \
	(info->ChipFamily == CHIP_FAMILY_RV380) ||  \
	(info->ChipFamily == CHIP_FAMILY_R420)  ||  \
	(info->ChipFamily == CHIP_FAMILY_RV410) ||  \
	(info->ChipFamily == CHIP_FAMILY_RS690) ||  \
	(info->ChipFamily == CHIP_FAMILY_RS600) ||  \
	(info->ChipFamily == CHIP_FAMILY_RS740) ||  \
	(info->ChipFamily == CHIP_FAMILY_RS400) ||  \
	(info->ChipFamily == CHIP_FAMILY_RS480))



typedef enum {
	CARD_PCI,
	CARD_AGP,
	CARD_PCIE
} RADEONCardType;

/*
 * Errata workarounds
 */
typedef enum {
       CHIP_ERRATA_R300_CG             = 0x00000001,
       CHIP_ERRATA_PLL_DUMMYREADS      = 0x00000002,
       CHIP_ERRATA_PLL_DELAY           = 0x00000004
} RADEONErrata;

typedef struct
{
    u32_t pci_device_id;
    RADEONChipFamily chip_family;
    int mobility;
    int igp;
    int nocrtc2;
    int nointtvout;
    int singledac;
} RADEONCardInfo;



#define RHD_FB_BAR         0
#define RHD_MMIO_BAR       2

#define RHD_MEM_GART       1
#define RHD_MEM_FB         2

typedef struct RHDRec
{
  u32_t            MMIOBase;
  u32_t            MMIOMapSize;

//  CARD32            FbBase;            /* map base of fb   */
 // u32_t            PhisBase;
 // u32_t            FbIntAddress;       /* card internal address of FB */
 // u32_t            FbMapSize;

  u32_t            FbFreeStart;
  u32_t            FbFreeSize;

  /* visible part of the framebuffer */
//  unsigned int      FbScanoutStart;
//  unsigned int      FbScanoutSize;

  u32_t            LinearAddr;           /* Frame buffer physical address     */

  u32_t            fbLocation;
  u32_t            mc_fb_location;
  u32_t            mc_agp_location;
  u32_t            mc_agp_location_hi;

  u32_t            videoRam;

  u32_t            MemCntl;
  u32_t            BusCntl;
  unsigned long    FbMapSize;            /* Size of frame buffer, in bytes    */
  unsigned long    FbSecureSize;         /* Size of secured fb area at end of
                                            framebuffer */


  RADEONChipFamily ChipFamily;
  RADEONErrata     ChipErrata;

  char             *chipset;

  int              IsIGP;
  int              IsMobility;

  u32_t            bus;
  u32_t            devfn;

  PCITAG           PciTag;
  u16_t            PciDeviceID;

  u16_t            subvendor_id;
  u16_t            subdevice_id;

  RADEONCardType   cardType;            /* Current card is a PCI card */

  u32_t            memBase[6];
  u32_t            ioBase[6];
  u32_t            memtype[6];
  u32_t            memsize[6];

  struct mem_block  *fb_heap;
  struct mem_block  *gart_heap;

  u32_t            displayWidth;
  u32_t            displayHeight;

  int              __xmin;
  int              __ymin;
  int              __xmax;
  int              __ymax;

  u32_t            gui_control;
  u32_t            dst_pitch_offset;
  u32_t            surface_cntl;

  u32_t            *ring_base;
  u32_t            ring_rp;
  u32_t            ring_wp;

  int              RamWidth;
  Bool             IsDDR;

  int              num_gb_pipes;
  int              has_tcl;
}RHD_t, *RHDPtr;

extern RHD_t rhd;



#define R5XX_DP_BRUSH_BKGD_CLR            0x1478
#define R5XX_DP_BRUSH_FRGD_CLR            0x147c
#define R5XX_BRUSH_DATA0                  0x1480
#define R5XX_BRUSH_DATA1                  0x1484

# define RADEON_GMC_SRC_PITCH_OFFSET_CNTL (1 << 0)
#	define RADEON_GMC_DST_PITCH_OFFSET_CNTL	(1 << 1)
# define RADEON_GMC_BRUSH_SOLID_COLOR     (13 << 4)
# define RADEON_GMC_BRUSH_NONE            (15 << 4)
# define RADEON_GMC_DST_16BPP             (4 << 8)
# define RADEON_GMC_DST_24BPP             (5 << 8)
# define RADEON_GMC_DST_32BPP             (6 << 8)
# define RADEON_GMC_DST_DATATYPE_SHIFT     8
# define RADEON_GMC_SRC_DATATYPE_COLOR    (3 << 12)
# define RADEON_DP_SRC_SOURCE_MEMORY      (2 << 24)
# define RADEON_DP_SRC_SOURCE_HOST_DATA   (3 << 24)
# define RADEON_GMC_CLR_CMP_CNTL_DIS      (1 << 28)
# define RADEON_GMC_WR_MSK_DIS            (1 << 30)
# define RADEON_ROP3_S                 0x00cc0000
# define RADEON_ROP3_P                 0x00f00000

#define RADEON_CP_PACKET0              0x00000000
#define RADEON_CP_PACKET1              0x40000000
#define RADEON_CP_PACKET2              0x80000000
#define RADEON_CP_PACKET3              0xC0000000

# define RADEON_CNTL_PAINT             0x00009100
# define RADEON_CNTL_BITBLT            0x00009200
# define RADEON_CNTL_TRANBLT           0x00009C00

# define RADEON_CNTL_PAINT_POLYLINE    0x00009500
# define RADEON_CNTL_PAINT_MULTI       0x00009A00

#define CP_PACKET0(reg, n)            \
	(RADEON_CP_PACKET0 | ((n) << 16) | ((reg) >> 2))

#define CP_PACKET1(reg0, reg1)            \
	(RADEON_CP_PACKET1 | (((reg1) >> 2) << 11) | ((reg0) >> 2))

#define CP_PACKET2()              \
  (RADEON_CP_PACKET2)

#define CP_PACKET3( pkt, n )            \
	(RADEON_CP_PACKET3 | (pkt) | ((n) << 16))

#define BEGIN_RING( n ) do {            \
  ring = rhd.ring_base;                 \
  write = rhd.ring_wp;                  \
} while (0)

#define ADVANCE_RING()

#define OUT_RING( x ) do {        \
	ring[write++] = (x);						\
} while (0)

#define OUT_RING_REG(reg, val)            \
do {									\
    OUT_RING(CP_PACKET0(reg, 0));					\
    OUT_RING(val);							\
} while (0)

#define DRM_MEMORYBARRIER()  __asm volatile("lock; addl $0,0(%%esp)" : : : "memory");

#define COMMIT_RING() do {                            \
  rhd.ring_wp = write & 0x1FFF;                       \
  /* Flush writes to ring */                          \
  DRM_MEMORYBARRIER();                                \
  /*GET_RING_HEAD( dev_priv );          */            \
  OUTREG( RADEON_CP_RB_WPTR, rhd.ring_wp);            \
	/* read from PCI bus to ensure correct posting */		\
  INREG( RADEON_CP_RB_RPTR );                         \
} while (0)



typedef struct {
    int			token;		/* id of the token */
    const char *	name;		/* token name */
} SymTabRec, *SymTabPtr;



extern inline void
OUTREG8(u16_t offset, u8_t value)
{
  *(volatile u8_t *)((u8_t *)(rhd.MMIOBase + offset)) = value;
}


extern inline u32_t INREG(u16_t offset)
{
  return *(volatile u32_t *)((u8_t*)(rhd.MMIOBase + offset));
}


extern inline void OUTREG(u16_t offset, u32_t value)
{
  *(volatile u32_t *)((u8_t *)(rhd.MMIOBase + offset)) = value;
}


extern inline u32_t _RHDRegRead(RHDPtr rhdPtr, u16_t offset)
{
  return *(volatile u32_t *)((u8_t*)(rhdPtr->MMIOBase + offset));
}

extern inline void
MASKREG(u16_t offset, u32_t value, u32_t mask)
{
  u32_t tmp;

  tmp = INREG(offset);
  tmp &= ~mask;
  tmp |= (value & mask);
  OUTREG(offset, tmp);
};

extern inline void
_RHDRegWrite(RHDPtr rhdPtr, u16_t offset, u32_t value)
{
  *(volatile u32_t *)((u8_t *)(rhdPtr->MMIOBase + offset)) = value;
}

extern inline void
_RHDRegMask(RHDPtr rhdPtr, u16_t offset, u32_t value, u32_t mask)
{
  u32_t tmp;

  tmp = _RHDRegRead(rhdPtr, offset);
  tmp &= ~mask;
  tmp |= (value & mask);
  _RHDRegWrite(rhdPtr, offset, tmp);
};

#define RHDRegRead(ptr, offset) _RHDRegRead((ptr)->rhdPtr, (offset))
#define RHDRegWrite(ptr, offset, value) _RHDRegWrite((ptr)->rhdPtr, (offset), (value))
#define RHDRegMask(ptr, offset, value, mask) _RHDRegMask((ptr)->rhdPtr, (offset), (value), (mask))


RHDPtr FindPciDevice();

Bool RHDPreInit();
int rhdInitHeap(RHDPtr rhdPtr);

#define RHDFUNC(ptr)

#define DBG(x) x
//  #define DBG(x)

#pragma pack (push,1)
typedef struct s_cursor
{
   u32_t   magic;                           // 'CURS'
   void  (*destroy)(struct s_cursor*);    // destructor
   u32_t   fd;                              // next object in list
   u32_t   bk;                              // prev object in list
   u32_t   pid;                             // owner id

   void *base;                            // allocated memory
   u32_t   hot_x;                           // hotspot coords
   u32_t   hot_y;
}cursor_t;
#pragma pack (pop)

#define LOAD_FROM_FILE   0
#define LOAD_FROM_MEM    1
#define LOAD_INDIRECT    2

cursor_t *create_cursor(u32_t pid, void *src, u32_t flags);
void __stdcall copy_cursor(void *img, void *src);
void destroy_cursor(cursor_t *cursor);
void __destroy_cursor(cursor_t *cursor);                // wrap

void __stdcall r500_SelectCursor(cursor_t *cursor);
void __stdcall r500_SetCursor(cursor_t *cursor, int x, int y);
void __stdcall r500_CursorRestore(int x, int y);

void  R5xx2DInit();


typedef struct {
    u32_t x ;
    u32_t y ;
} xPointFixed;

typedef u32_t   xFixed_16_16;

typedef xFixed_16_16  xFixed;

#define XFIXED_BITS 16

#define xFixedToInt(f)  (int) ((f) >> XFIXED_BITS)
#define IntToxFixed(i)  ((xFixed) (i) << XFIXED_BITS)

#define xFixedToFloat(f) (((float) (f)) / 65536)

#define PICT_FORMAT(bpp,type,a,r,g,b) (((bpp) << 24) |  \
					 ((type) << 16) | \
					 ((a) << 12) | \
					 ((r) << 8) | \
					 ((g) << 4) | \
					 ((b)))

#define PICT_FORMAT_A(f)  (((f) >> 12) & 0x0f)
#define PICT_FORMAT_RGB(f)  (((f)      ) & 0xfff)

#define PICT_TYPE_OTHER 0
#define PICT_TYPE_A     1
#define PICT_TYPE_ARGB	2
#define PICT_TYPE_ABGR	3
#define PICT_TYPE_COLOR	4
#define PICT_TYPE_GRAY	5

typedef enum _PictFormatShort {
   PICT_a8r8g8b8 =	PICT_FORMAT(32,PICT_TYPE_ARGB,8,8,8,8),
   PICT_x8r8g8b8 =	PICT_FORMAT(32,PICT_TYPE_ARGB,0,8,8,8),
   PICT_a8b8g8r8 =	PICT_FORMAT(32,PICT_TYPE_ABGR,8,8,8,8),
   PICT_x8b8g8r8 =	PICT_FORMAT(32,PICT_TYPE_ABGR,0,8,8,8),

/* 24bpp formats */
   PICT_r8g8b8 =	PICT_FORMAT(24,PICT_TYPE_ARGB,0,8,8,8),
   PICT_b8g8r8 =	PICT_FORMAT(24,PICT_TYPE_ABGR,0,8,8,8),

/* 16bpp formats */
   PICT_r5g6b5 =	PICT_FORMAT(16,PICT_TYPE_ARGB,0,5,6,5),
   PICT_b5g6r5 =	PICT_FORMAT(16,PICT_TYPE_ABGR,0,5,6,5),

   PICT_a1r5g5b5 =	PICT_FORMAT(16,PICT_TYPE_ARGB,1,5,5,5),
   PICT_x1r5g5b5 =	PICT_FORMAT(16,PICT_TYPE_ARGB,0,5,5,5),
   PICT_a1b5g5r5 =	PICT_FORMAT(16,PICT_TYPE_ABGR,1,5,5,5),
   PICT_x1b5g5r5 =	PICT_FORMAT(16,PICT_TYPE_ABGR,0,5,5,5),
   PICT_a4r4g4b4 =	PICT_FORMAT(16,PICT_TYPE_ARGB,4,4,4,4),
   PICT_x4r4g4b4 =	PICT_FORMAT(16,PICT_TYPE_ARGB,0,4,4,4),
   PICT_a4b4g4r4 =	PICT_FORMAT(16,PICT_TYPE_ABGR,4,4,4,4),
   PICT_x4b4g4r4 =	PICT_FORMAT(16,PICT_TYPE_ABGR,0,4,4,4),

/* 8bpp formats */
   PICT_a8 =		PICT_FORMAT(8,PICT_TYPE_A,8,0,0,0),
   PICT_r3g3b2 =	PICT_FORMAT(8,PICT_TYPE_ARGB,0,3,3,2),
   PICT_b2g3r3 =	PICT_FORMAT(8,PICT_TYPE_ABGR,0,3,3,2),
   PICT_a2r2g2b2 =	PICT_FORMAT(8,PICT_TYPE_ARGB,2,2,2,2),
   PICT_a2b2g2r2 =	PICT_FORMAT(8,PICT_TYPE_ABGR,2,2,2,2),

   PICT_c8 =		PICT_FORMAT(8,PICT_TYPE_COLOR,0,0,0,0),
   PICT_g8 =		PICT_FORMAT(8,PICT_TYPE_GRAY,0,0,0,0),

   PICT_x4a4 =		PICT_FORMAT(8,PICT_TYPE_A,4,0,0,0),

   PICT_x4c4 =		PICT_FORMAT(8,PICT_TYPE_COLOR,0,0,0,0),
   PICT_x4g4 =		PICT_FORMAT(8,PICT_TYPE_GRAY,0,0,0,0),

/* 4bpp formats */
   PICT_a4 =		PICT_FORMAT(4,PICT_TYPE_A,4,0,0,0),
   PICT_r1g2b1 =	PICT_FORMAT(4,PICT_TYPE_ARGB,0,1,2,1),
   PICT_b1g2r1 =	PICT_FORMAT(4,PICT_TYPE_ABGR,0,1,2,1),
   PICT_a1r1g1b1 =	PICT_FORMAT(4,PICT_TYPE_ARGB,1,1,1,1),
   PICT_a1b1g1r1 =	PICT_FORMAT(4,PICT_TYPE_ABGR,1,1,1,1),

   PICT_c4 =		PICT_FORMAT(4,PICT_TYPE_COLOR,0,0,0,0),
   PICT_g4 =		PICT_FORMAT(4,PICT_TYPE_GRAY,0,0,0,0),

/* 1bpp formats */
   PICT_a1 =		PICT_FORMAT(1,PICT_TYPE_A,1,0,0,0),

   PICT_g1 =		PICT_FORMAT(1,PICT_TYPE_GRAY,0,0,0,0),
} PictFormatShort;

void dump_mem();
