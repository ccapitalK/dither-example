import std.conv;
import std.exception;
import std.math;
import std.parallelism;
import std.range;

import simple_image;

static immutable ubyte[8][8] bayerMatrix = [
    [ 0, 32,  8, 40,  2, 34, 10, 42],
    [48, 16, 56, 24, 50, 18, 58, 26],
    [12, 44,  4, 36, 14, 46,  6, 38],
    [60, 28, 52, 20, 62, 30, 54, 22],
    [ 3, 35, 11, 43,  1, 33,  9, 41],
    [51, 19, 59, 27, 49, 17, 57, 25],
    [15, 47,  7, 39, 13, 45,  5, 37],
    [63, 31, 55, 23, 61, 29, 53, 21],
];

float ditherQuantize(float v, size_t stepsPerChannel, size_t x, size_t y) {
    double scaled = (v * stepsPerChannel);
    auto bayerMatrixCoeff = bayerMatrix[x % 8][y % 8];
    double choice = (bayerMatrixCoeff + .5) / 64;
    if ((scaled % 1) >= choice) {
        return scaled.ceil / stepsPerChannel;
    } else {
        return scaled.floor / stepsPerChannel;
    }
}

Image dither(Image image, size_t stepsPerChannel) {
    image = image.dup;
    foreach (y; image.height.iota.parallel) {
        foreach (x; 0 .. image.width) {
            auto pix = image.pixel(x, y);
            foreach (i; 0 .. 3) {
                pix[i] = pix[i]
                    .srgbUnormToLinearF32
                    .ditherQuantize(stepsPerChannel, x + 3 * i, y + 7 * i) // step by plane
                    .linearF32ToSrgbUnorm;
            }
        }
    }
    return image;
}

void main(string[] args) {
    enforce(args.length >= 3 && args.length <= 4, "Usage: app inFile outFile [steps]");
    auto inFile = args[1];
    auto outFile = args[2];
    auto steps = args.length > 3 ? args[3].to!size_t : 12;
    auto image = inFile.loadImageRgb();
    image.dither(steps).writeImageRgb(outFile);
}
