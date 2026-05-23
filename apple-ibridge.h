/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Apple iBridge Driver
 *
 * Copyright (c) 2018 Ronald Tschalär
 */

#ifndef __LINUX_APPLE_IBRDIGE_H
#define __LINUX_APPLE_IBRDIGE_H

#define USB_VENDOR_ID_LINUX_FOUNDATION	0x1d6b
#define USB_DEVICE_ID_IBRIDGE_TB	0x0301
#define USB_DEVICE_ID_IBRIDGE_ALS	0x0302

/* Minimal IDs needed by this out-of-tree driver set. */
#define USB_VENDOR_ID_APPLE		0x05ac
#define USB_DEVICE_ID_APPLE_IBRIDGE	0x8600
#define USB_DEVICE_ID_APPLE_TOUCHBAR_BACKLIGHT 0x8102
#define USB_DEVICE_ID_APPLE_TOUCHBAR_DISPLAY	0x8302

#endif
