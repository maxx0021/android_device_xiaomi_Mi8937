#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib64/lib_fpc_tac_shared.so)
            if ! "${PATCHELF}" --print-needed "${2}" | grep "libshims_binder.so" >/dev/null; then
                "${PATCHELF}" --add-needed "libshims_binder.so" "${2}"
            fi
            ;;
        vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so)
            "${PATCHELF_0_8}" --remove-needed "libprotobuf-cpp-lite.so" "${2}"
            ;;
        vendor/lib/libmmsw_platform.so|vendor/lib/libmmsw_detail_enhancement.so)
            "${PATCHELF}" --remove-needed "libbinder.so" "${2}"
            sed -i 's|libgui.so|libwui.so|g' "${2}"
            ;;
        vendor/lib/libmmcamera2_sensor_modules.so)
            sed -i 's|/system/etc/camera/|/vendor/etc/camera/|g' "${2}"
            sed -i 's|data/misc/camera|data/vendor/qcam|g' "${2}"
            ;;
        vendor/lib/libmmcamera_tintless_bg_pca_algo.so \
        |vendor/lib/libmmcamera_pdafcamif.so \
        |vendor/lib/libmmcamera2_dcrf.so \
        |vendor/lib/libmmcamera_imglib.so \
        |vendor/lib/libmmcamera_dbg.so \
        |vendor/lib/libmmcamera2_stats_algorithm.so \
        |vendor/lib/libmmcamera2_mct.so \
        |vendor/lib/libmmcamera_tuning.so \
        |vendor/lib/libmmcamera_tintless_algo.so \
        |vendor/lib/libmmcamera2_iface_modules.so \
        |vendor/lib/libmmcamera2_q3a_core.so \
        |vendor/lib/libmmcamera2_pproc_modules.so \
        |vendor/lib/libmmcamera2_imglib_modules.so \
        |vendor/lib/libmmcamera2_cpp_module.so \
        |vendor/lib/libmmcamera_pdaf.so \
        |vendor/bin/wingtech_mm-qcamera-daemon)
            sed -i 's|data/misc/camera|data/vendor/qcam|g' "${2}"
            ;;
        vendor/lib/libmmcamera2_stats_modules.so)
            sed -i 's|data/misc/camera|data/vendor/qcam|g' "${2}"
            sed -i 's|libgui.so|libwui.so|g' "${2}"
            "${PATCHELF}" --replace-needed "libandroid.so" "libshims_android.so" "${2}"
            ;;
        vendor/lib/libmmcamera_ppeiscore.so)
            sed -i 's|libgui.so|libwui.so|g' "${2}"
            if ! "${PATCHELF}" --print-needed "${2}" | grep "libshims_ui.so" >/dev/null; then
                "${PATCHELF}" --add-needed "libshims_ui.so" "${2}"
            fi
            ;;
        vendor/lib/libmpbase.so)
            "${PATCHELF}" --replace-needed "libandroid.so" "libshims_android.so" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=Mi8937_4_19
export DEVICE_PARENT=Mi8937
export DEVICE_COMMON=mithorium-common
export VENDOR=xiaomi

MY_DIR="$(cd "$(dirname "${0}")"; pwd -P)"

"${MY_DIR}/../../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "--kernel-4.19" "$@"
