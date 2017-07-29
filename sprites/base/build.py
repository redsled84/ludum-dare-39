import numpy as np
import skimage as sk
import skimage.io as skio
import sys, os
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_files', nargs='+')
    parser.add_argument('--palette')
    parser.add_argument('--output-dir')
    args = parser.parse_args()

    palette = None
    with open(args.palette) as f:
        palette = parse_palette(f.read())
        print 'Loaded {}-color palette:'.format(len(palette))
        for hexcode in palette:
            print hexcode

    incr = 256 / len(palette)

    for arg in args.input_files:
        im = None
        with open(arg) as f:
            im = skio.imread(f)
        im_r = im[:,:,0]
        w, h = im_r.shape
        layers = []
        for i in xrange(0, 256, incr):
            layers.append(im_r == i)

        im_comp = np.zeros(im.shape).astype(np.uint8)
        for i, layer in enumerate(layers):
            color_tuple = hexcode2tuple(palette[i])
            layer_tiled = layer.astype(np.uint8).reshape(w, h, 1).repeat(4, axis=2)
            color_tiled = np.array(color_tuple).astype(np.uint8).reshape(1, 1, -1).repeat(w, axis=0).repeat(h, axis=1)
            im_comp += layer_tiled * color_tiled


        comp_list = np.dsplit(im_comp, 4)[:3]
        comp_list.append(np.dsplit(im, 4)[3])
        im_comp = np.dstack(comp_list)

        skio.imsave(os.path.join(args.output_dir, arg), im_comp)


def parse_palette(s):
    hexcodes = []
    for i, c in enumerate(s):
        if c == '#':
            hexcodes.append(s[i+1:i+7])
    return hexcodes

def hexcode2tuple(hc):
    return (\
            int(hc[0:2], 16),\
            int(hc[2:4], 16),\
            int(hc[4:6], 16),\
            255,
            )


if __name__ == '__main__':
    main()

