# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from pco_tools import pco_reader as pco
import matplotlib.pyplot as plt
import os
from PIL import Image
from io import BytesIO

file = '1190305012b.b16'
folder = r'C:\Users\Plasma\Box\elizabethtan\2018-19 WIRX Honors Thesis\Images and Figures\ccd'
path = os.path.join(folder, file)
img = pco.load(path)

plt.close("all")
# use this to check histogram and determine clim
plt.hist(img.ravel(), bins=256, range=(0.0, 2000.0), fc='k', ec='k')
plt.yscale('log', nonposy='clip')

plt.figure()
fig = plt.imshow(img,cmap='gray',clim=(80, 250))
plt.colorbar()
#cmap options: 'jet','plasma','cividis','magma','gray' see full list below

#png1 = BytesIO()
#fig.savefig(png1, format='png')

# (2) load this image into PIL
#png2 = Image.open(png1)

# (3) save as TIFF
#png2.save('test.tiff')
#png1.close()

"""
cmaps = [('Perceptually Uniform Sequential', [
            'viridis', 'plasma', 'inferno', 'magma', 'cividis']),
         ('Sequential', [
            'Greys', 'Purples', 'Blues', 'Greens', 'Oranges', 'Reds',
            'YlOrBr', 'YlOrRd', 'OrRd', 'PuRd', 'RdPu', 'BuPu',
            'GnBu', 'PuBu', 'YlGnBu', 'PuBuGn', 'BuGn', 'YlGn']),
         ('Sequential (2)', [
            'binary', 'gist_yarg', 'gist_gray', 'gray', 'bone', 'pink',
            'spring', 'summer', 'autumn', 'winter', 'cool', 'Wistia',
            'hot', 'afmhot', 'gist_heat', 'copper']),
         ('Diverging', [
            'PiYG', 'PRGn', 'BrBG', 'PuOr', 'RdGy', 'RdBu',
            'RdYlBu', 'RdYlGn', 'Spectral', 'coolwarm', 'bwr', 'seismic']),
         ('Cyclic', ['twilight', 'twilight_shifted', 'hsv']),
         ('Qualitative', [
            'Pastel1', 'Pastel2', 'Paired', 'Accent',
            'Dark2', 'Set1', 'Set2', 'Set3',
            'tab10', 'tab20', 'tab20b', 'tab20c']),
         ('Miscellaneous', [
            'flag', 'prism', 'ocean', 'gist_earth', 'terrain', 'gist_stern',
            'gnuplot', 'gnuplot2', 'CMRmap', 'cubehelix', 'brg',
            'gist_rainbow', 'rainbow', 'jet', 'nipy_spectral', 'gist_ncar'])]
"""