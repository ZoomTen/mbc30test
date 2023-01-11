# MBC3 / MBC30 Test ROM

This simple ROM aims to test your Game Boy, emulator, console or whatever that plays Game Boy games to check if it's MBC30-ready. It is inspired by [HyperHacker's MBC3 Tester ROM](https://github.com/EricKirschenmann/MBC3-Tester-gb), but with the addition of testing SRAM as well.

The MBC30 is a variant of the MBC3 mapper that allows for up to 4MB ROM and 64KB SRAM. In contrast, the more common MBC3 mapper only allows up to 2MB ROM and 32KB SRAM.

This source was built for [ASMotor](https://github.com/asmotor/asmotor), although hopefully it shouldn't be too hard to port it to RGBDS.

## Test results

### Full MBC30 support

![](screenshots/mbc30_rom.png)
![](screenshots/mbc30_sram.png)

No X's are to be seen.

### Unsupported / MBC3 only

![](screenshots/mbc3_rom.png)
![](screenshots/mbc3_sram.png)

* **ROM**: X's fill half the table or more.
* **SRAM**: If X's fill the table and the `MBC3 SRAM OK!` message is displayed, only up 32KB SRAM is supported. This table might be filled with dots instead and the message `MBC30 SRAM OK!` &mdash; in which case, 64KB SRAM is supported even despite the ROM being limited to 2MB.
