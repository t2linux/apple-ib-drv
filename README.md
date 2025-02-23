Work in progress driver for the touchbar and ambient-light-sensor on 2019 MacBook Pro's.

------------------------
The information provided here is for general informational purposes only. While I strive to ensure the accuracy and reliability of the information, I make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability, or availability of the information, products, services, or related graphics provided. Any reliance you place on such information is strictly at your own risk.

In no event will I be liable for any loss or damage, including without limitation, indirect or consequential loss or damage, or any loss or damage whatsoever arising from the use of, or reliance on, this information. This includes, but is not limited to, technical issues, data loss, system failures, or any other problems that may arise from following the advice or instructions provided.

You are solely responsible for your actions and decisions. Always exercise caution and consult with a qualified professional if you are unsure about any steps or procedures. By using this information, you agree to hold me harmless from any and all claims, liabilities, or damages that may result from your use of the information provided.

This disclaimer applies to the fullest extent permitted by law.
------------------------

Building and Installing on Arch Linux / CachyOS:
------------------------
```
# setup / install pre-reqs
sudo pacman -S lld                                      
sudo pacman -S clang

git clone https://github.com/vallamost/apple-ib-drv-arch-linux-support.git
cd apple-ib-drv-arch-linux-support
make CC=clang LD=ld.lld
sudo modprobe industrialio_triggered_buffer
sudo insmod apple-ibridge.ko
sudo insmod apple-touchbar.ko
```

Touchbar/ALS/iBridge:
---------------------
The touchbar and ambient-light-sensor (ALS) are part of the iBridge (T2) chip, and hence there are 3 modules corresponding to these (`apple_ibridge`, `apple_ib_tb`, and `apple_ib_als`). Generally loading any one of these will load the others, unless you are loading them via `insmod`. If loading manually (i.e. via `insmod`), you need to first load the `industrialio_triggered_buffer` and `apple_ibridge` modules.

The touchbar driver provides basic touchbar functionality (enabling the touchbar and switching between modes based on the FN key). The touchbar is automatically dimmed and later switched off if no (internal) keyboard, touchpad, or touchbar input is received for a period of time; any (internal) keyboard, touchpad, or touchbar input switches it back on. The timeouts till the touchbar is dimmed and turned off can be changed via the `idle_timeout` and `dim_timeout` module params or sysfs attributes (`/sys/class/input/input9/device/...`); they default to 5 min and 4.5 min, respectively. See also `modinfo apple_ib_tb`.

The ALS driver exposes the ambient light sensor; if you have the `iio-sensor-proxy` installed then it should be recognized and handled automatically.

