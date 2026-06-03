# tierhive buildroot project
#
# usage:
#   make base          build the minimal base vps image
#   make fetch         download buildroot source only
#   make menuconfig    open buildroot menuconfig (base target)
#   make linux-menuconfig  open kernel menuconfig (base target)
#   make saveconfig    write running config back to defconfig
#   make clean         remove build output
#   make distclean     remove output and downloaded buildroot source

BUILDROOT_VERSION := 2024.02.9
BUILDROOT_TARBALL := buildroot-$(BUILDROOT_VERSION).tar.gz
BUILDROOT_URL     := https://buildroot.org/downloads/$(BUILDROOT_TARBALL)
BUILDROOT_SRC     := $(CURDIR)/buildroot-src
OUTPUT_DIR        := $(CURDIR)/output
BR2_EXTERNAL      := $(CURDIR)

.PHONY: all base fetch menuconfig linux-menuconfig saveconfig clean distclean help

all: base

# download and unpack buildroot if not already present
fetch:
	@if [ ! -d "$(BUILDROOT_SRC)" ]; then \
		echo "fetching buildroot $(BUILDROOT_VERSION)..."; \
		wget -q "$(BUILDROOT_URL)" -O /tmp/$(BUILDROOT_TARBALL); \
		tar -xf /tmp/$(BUILDROOT_TARBALL); \
		mv buildroot-$(BUILDROOT_VERSION) buildroot-src; \
		rm /tmp/$(BUILDROOT_TARBALL); \
		echo "done."; \
	else \
		echo "buildroot-src already present, skipping fetch."; \
	fi

# build the base vps image
base: fetch
	mkdir -p $(OUTPUT_DIR)/base
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_base_defconfig
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base

# build the wireguard vps image (base + wireguard kernel module + wireguard-tools)
wireguard: fetch
	mkdir -p $(OUTPUT_DIR)/wireguard
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/wireguard \
		BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_wireguard_defconfig
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/wireguard

# future service targets follow the same pattern:
#
#   frp: fetch
#       mkdir -p $(OUTPUT_DIR)/frp
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/frp \
#           BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_frp_defconfig
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/frp
#
#   nginx: fetch
#       mkdir -p $(OUTPUT_DIR)/nginx
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/nginx \
#           BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_nginx_defconfig
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/nginx

# open buildroot menuconfig for the base target
menuconfig: fetch
	mkdir -p $(OUTPUT_DIR)/base
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base \
		BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_base_defconfig
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base menuconfig

# open kernel menuconfig for the base target
linux-menuconfig: fetch
	mkdir -p $(OUTPUT_DIR)/base
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base \
		BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_base_defconfig
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base linux-menuconfig

# save the running config back to our defconfig file
saveconfig: fetch
	$(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/base \
		BR2_EXTERNAL=$(BR2_EXTERNAL) savedefconfig \
		BR2_DEFCONFIG=$(BR2_EXTERNAL)/configs/tierhive_base_defconfig

# future service targets will follow this same pattern, for example:
#
#   wireguard: fetch
#       mkdir -p $(OUTPUT_DIR)/wireguard
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/wireguard \
#           BR2_EXTERNAL=$(BR2_EXTERNAL) tierhive_wireguard_defconfig
#       $(MAKE) -C $(BUILDROOT_SRC) O=$(OUTPUT_DIR)/wireguard

clean:
	rm -rf $(OUTPUT_DIR)

distclean: clean
	rm -rf $(BUILDROOT_SRC)

help:
	@echo ""
	@echo "tierhive buildroot project"
	@echo ""
	@echo "  make base              build the base vps image"
	@echo "  make fetch             download buildroot source only"
	@echo "  make menuconfig        open buildroot menuconfig (base)"
	@echo "  make linux-menuconfig  open kernel menuconfig (base)"
	@echo "  make saveconfig        save config back to defconfig"
	@echo "  make clean             remove output directory"
	@echo "  make distclean         remove output and buildroot source"
	@echo ""
