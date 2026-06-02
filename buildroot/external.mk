# included automatically by buildroot when BR2_EXTERNAL points here.
# add custom package .mk files here when packages are added under package/.
include $(sort $(wildcard $(BR2_EXTERNAL_TIERHIVE_PATH)/package/*/*.mk))
