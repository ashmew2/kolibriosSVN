/*
 * Copyright 2008 Advanced Micro Devices, Inc.
 * Copyright 2008 Red Hat Inc.
 * Copyright 2009 Jerome Glisse.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Authors: Dave Airlie
 *          Alex Deucher
 *          Jerome Glisse
 */
//#include <linux/console.h>

#include <drm/drmP.h>
#include <drm/drm_crtc_helper.h>
#include <drm/radeon_drm.h>
#include "radeon_reg.h"
#include "radeon.h"
#include "radeon_asic.h"
#include "atom.h"

#include <drm/drm_pciids.h>


int radeon_dynclks = -1;
int radeon_r4xx_atom = 0;
int radeon_agpmode   = -1;
int radeon_gart_size = 512; /* default gart size */
int radeon_benchmarking = 0;
int radeon_connector_table = 0;
int radeon_tv = 0;

void parse_cmdline(char *cmdline, mode_t *mode, char *log);
int init_display(struct radeon_device *rdev, mode_t *mode);

 /* Legacy VGA regions */
#define VGA_RSRC_NONE          0x00
#define VGA_RSRC_LEGACY_IO     0x01
#define VGA_RSRC_LEGACY_MEM    0x02
#define VGA_RSRC_LEGACY_MASK   (VGA_RSRC_LEGACY_IO | VGA_RSRC_LEGACY_MEM)
/* Non-legacy access */
#define VGA_RSRC_NORMAL_IO     0x04
#define VGA_RSRC_NORMAL_MEM    0x08



/*
 * Clear GPU surface registers.
 */
void radeon_surface_init(struct radeon_device *rdev)
{
    ENTER();

    /* FIXME: check this out */
    if (rdev->family < CHIP_R600) {
        int i;

        for (i = 0; i < 8; i++) {
            WREG32(RADEON_SURFACE0_INFO +
                   i * (RADEON_SURFACE1_INFO - RADEON_SURFACE0_INFO),
                   0);
        }
		/* enable surfaces */
		WREG32(RADEON_SURFACE_CNTL, 0);
    }
}

/*
 * GPU scratch registers helpers function.
 */
void radeon_scratch_init(struct radeon_device *rdev)
{
    int i;

    /* FIXME: check this out */
    if (rdev->family < CHIP_R300) {
        rdev->scratch.num_reg = 5;
    } else {
        rdev->scratch.num_reg = 7;
    }
    for (i = 0; i < rdev->scratch.num_reg; i++) {
        rdev->scratch.free[i] = true;
        rdev->scratch.reg[i] = RADEON_SCRATCH_REG0 + (i * 4);
    }
}

int radeon_scratch_get(struct radeon_device *rdev, uint32_t *reg)
{
	int i;

	for (i = 0; i < rdev->scratch.num_reg; i++) {
		if (rdev->scratch.free[i]) {
			rdev->scratch.free[i] = false;
			*reg = rdev->scratch.reg[i];
			return 0;
		}
	}
	return -EINVAL;
}

void radeon_scratch_free(struct radeon_device *rdev, uint32_t reg)
{
	int i;

	for (i = 0; i < rdev->scratch.num_reg; i++) {
		if (rdev->scratch.reg[i] == reg) {
			rdev->scratch.free[i] = true;
			return;
		}
	}
}

/*
 * MC common functions
 */
int radeon_mc_setup(struct radeon_device *rdev)
{
	uint32_t tmp;

	/* Some chips have an "issue" with the memory controller, the
	 * location must be aligned to the size. We just align it down,
	 * too bad if we walk over the top of system memory, we don't
	 * use DMA without a remapped anyway.
	 * Affected chips are rv280, all r3xx, and all r4xx, but not IGP
	 */
	/* FGLRX seems to setup like this, VRAM a 0, then GART.
	 */
	/*
	 * Note: from R6xx the address space is 40bits but here we only
	 * use 32bits (still have to see a card which would exhaust 4G
	 * address space).
	 */
	if (rdev->mc.vram_location != 0xFFFFFFFFUL) {
		/* vram location was already setup try to put gtt after
		 * if it fits */
		tmp = rdev->mc.vram_location + rdev->mc.mc_vram_size;
		tmp = (tmp + rdev->mc.gtt_size - 1) & ~(rdev->mc.gtt_size - 1);
		if ((0xFFFFFFFFUL - tmp) >= rdev->mc.gtt_size) {
			rdev->mc.gtt_location = tmp;
		} else {
			if (rdev->mc.gtt_size >= rdev->mc.vram_location) {
				printk(KERN_ERR "[drm] GTT too big to fit "
				       "before or after vram location.\n");
				return -EINVAL;
			}
			rdev->mc.gtt_location = 0;
		}
	} else if (rdev->mc.gtt_location != 0xFFFFFFFFUL) {
		/* gtt location was already setup try to put vram before
		 * if it fits */
		if (rdev->mc.mc_vram_size < rdev->mc.gtt_location) {
			rdev->mc.vram_location = 0;
		} else {
			tmp = rdev->mc.gtt_location + rdev->mc.gtt_size;
			tmp += (rdev->mc.mc_vram_size - 1);
			tmp &= ~(rdev->mc.mc_vram_size - 1);
			if ((0xFFFFFFFFUL - tmp) >= rdev->mc.mc_vram_size) {
				rdev->mc.vram_location = tmp;
			} else {
				printk(KERN_ERR "[drm] vram too big to fit "
				       "before or after GTT location.\n");
				return -EINVAL;
			}
		}
	} else {
		rdev->mc.vram_location = 0;
		tmp = rdev->mc.mc_vram_size;
		tmp = (tmp + rdev->mc.gtt_size - 1) & ~(rdev->mc.gtt_size - 1);
		rdev->mc.gtt_location = tmp;
	}
	rdev->mc.vram_start = rdev->mc.vram_location;
	rdev->mc.vram_end = rdev->mc.vram_location + rdev->mc.mc_vram_size - 1;
	rdev->mc.gtt_start = rdev->mc.gtt_location;
	rdev->mc.gtt_end = rdev->mc.gtt_location + rdev->mc.gtt_size - 1;
	DRM_INFO("radeon: VRAM %uM\n", (unsigned)(rdev->mc.mc_vram_size >> 20));
	DRM_INFO("radeon: VRAM from 0x%08X to 0x%08X\n",
		 (unsigned)rdev->mc.vram_location,
		 (unsigned)(rdev->mc.vram_location + rdev->mc.mc_vram_size - 1));
	DRM_INFO("radeon: GTT %uM\n", (unsigned)(rdev->mc.gtt_size >> 20));
	DRM_INFO("radeon: GTT from 0x%08X to 0x%08X\n",
		 (unsigned)rdev->mc.gtt_location,
		 (unsigned)(rdev->mc.gtt_location + rdev->mc.gtt_size - 1));
	return 0;
}


/*
 * GPU helpers function.
 */
bool radeon_card_posted(struct radeon_device *rdev)
{
	uint32_t reg;

    ENTER();

	/* first check CRTCs */
	if (ASIC_IS_AVIVO(rdev)) {
		reg = RREG32(AVIVO_D1CRTC_CONTROL) |
		      RREG32(AVIVO_D2CRTC_CONTROL);
		if (reg & AVIVO_CRTC_EN) {
			return true;
		}
	} else {
		reg = RREG32(RADEON_CRTC_GEN_CNTL) |
		      RREG32(RADEON_CRTC2_GEN_CNTL);
		if (reg & RADEON_CRTC_EN) {
			return true;
		}
	}

	/* then check MEM_SIZE, in case the crtcs are off */
	if (rdev->family >= CHIP_R600)
		reg = RREG32(R600_CONFIG_MEMSIZE);
	else
		reg = RREG32(RADEON_CONFIG_MEMSIZE);

	if (reg)
		return true;

	return false;

}

int radeon_dummy_page_init(struct radeon_device *rdev)
{
    rdev->dummy_page.page = AllocPage();
	if (rdev->dummy_page.page == NULL)
		return -ENOMEM;
    rdev->dummy_page.addr = MapIoMem(rdev->dummy_page.page, 4096, 5);
	if (!rdev->dummy_page.addr) {
//       __free_page(rdev->dummy_page.page);
		rdev->dummy_page.page = NULL;
		return -ENOMEM;
	}
	return 0;
}

void radeon_dummy_page_fini(struct radeon_device *rdev)
{
	if (rdev->dummy_page.page == NULL)
		return;
    KernelFree(rdev->dummy_page.addr);
	rdev->dummy_page.page = NULL;
}


/*
 * Registers accessors functions.
 */
uint32_t radeon_invalid_rreg(struct radeon_device *rdev, uint32_t reg)
{
    DRM_ERROR("Invalid callback to read register 0x%04X\n", reg);
    BUG_ON(1);
    return 0;
}

void radeon_invalid_wreg(struct radeon_device *rdev, uint32_t reg, uint32_t v)
{
    DRM_ERROR("Invalid callback to write register 0x%04X with 0x%08X\n",
          reg, v);
    BUG_ON(1);
}

void radeon_register_accessor_init(struct radeon_device *rdev)
{
    rdev->mc_rreg = &radeon_invalid_rreg;
    rdev->mc_wreg = &radeon_invalid_wreg;
    rdev->pll_rreg = &radeon_invalid_rreg;
    rdev->pll_wreg = &radeon_invalid_wreg;
    rdev->pciep_rreg = &radeon_invalid_rreg;
    rdev->pciep_wreg = &radeon_invalid_wreg;

    /* Don't change order as we are overridding accessor. */
    if (rdev->family < CHIP_RV515) {
		rdev->pcie_reg_mask = 0xff;
	} else {
		rdev->pcie_reg_mask = 0x7ff;
    }
    /* FIXME: not sure here */
    if (rdev->family <= CHIP_R580) {
        rdev->pll_rreg = &r100_pll_rreg;
        rdev->pll_wreg = &r100_pll_wreg;
    }
	if (rdev->family >= CHIP_R420) {
		rdev->mc_rreg = &r420_mc_rreg;
		rdev->mc_wreg = &r420_mc_wreg;
	}
    if (rdev->family >= CHIP_RV515) {
        rdev->mc_rreg = &rv515_mc_rreg;
        rdev->mc_wreg = &rv515_mc_wreg;
    }
    if (rdev->family == CHIP_RS400 || rdev->family == CHIP_RS480) {
        rdev->mc_rreg = &rs400_mc_rreg;
        rdev->mc_wreg = &rs400_mc_wreg;
    }
    if (rdev->family == CHIP_RS690 || rdev->family == CHIP_RS740) {
        rdev->mc_rreg = &rs690_mc_rreg;
        rdev->mc_wreg = &rs690_mc_wreg;
    }
    if (rdev->family == CHIP_RS600) {
        rdev->mc_rreg = &rs600_mc_rreg;
        rdev->mc_wreg = &rs600_mc_wreg;
    }
	if (rdev->family >= CHIP_R600) {
		rdev->pciep_rreg = &r600_pciep_rreg;
		rdev->pciep_wreg = &r600_pciep_wreg;
	}
}


/*
 * ASIC
 */
int radeon_asic_init(struct radeon_device *rdev)
{
    radeon_register_accessor_init(rdev);
	switch (rdev->family) {
	case CHIP_R100:
	case CHIP_RV100:
	case CHIP_RS100:
	case CHIP_RV200:
	case CHIP_RS200:
	case CHIP_R200:
	case CHIP_RV250:
	case CHIP_RS300:
	case CHIP_RV280:
        rdev->asic = &r100_asic;
		break;
	case CHIP_R300:
	case CHIP_R350:
	case CHIP_RV350:
	case CHIP_RV380:
        rdev->asic = &r300_asic;
		if (rdev->flags & RADEON_IS_PCIE) {
			rdev->asic->gart_tlb_flush = &rv370_pcie_gart_tlb_flush;
			rdev->asic->gart_set_page = &rv370_pcie_gart_set_page;
		}
		break;
	case CHIP_R420:
	case CHIP_R423:
	case CHIP_RV410:
        rdev->asic = &r420_asic;
		break;
	case CHIP_RS400:
	case CHIP_RS480:
       rdev->asic = &rs400_asic;
		break;
	case CHIP_RS600:
        rdev->asic = &rs600_asic;
		break;
	case CHIP_RS690:
	case CHIP_RS740:
        rdev->asic = &rs690_asic;
		break;
	case CHIP_RV515:
        rdev->asic = &rv515_asic;
		break;
	case CHIP_R520:
	case CHIP_RV530:
	case CHIP_RV560:
	case CHIP_RV570:
	case CHIP_R580:
        rdev->asic = &r520_asic;
		break;
	case CHIP_R600:
	case CHIP_RV610:
	case CHIP_RV630:
	case CHIP_RV620:
	case CHIP_RV635:
	case CHIP_RV670:
	case CHIP_RS780:
	case CHIP_RS880:
		rdev->asic = &r600_asic;
		break;
	case CHIP_RV770:
	case CHIP_RV730:
	case CHIP_RV710:
	case CHIP_RV740:
		rdev->asic = &rv770_asic;
		break;
	default:
		/* FIXME: not supported yet */
		return -EINVAL;
	}
	return 0;
}


/*
 * Wrapper around modesetting bits.
 */
int radeon_clocks_init(struct radeon_device *rdev)
{
	int r;

    ENTER();

    r = radeon_static_clocks_init(rdev->ddev);
	if (r) {
		return r;
	}
	DRM_INFO("Clocks initialized !\n");
	return 0;
}

void radeon_clocks_fini(struct radeon_device *rdev)
{
}

/* ATOM accessor methods */
static uint32_t cail_pll_read(struct card_info *info, uint32_t reg)
{
    struct radeon_device *rdev = info->dev->dev_private;
    uint32_t r;

    r = rdev->pll_rreg(rdev, reg);
    return r;
}

static void cail_pll_write(struct card_info *info, uint32_t reg, uint32_t val)
{
    struct radeon_device *rdev = info->dev->dev_private;

    rdev->pll_wreg(rdev, reg, val);
}

static uint32_t cail_mc_read(struct card_info *info, uint32_t reg)
{
    struct radeon_device *rdev = info->dev->dev_private;
    uint32_t r;

    r = rdev->mc_rreg(rdev, reg);
    return r;
}

static void cail_mc_write(struct card_info *info, uint32_t reg, uint32_t val)
{
    struct radeon_device *rdev = info->dev->dev_private;

    rdev->mc_wreg(rdev, reg, val);
}

static void cail_reg_write(struct card_info *info, uint32_t reg, uint32_t val)
{
    struct radeon_device *rdev = info->dev->dev_private;

    WREG32(reg*4, val);
}

static uint32_t cail_reg_read(struct card_info *info, uint32_t reg)
{
    struct radeon_device *rdev = info->dev->dev_private;
    uint32_t r;

    r = RREG32(reg*4);
    return r;
}

static struct card_info atom_card_info = {
    .dev = NULL,
    .reg_read = cail_reg_read,
    .reg_write = cail_reg_write,
    .mc_read = cail_mc_read,
    .mc_write = cail_mc_write,
    .pll_read = cail_pll_read,
    .pll_write = cail_pll_write,
};

int radeon_atombios_init(struct radeon_device *rdev)
{
    ENTER();

    atom_card_info.dev = rdev->ddev;
    rdev->mode_info.atom_context = atom_parse(&atom_card_info, rdev->bios);
    radeon_atom_initialize_bios_scratch_regs(rdev->ddev);
    return 0;
}

void radeon_atombios_fini(struct radeon_device *rdev)
{
	kfree(rdev->mode_info.atom_context);
}

int radeon_combios_init(struct radeon_device *rdev)
{
	radeon_combios_initialize_bios_scratch_regs(rdev->ddev);
	return 0;
}

void radeon_combios_fini(struct radeon_device *rdev)
{
}

/* if we get transitioned to only one device, tak VGA back */
static unsigned int radeon_vga_set_decode(void *cookie, bool state)
{
	struct radeon_device *rdev = cookie;
	radeon_vga_set_state(rdev, state);
	if (state)
		return VGA_RSRC_LEGACY_IO | VGA_RSRC_LEGACY_MEM |
		       VGA_RSRC_NORMAL_IO | VGA_RSRC_NORMAL_MEM;
	else
		return VGA_RSRC_NORMAL_IO | VGA_RSRC_NORMAL_MEM;
}

void radeon_agp_disable(struct radeon_device *rdev)
{
	rdev->flags &= ~RADEON_IS_AGP;
	if (rdev->family >= CHIP_R600) {
		DRM_INFO("Forcing AGP to PCIE mode\n");
		rdev->flags |= RADEON_IS_PCIE;
	} else if (rdev->family >= CHIP_RV515 ||
			rdev->family == CHIP_RV380 ||
			rdev->family == CHIP_RV410 ||
			rdev->family == CHIP_R423) {
		DRM_INFO("Forcing AGP to PCIE mode\n");
		rdev->flags |= RADEON_IS_PCIE;
		rdev->asic->gart_tlb_flush = &rv370_pcie_gart_tlb_flush;
		rdev->asic->gart_set_page = &rv370_pcie_gart_set_page;
	} else {
		DRM_INFO("Forcing AGP to PCI mode\n");
		rdev->flags |= RADEON_IS_PCI;
		rdev->asic->gart_tlb_flush = &r100_pci_gart_tlb_flush;
		rdev->asic->gart_set_page = &r100_pci_gart_set_page;
	}
}

/*
 * Radeon device.
 */
int radeon_device_init(struct radeon_device *rdev,
               struct drm_device *ddev,
               struct pci_dev *pdev,
               uint32_t flags)
{
	int r;
	int dma_bits;

    ENTER();

    DRM_INFO("radeon: Initializing kernel modesetting.\n");
    rdev->shutdown = false;
    rdev->ddev = ddev;
    rdev->pdev = pdev;
    rdev->flags = flags;
    rdev->family = flags & RADEON_FAMILY_MASK;
    rdev->is_atom_bios = false;
    rdev->usec_timeout = RADEON_MAX_USEC_TIMEOUT;
    rdev->mc.gtt_size = radeon_gart_size * 1024 * 1024;
    rdev->gpu_lockup = false;
	rdev->accel_working = false;
    /* mutex initialization are all done here so we
     * can recall function without having locking issues */
 //   mutex_init(&rdev->cs_mutex);
 //   mutex_init(&rdev->ib_pool.mutex);
 //   mutex_init(&rdev->cp.mutex);
 //   rwlock_init(&rdev->fence_drv.lock);

	/* Set asic functions */
	r = radeon_asic_init(rdev);
	if (r) {
		return r;
	}

    if (radeon_agpmode == -1) {
		radeon_agp_disable(rdev);
    }

	/* set DMA mask + need_dma32 flags.
	 * PCIE - can handle 40-bits.
	 * IGP - can handle 40-bits (in theory)
	 * AGP - generally dma32 is safest
	 * PCI - only dma32
	 */
	rdev->need_dma32 = false;
	if (rdev->flags & RADEON_IS_AGP)
		rdev->need_dma32 = true;
	if (rdev->flags & RADEON_IS_PCI)
		rdev->need_dma32 = true;

	dma_bits = rdev->need_dma32 ? 32 : 40;
	r = pci_set_dma_mask(rdev->pdev, DMA_BIT_MASK(dma_bits));
    if (r) {
        printk(KERN_WARNING "radeon: No suitable DMA available.\n");
    }

    /* Registers mapping */
    /* TODO: block userspace mapping of io register */
    rdev->rmmio_base = pci_resource_start(rdev->pdev, 2);

    rdev->rmmio_size = pci_resource_len(rdev->pdev, 2);

    rdev->rmmio =  (void*)MapIoMem(rdev->rmmio_base, rdev->rmmio_size,
                                   PG_SW+PG_NOCACHE);

    if (rdev->rmmio == NULL) {
        return -ENOMEM;
    }
    DRM_INFO("register mmio base: 0x%08X\n", (uint32_t)rdev->rmmio_base);
    DRM_INFO("register mmio size: %u\n", (unsigned)rdev->rmmio_size);

	/* if we have > 1 VGA cards, then disable the radeon VGA resources */
//	r = vga_client_register(rdev->pdev, rdev, NULL, radeon_vga_set_decode);
//	if (r) {
//		return -EINVAL;
//	}

	r = radeon_init(rdev);
	if (r)
            return r;

	if (rdev->flags & RADEON_IS_AGP && !rdev->accel_working) {
		/* Acceleration not working on AGP card try again
		 * with fallback to PCI or PCIE GART
		 */
		radeon_gpu_reset(rdev);
		radeon_fini(rdev);
		radeon_agp_disable(rdev);
		r = radeon_init(rdev);
		if (r)
		return r;
	}
//	if (radeon_testing) {
//		radeon_test_moves(rdev);
//    }
//	if (radeon_benchmarking) {
//		radeon_benchmark(rdev);
//    }
	return 0;
}


static struct pci_device_id pciidlist[] = {
    radeon_PCI_IDS
};

mode_t usermode;
char   log[256];

u32_t drvEntry(int action, char *cmdline)
{
    struct pci_device_id  *ent;

    dev_t   device;
    int     err;
    u32_t   retval = 0;

    if(action != 1)
        return 0;

    if( cmdline && *cmdline )
        parse_cmdline(cmdline, &usermode, log);

    if(!dbg_open(log))
    {
        strcpy(log, "/rd/1/drivers/atikms.log");

        if(!dbg_open(log))
    {
            printf("Can't open %s\nExit\n", log);
        return 0;
        };
    }

    enum_pci_devices();

    ent = find_pci_device(&device, pciidlist);

    if( unlikely(ent == NULL) )
    {
        dbgprintf("device not found\n");
        return 0;
    };

    dbgprintf("device %x:%x\n", device.pci_dev.vendor,
                                device.pci_dev.device);

    err = drm_get_dev(&device.pci_dev, ent);

    return retval;
};



/*
 * Driver load/unload
 */
int radeon_driver_load_kms(struct drm_device *dev, unsigned long flags)
{
    struct radeon_device *rdev;
    int r;

    ENTER();

    rdev = kzalloc(sizeof(struct radeon_device), GFP_KERNEL);
    if (rdev == NULL) {
        return -ENOMEM;
    };

    dev->dev_private = (void *)rdev;

    /* update BUS flag */
//    if (drm_device_is_agp(dev)) {
        flags |= RADEON_IS_AGP;
//    } else if (drm_device_is_pcie(dev)) {
//        flags |= RADEON_IS_PCIE;
//    } else {
//        flags |= RADEON_IS_PCI;
//    }

    /* radeon_device_init should report only fatal error
     * like memory allocation failure or iomapping failure,
     * or memory manager initialization failure, it must
     * properly initialize the GPU MC controller and permit
     * VRAM allocation
     */
    r = radeon_device_init(rdev, dev, dev->pdev, flags);
    if (r) {
        DRM_ERROR("Fatal error while trying to initialize radeon.\n");
        return r;
    }
    /* Again modeset_init should fail only on fatal error
     * otherwise it should provide enough functionalities
     * for shadowfb to run
     */
    r = radeon_modeset_init(rdev);
    if (r) {
        return r;
    }
    return 0;
}


int drm_get_dev(struct pci_dev *pdev, const struct pci_device_id *ent)
{
    struct drm_device *dev;
    int ret;

    ENTER();

    dev = malloc(sizeof(*dev));
    if (!dev)
        return -ENOMEM;

 //   ret = pci_enable_device(pdev);
 //   if (ret)
 //       goto err_g1;

 //   pci_set_master(pdev);

 //   if ((ret = drm_fill_in_dev(dev, pdev, ent, driver))) {
 //       printk(KERN_ERR "DRM: Fill_in_dev failed.\n");
 //       goto err_g2;
 //   }

    dev->pdev = pdev;
    dev->pci_device = pdev->device;
    dev->pci_vendor = pdev->vendor;

    ret = radeon_driver_load_kms(dev, ent->driver_data );
    if (ret)
        goto err_g4;

 //   list_add_tail(&dev->driver_item, &driver->device_list);

 //   DRM_INFO("Initialized %s %d.%d.%d %s for %s on minor %d\n",
 //        driver->name, driver->major, driver->minor, driver->patchlevel,
 //        driver->date, pci_name(pdev), dev->primary->index);

    init_display(dev->dev_private, &usermode);

    LEAVE();

    return 0;

err_g4:
//    drm_put_minor(&dev->primary);
//err_g3:
//    if (drm_core_check_feature(dev, DRIVER_MODESET))
//        drm_put_minor(&dev->control);
//err_g2:
//    pci_disable_device(pdev);
//err_g1:
    free(dev);

    LEAVE();

    return ret;
}

resource_size_t drm_get_resource_start(struct drm_device *dev, unsigned int resource)
{
    return pci_resource_start(dev->pdev, resource);
}

resource_size_t drm_get_resource_len(struct drm_device *dev, unsigned int resource)
{
    return pci_resource_len(dev->pdev, resource);
}


uint32_t __div64_32(uint64_t *n, uint32_t base)
{
        uint64_t rem = *n;
        uint64_t b = base;
        uint64_t res, d = 1;
        uint32_t high = rem >> 32;

        /* Reduce the thing a bit first */
        res = 0;
        if (high >= base) {
                high /= base;
                res = (uint64_t) high << 32;
                rem -= (uint64_t) (high*base) << 32;
        }

        while ((int64_t)b > 0 && b < rem) {
                b = b+b;
                d = d+d;
        }

        do {
                if (rem >= b) {
                        rem -= b;
                        res += d;
                }
                b >>= 1;
                d >>= 1;
        } while (d);

        *n = res;
        return rem;
}

