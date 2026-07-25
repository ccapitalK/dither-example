# Dither example

Simple ordered dithering example implementation, using D + simple_image. Uses Bayer matrix coefficients + thread per scanline for fast cpu implementation.

## Example 

Source quality:

![Source quality](16777216-color-source.png)

64 colors, no dithering:

![64 colors, no dithering](64-color-no-dither.png)

64 colors, dithering:

![64 colors, dithering](64-color-dither.png)

1728colors, dithering:

![1728 colors, dithering](1728-color-dither.png)
