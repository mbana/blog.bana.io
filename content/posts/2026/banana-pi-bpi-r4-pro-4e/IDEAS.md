# `IDEAS`

## Docker container/image to make an OpenWRT build

Firstly, thanks for at least trying to make things open source and publishing the code to GitHub, both are better than nothing.

**How do I go about building <https://github.com/BPI-SINOVOIP/BPI-R4PRO-4E-OPENWRT-V24.10.0-Master-Devel> and generating something (images) which I can then flash to a micro SD card?** There isn't any information on how to go about doing this I'm afraid.

What I think most people want is a set of instructions to use Docker or Podman to generate the various images:

1. `BPI-R4Pro-4E-BE14-MT76-OpenWRT24.10-emmc-260325`.
2. `BPI-R4Pro-4E-BE14-MT76-OpenWRT24.10-sdcard-260325`.
3. `BPI-R4Pro-4E-BE14-MT76-OpenWRT24.10-snand-260325`.

Just by a. checking out <https://github.com/BPI-SINOVOIP/BPI-R4PRO-4E-OPENWRT-V24.10.0-Master-Devel>, b. installing Docker/Podman, c. running the commands as documented in <https://github.com/openwrt/docker#imagebuilder-tags>. For instance:

```sh
$ git clone https://github.com/BPI-SINOVOIP/BPI-R4PRO-4E-OPENWRT-V24.10.0-Master-Devel.git
$ cd BPI-R4PRO-4E-OPENWRT-V24.10.0-Master-Devel
$ docker run --rm -v "$(pwd)"/bin/:/builder/bin -it openwrt/imagebuilder
# inside the Docker container
[ ! -d ./scripts ] && ./setup.sh
make image PROFILE=generic PACKAGES=tmate
exit
# Flash the image generated from the step above.
$ sudo dd status=progress if="$(pwd)"/bin/<FILE>" of=/dev/<BLOCK_DEV>
```

**Simple. Does it really need to be more complicated?**

---

### Questions

1. Does anyone know how to figure out what is different from upstream OpenWRT and <https://github.com/BPI-SINOVOIP/BPI-R4PRO-4E-OPENWRT-V24.10.0-Master-Devel>? Again, this is another one of those things that doesn't make sense to me, or that I'm simply missing something, but why was this repository not just forked from OpenWRT so everyone could see what is really happening in the repository. Again, I'm sure there must be some justification for it but this seems really odd.
2. I want to switch to 10G SFP WAN port without entering `uboot` as documented in <https://docs.banana-pi.org/en/BPI-R4_Pro/GettingStarted_BPI-R4_Pro#_r4pro_4e_switchable_combo_network_port>. How can I do this without using the serial console?
3. Does the `BPI-R4 Pro WiFi7 Router Complete Assembly Package`, <https://www.bpi-shop.com/products/bpi-r4-pro-complete-assembly-package.html>, come with a default factory image? If so, what exactly is flashed on there?

Many thanks!

\- Bana (reach out to me at m@bana.io if you want to collaborate on anything)

---

Stop `css/custom.css` from being minified

According to the code in <https://github.com/imfing/hextra/blob/fb994d6b1c4f78ffd4443815fa5bfad3918a4911/layouts/_partials/head.html#L37> the `custom.css` is being minified:

```html
{{- $customCss := resources.Get "css/custom.css" -}}
...
{{- $styles := slice $variablesCss $mainCss $customCss | resources.Concat "css/compiled/main.css" | minify | fingerprint }}
```

Which causes problems for me, such as removing quotes and quotations around the font name, see the attached `main.min.css` or have a look at <https://blog.bana.io/css/compiled/main.min.0b7294c9218078e1942fef869b2cabac4f1693df1bee0ac4958efe1f3116fa3b.css> (if I have not pushed a new commit). How do I stop this from happening? It seems like the call to `minify` in the pipeline needs to be conditional.

Thanks,
\- Bana